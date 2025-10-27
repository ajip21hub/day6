import '../../domain/entities/user.dart';
import '../../core/services/api_service.dart';
import '../data_sources/remote/auth_remote_datasource.dart';
import '../data_sources/local/auth_local_datasource.dart';
import '../models/user_model.dart';

/// Auth Repository
/// Menggabungkan remote & local data sources
/// Single source of truth untuk authentication
/// 
/// Repository Pattern Benefits:
/// - ViewModel tidak perlu tahu data dari mana (API atau cache)
/// - Mudah untuk switch data source (misalnya dari REST ke GraphQL)
/// - Mudah untuk testing (bisa mock repository)

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ====================
  // LOGIN & REGISTER
  // ====================

  /// Login dengan email & password
  /// 
  /// Flow:
  /// 1. Call login API
  /// 2. Save tokens ke secure storage
  /// 3. Save user data ke local storage
  /// 4. Set login status
  /// 5. Return User entity
  /// 
  /// Throws:
  /// - DeviceConflictException jika user sudah login di device lain
  /// - ValidationException jika email/password salah
  /// - NetworkException jika tidak ada internet
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login via API
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // 2. Parse user data
      final userModel = UserModel.fromJson(response['user']);

      // 3. Save tokens (encrypted di secure storage)
      await localDataSource.saveTokens(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
      );

      // 4. Save user data (di SharedPreferences)
      await localDataSource.saveUser(userModel);
      
      // 5. Set login status
      await localDataSource.setLoggedIn(true);

      // 6. Return entity untuk digunakan di ViewModel
      return userModel.toEntity();
    } on DeviceConflictException {
      // User sudah login di device lain
      // Re-throw untuk di-handle di ViewModel
      rethrow;
    } on ValidationException {
      // Email/password salah
      rethrow;
    } on NetworkException {
      // Tidak ada internet
      rethrow;
    } catch (e) {
      // Unknown error
      rethrow;
    }
  }

  /// Register user baru
  /// Flow sama dengan login
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // 1. Register via API
      final response = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      // 2. Parse user data
      final userModel = UserModel.fromJson(response['user']);

      // 3. Save tokens
      await localDataSource.saveTokens(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
      );

      // 4. Save user data
      await localDataSource.saveUser(userModel);
      await localDataSource.setLoggedIn(true);

      // 5. Return entity
      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  // ====================
  // LOGOUT
  // ====================

  /// Logout dari aplikasi
  /// 
  /// Flow:
  /// 1. Call logout API (untuk hapus device ID dari backend)
  /// 2. Clear local data (tokens, user data, biometric credentials)
  /// 
  /// Note: Jika API call gagal, tetap clear local data
  Future<void> logout() async {
    try {
      // 1. Call logout API
      await remoteDataSource.logout();
    } catch (e) {
      // Ignore error dari API
      // Tetap lanjut clear local data
    } finally {
      // 2. Clear all local data
      await localDataSource.clearAuthData();
    }
  }

  // ====================
  // GET USER
  // ====================

  /// Get current user
  /// 
  /// Strategy: Cache-first
  /// 1. Coba ambil dari cache dulu
  /// 2. Kalau tidak ada cache, fetch dari API
  /// 3. Save hasil fetch ke cache
  Future<User> getCurrentUser({bool forceRefresh = false}) async {
    // Force refresh: skip cache, langsung fetch dari API
    if (!forceRefresh) {
      // 1. Try get from cache
      final cachedUser = localDataSource.getCachedUser();
      if (cachedUser != null) {
        return cachedUser.toEntity();
      }
    }

    // 2. Fetch from API
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      
      // 3. Save to cache
      await localDataSource.saveUser(userModel);
      
      return userModel.toEntity();
    } on UnauthorizedException {
      // Token expired atau invalid
      // Clear local data dan re-throw
      await localDataSource.clearAuthData();
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // ====================
  // CHECK STATUS
  // ====================

  /// Check if user is logged in
  /// Hanya check local status, tidak call API
  bool isLoggedIn() {
    return localDataSource.isLoggedIn();
  }

  /// Check if biometric is enabled
  bool isBiometricEnabled() {
    return localDataSource.isBiometricEnabled();
  }

  // ====================
  // BIOMETRIC
  // ====================

  /// Enable biometric login
  /// Save credentials untuk auto-login dengan biometric
  Future<void> enableBiometric({
    required String email,
    required String password,
  }) async {
    // Encode credentials (dalam production, gunakan proper encryption)
    final credential = '$email:$password';
    
    await localDataSource.saveBiometricCredential(credential);
    await localDataSource.setBiometricEnabled(true);
  }

  /// Disable biometric login
  Future<void> disableBiometric() async {
    await localDataSource.deleteBiometricCredential();
    await localDataSource.setBiometricEnabled(false);
  }

  /// Get biometric credentials untuk auto-login
  Future<Map<String, String>?> getBiometricCredentials() async {
    final credential = await localDataSource.getBiometricCredential();
    if (credential == null) return null;

    // Parse credential
    final parts = credential.split(':');
    if (parts.length != 2) return null;

    return {
      'email': parts[0],
      'password': parts[1],
    };
  }

  // ====================
  // TOKEN REFRESH
  // ====================

  /// Refresh access token
  /// Digunakan saat access token expired
  Future<void> refreshToken() async {
    try {
      // 1. Get refresh token dari local
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        throw UnauthorizedException('Refresh token not found');
      }

      // 2. Call refresh API
      final response = await remoteDataSource.refreshAccessToken(refreshToken);

      // 3. Save new tokens
      await localDataSource.saveTokens(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
      );
    } catch (e) {
      // Token refresh gagal, clear auth data
      await localDataSource.clearAuthData();
      rethrow;
    }
  }
}
