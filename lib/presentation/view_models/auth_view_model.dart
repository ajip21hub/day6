import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/api_service.dart';

/// Auth ViewModel
/// Handle authentication logic & state management
/// Menggunakan ChangeNotifier (Provider) untuk reactive UI
/// 
/// ViewModel Pattern Benefits:
/// - Separation of concerns: business logic terpisah dari UI
/// - Testable: mudah untuk unit test
/// - Reusable: bisa digunakan di multiple screens

class AuthViewModel extends ChangeNotifier {
  final AuthRepository repository;
  final BiometricService biometricService;

  AuthViewModel({
    required this.repository,
    required this.biometricService,
  });

  // ====================
  // STATE
  // ====================

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  Map<String, dynamic>? _deviceConflictInfo;
  bool _isBiometricAvailable = false;

  // ====================
  // GETTERS
  // ====================

  /// Is loading (untuk show loading indicator)
  bool get isLoading => _isLoading;

  /// Error message (null jika tidak ada error)
  String? get errorMessage => _errorMessage;

  /// Current logged in user (null jika belum login)
  User? get currentUser => _currentUser;

  /// Is authenticated (apakah user sudah login)
  bool get isAuthenticated => _currentUser != null;

  /// Device conflict info (info device yang sedang login)
  /// Digunakan untuk tampilkan info ke user saat device conflict
  Map<String, dynamic>? get deviceConflictInfo => _deviceConflictInfo;

  /// Is biometric available on this device
  bool get isBiometricAvailable => _isBiometricAvailable;

  /// Is biometric enabled untuk user ini
  bool get isBiometricEnabled => repository.isBiometricEnabled();

  // ====================
  // INITIALIZATION
  // ====================

  /// Initialize ViewModel
  /// Check biometric availability dan load current user jika sudah login
  Future<void> initialize() async {
    // Check biometric availability
    _isBiometricAvailable = await biometricService.isDeviceSupported();
    notifyListeners();

    // Load current user jika sudah login
    if (repository.isLoggedIn()) {
      await loadCurrentUser();
    }
  }

  // ====================
  // LOGIN
  // ====================

  /// Login dengan email & password
  /// Return true jika login berhasil, false jika gagal
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await repository.login(
        email: email,
        password: password,
      );

      _setLoading(false);
      return true;
    } on DeviceConflictException catch (e) {
      // User sudah login di device lain
      _errorMessage = e.message;
      _deviceConflictInfo = e.deviceInfo;
      _setLoading(false);
      return false;
    } on ValidationException catch (e) {
      // Email/password salah
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } on NetworkException catch (e) {
      // Tidak ada internet
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      // Unknown error
      _errorMessage = 'Terjadi kesalahan: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Login dengan biometric
  /// 
  /// Flow:
  /// 1. Check if biometric enabled
  /// 2. Authenticate dengan biometric
  /// 3. Get saved credentials
  /// 4. Auto login dengan credentials
  Future<bool> loginWithBiometric() async {
    // 1. Check if biometric enabled
    if (!isBiometricEnabled) {
      _errorMessage = 'Biometric login belum diaktifkan';
      notifyListeners();
      return false;
    }

    // 2. Authenticate dengan biometric
    final result = await biometricService.authenticate(
      localizedReason: 'Login ke aplikasi',
    );

    if (!result.success) {
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }

    // 3. Get saved credentials
    final credentials = await repository.getBiometricCredentials();
    if (credentials == null) {
      _errorMessage = 'Credentials tidak ditemukan. Silakan login manual.';
      notifyListeners();
      return false;
    }

    // 4. Auto login dengan credentials
    return await login(
      email: credentials['email']!,
      password: credentials['password']!,
    );
  }

  // ====================
  // REGISTER
  // ====================

  /// Register user baru
  /// Return true jika register berhasil, false jika gagal
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await repository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      _setLoading(false);
      return true;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _setLoading(false);
      return false;
    }
  }

  // ====================
  // LOGOUT
  // ====================

  /// Logout dari aplikasi
  Future<void> logout() async {
    _setLoading(true);

    try {
      await repository.logout();
      _currentUser = null;
      _clearError();
      _setLoading(false);
    } catch (e) {
      // Tetap clear user meskipun ada error
      _currentUser = null;
      _setLoading(false);
    }
  }

  // ====================
  // USER DATA
  // ====================

  /// Load current user data
  /// Digunakan saat app start untuk check apakah user sudah login
  Future<void> loadCurrentUser({bool forceRefresh = false}) async {
    try {
      _currentUser = await repository.getCurrentUser(
        forceRefresh: forceRefresh,
      );
      notifyListeners();
    } on UnauthorizedException {
      // Token expired, logout
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      // Ignore error, keep current state
    }
  }

  // ====================
  // BIOMETRIC
  // ====================

  /// Enable biometric login
  /// Save credentials untuk auto-login
  Future<bool> enableBiometric({
    required String email,
    required String password,
  }) async {
    // 1. Check if biometric available
    if (!_isBiometricAvailable) {
      _errorMessage = 'Biometric tidak tersedia di device ini';
      notifyListeners();
      return false;
    }

    // 2. Test biometric authentication
    final result = await biometricService.authenticate(
      localizedReason: 'Aktifkan biometric login',
    );

    if (!result.success) {
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }

    // 3. Save credentials
    try {
      await repository.enableBiometric(
        email: email,
        password: password,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengaktifkan biometric: $e';
      notifyListeners();
      return false;
    }
  }

  /// Disable biometric login
  Future<void> disableBiometric() async {
    try {
      await repository.disableBiometric();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menonaktifkan biometric: $e';
      notifyListeners();
    }
  }

  // ====================
  // HELPERS
  // ====================

  /// Set loading state dan notify listeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Clear error message dan device conflict info
  void _clearError() {
    _errorMessage = null;
    _deviceConflictInfo = null;
  }

  /// Clear error message (public method untuk dipanggil dari UI)
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
