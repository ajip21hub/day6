import '../../../core/services/api_service.dart';
import '../../../core/services/device_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/user_model.dart';

/// Auth Remote Data Source
/// Handle semua API calls untuk authentication
/// Layer ini bertanggung jawab untuk komunikasi dengan backend API

class AuthRemoteDataSource {
  final ApiService apiService;
  final DeviceService deviceService;

  AuthRemoteDataSource({
    required this.apiService,
    required this.deviceService,
  });

  /// Login dengan email & password
  /// Return response yang berisi user data dan tokens
  /// 
  /// Flow:
  /// 1. Get device info untuk single device login
  /// 2. Call login API dengan credentials + device info
  /// 3. Return response (user, accessToken, refreshToken)
  /// 
  /// Throws:
  /// - DeviceConflictException jika user sudah login di device lain
  /// - ValidationException jika email/password salah
  /// - NetworkException jika tidak ada internet
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // 1. Get device info untuk single device login
    final deviceId = await deviceService.getDeviceId();
    final deviceName = await deviceService.getDeviceName();

    // 2. Call API
    final response = await apiService.post(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
        'deviceId': deviceId,
        'deviceName': deviceName,
      },
      requiresAuth: false, // Login tidak perlu token
    );

    // 3. Return response
    // Expected response structure:
    // {
    //   "user": {
    //     "id": "user_123",
    //     "email": "user@example.com",
    //     "name": "John Doe",
    //     "phone": "08123456789",
    //     "photoUrl": null,
    //     "createdAt": "2024-01-15T10:30:00Z"
    //   },
    //   "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    //   "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    // }
    return response;
  }

  /// Register user baru
  /// Return response dengan user data dan tokens
  /// 
  /// Throws:
  /// - ValidationException jika email sudah terdaftar atau data tidak valid
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await apiService.post(
      ApiConstants.register,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      },
      requiresAuth: false, // Register tidak perlu token
    );

    // Response structure sama dengan login
    return response;
  }

  /// Logout dari device ini
  /// Menghapus device ID dari backend
  /// 
  /// Throws:
  /// - UnauthorizedException jika token tidak valid
  Future<void> logout() async {
    final deviceId = await deviceService.getDeviceId();
    
    await apiService.post(
      ApiConstants.logout,
      body: {'deviceId': deviceId},
      requiresAuth: true, // Logout memerlukan token
    );
  }

  /// Get current user data dari server
  /// Digunakan untuk refresh user data atau saat pertama kali load app
  /// 
  /// Throws:
  /// - UnauthorizedException jika token tidak valid/expired
  Future<UserModel> getCurrentUser() async {
    final response = await apiService.get(
      ApiConstants.profile,
      requiresAuth: true,
    );

    // Expected response:
    // {
    //   "user": {...}
    // }
    return UserModel.fromJson(response['user']);
  }

  /// Refresh access token menggunakan refresh token
  /// Digunakan saat access token expired
  /// 
  /// Throws:
  /// - UnauthorizedException jika refresh token tidak valid
  Future<Map<String, dynamic>> refreshAccessToken(String refreshToken) async {
    final response = await apiService.post(
      ApiConstants.refreshToken,
      body: {'refreshToken': refreshToken},
      requiresAuth: false,
    );

    // Expected response:
    // {
    //   "accessToken": "...",
    //   "refreshToken": "..."
    // }
    return response;
  }

  /// Check device status
  /// Cek apakah device ini masih boleh login atau tidak
  /// Digunakan untuk validasi sebelum login
  Future<Map<String, dynamic>> checkDeviceStatus() async {
    final deviceId = await deviceService.getDeviceId();
    
    final response = await apiService.get(
      ApiConstants.deviceStatus,
      queryParameters: {'deviceId': deviceId},
      requiresAuth: false,
    );

    // Expected response:
    // {
    //   "isAllowed": true,
    //   "currentDevice": {
    //     "deviceId": "...",
    //     "deviceName": "...",
    //     "lastLogin": "..."
    //   }
    // }
    return response;
  }
}
