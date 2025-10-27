# 🚀 Implementation Guide

Panduan praktis untuk mengimplementasikan fitur-fitur di aplikasi ini.

## 📋 Status Implementasi

### ✅ Sudah Dibuat (Foundation)
- [x] Core Constants (API, Storage Keys, App Constants)
- [x] Core Utils (Validators, Date Formatter, Currency Formatter)
- [x] Core Services (API, Storage, Biometric, Device)
- [x] Domain Entities (User, TaxReport, WorkHistory, TaxAccumulation)
- [x] Data Models (dengan fromJson/toJson dan toEntity)
- [x] Main.dart (Entry point dengan setup services)
- [x] Dokumentasi lengkap (README.md, STUDY_GUIDE.md)

### ⏳ Perlu Diimplementasikan
- [ ] Data Sources (Remote & Local)
- [ ] Repositories
- [ ] ViewModels
- [ ] Views/Screens
- [ ] Widgets

---

## 🎯 Cara Mengimplementasikan Fitur Baru

### Step 1: Buat Remote Data Source

Lokasi: `lib/data/data_sources/remote/`

```dart
// lib/data/data_sources/remote/auth_remote_datasource.dart

import '../../../core/services/api_service.dart';
import '../../../core/services/device_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/user_model.dart';

/// Auth Remote Data Source
/// Handle semua API calls untuk authentication

class AuthRemoteDataSource {
  final ApiService apiService;
  final DeviceService deviceService;

  AuthRemoteDataSource({
    required this.apiService,
    required this.deviceService,
  });

  /// Login dengan email & password
  /// Return UserModel dan tokens
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

    // 3. Return response (berisi user data & tokens)
    // Expected response:
    // {
    //   "user": {...},
    //   "accessToken": "...",
    //   "refreshToken": "..."
    // }
    return response;
  }

  /// Register user baru
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
      requiresAuth: false,
    );

    return response;
  }

  /// Logout
  Future<void> logout() async {
    final deviceId = await deviceService.getDeviceId();
    
    await apiService.post(
      ApiConstants.logout,
      body: {'deviceId': deviceId},
      requiresAuth: true,
    );
  }

  /// Get current user
  Future<UserModel> getCurrentUser() async {
    final response = await apiService.get(
      ApiConstants.profile,
      requiresAuth: true,
    );

    return UserModel.fromJson(response['user']);
  }
}
```

### Step 2: Buat Local Data Source

Lokasi: `lib/data/data_sources/local/`

```dart
// lib/data/data_sources/local/auth_local_datasource.dart

import '../../../core/services/storage_service.dart';
import '../../models/user_model.dart';

/// Auth Local Data Source
/// Handle caching & local storage untuk auth

class AuthLocalDataSource {
  final StorageService storageService;

  AuthLocalDataSource({required this.storageService});

  /// Save user data ke local storage
  Future<void> saveUser(UserModel user) async {
    await storageService.saveUserData(user.toJson());
  }

  /// Get cached user data
  UserModel? getCachedUser() {
    final userData = storageService.getUserData();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  /// Save tokens ke secure storage
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await storageService.saveAccessToken(accessToken);
    await storageService.saveRefreshToken(refreshToken);
  }

  /// Delete user data & tokens (logout)
  Future<void> clearUserData() async {
    await storageService.clearAll();
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return storageService.isLoggedIn();
  }

  /// Set login status
  Future<void> setLoggedIn(bool status) async {
    await storageService.setLoggedIn(status);
  }
}
```

### Step 3: Buat Repository

Lokasi: `lib/data/repositories/`

```dart
// lib/data/repositories/auth_repository.dart

import '../../domain/entities/user.dart';
import '../../core/services/api_service.dart';
import '../data_sources/remote/auth_remote_datasource.dart';
import '../data_sources/local/auth_local_datasource.dart';
import '../models/user_model.dart';

/// Auth Repository
/// Menggabungkan remote & local data sources
/// Single source of truth untuk authentication

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Login
  /// 1. Call API
  /// 2. Save tokens & user data
  /// 3. Return User entity
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
    } on DeviceConflictException catch (e) {
      // User sudah login di device lain
      // Re-throw untuk di-handle di ViewModel
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user
  /// Coba dari cache dulu, kalau ga ada baru fetch dari API
  Future<User> getCurrentUser() async {
    // 1. Try cache
    final cachedUser = localDataSource.getCachedUser();
    if (cachedUser != null) {
      return cachedUser.toEntity();
    }

    // 2. Fetch from API
    final userModel = await remoteDataSource.getCurrentUser();
    await localDataSource.saveUser(userModel);
    return userModel.toEntity();
  }

  /// Logout
  Future<void> logout() async {
    try {
      // 1. Call logout API
      await remoteDataSource.logout();
    } catch (e) {
      // Ignore error, clear local data anyway
    } finally {
      // 2. Clear local data
      await localDataSource.clearUserData();
    }
  }

  /// Check if logged in
  bool isLoggedIn() {
    return localDataSource.isLoggedIn();
  }
}
```

### Step 4: Buat ViewModel

Lokasi: `lib/presentation/view_models/`

```dart
// lib/presentation/view_models/auth_view_model.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/api_service.dart';

/// Auth ViewModel
/// Handle authentication logic & state
/// Menggunakan ChangeNotifier untuk state management

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

  // ====================
  // GETTERS
  // ====================

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  Map<String, dynamic>? get deviceConflictInfo => _deviceConflictInfo;

  // ====================
  // METHODS
  // ====================

  /// Login dengan email & password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _deviceConflictInfo = null;
    notifyListeners();

    try {
      _currentUser = await repository.login(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on DeviceConflictException catch (e) {
      // User sudah login di device lain
      _errorMessage = e.message;
      _deviceConflictInfo = e.deviceInfo;
      _isLoading = false;
      notifyListeners();
      return false;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login dengan biometric
  Future<bool> loginWithBiometric() async {
    // 1. Check if biometric enabled
    // 2. Authenticate
    // 3. Get saved credentials
    // 4. Auto login
    // TODO: Implement this
    return false;
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.logout();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load current user
  Future<void> loadCurrentUser() async {
    try {
      _currentUser = await repository.getCurrentUser();
      notifyListeners();
    } catch (e) {
      // Ignore
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    _deviceConflictInfo = null;
    notifyListeners();
  }
}
```

### Step 5: Buat View/Screen

Lokasi: `lib/presentation/views/auth/`

```dart
// lib/presentation/views/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../../core/utils/validators.dart';

/// Login Screen
/// UI untuk login dengan email & password atau biometric

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    
                    // Title
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Masuk ke akun Anda',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 48),
                    
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 24),
                    
                    // Error message
                    if (viewModel.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Login button
                    ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Biometric button
                    OutlinedButton.icon(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => viewModel.loginWithBiometric(),
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Login dengan Biometric'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## 🔄 Setup dengan Provider

Untuk menggunakan ViewModels dengan Provider, update `main.dart`:

```dart
import 'package:provider/provider.dart';

// ... imports

void main() async {
  // ... initialize services

  // Setup repositories
  final authRepository = AuthRepository(
    remoteDataSource: AuthRemoteDataSource(
      apiService: apiService,
      deviceService: deviceService,
    ),
    localDataSource: AuthLocalDataSource(
      storageService: storageService,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        // ViewModels
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            repository: authRepository,
            biometricService: biometricService,
          ),
        ),
        // Add more ViewModels here
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## 📝 Checklist Implementasi

### Authentication
- [ ] AuthRemoteDataSource
- [ ] AuthLocalDataSource
- [ ] AuthRepository
- [ ] AuthViewModel
- [ ] LoginScreen
- [ ] RegisterScreen
- [ ] BiometricSetupScreen

### Tax Reports
- [ ] TaxRemoteDataSource
- [ ] TaxRepository
- [ ] TaxViewModel
- [ ] TaxReportListScreen
- [ ] TaxReportDetailScreen
- [ ] CreateTaxReportScreen

### Work History
- [ ] WorkHistoryRemoteDataSource
- [ ] WorkHistoryRepository
- [ ] WorkHistoryViewModel
- [ ] WorkHistoryListScreen
- [ ] WorkHistoryDetailScreen

### Profile
- [ ] ProfileRemoteDataSource
- [ ] ProfileRepository
- [ ] ProfileViewModel
- [ ] ProfileScreen
- [ ] EditProfileScreen

---

## 🎯 Tips Implementation

1. **Mulai dari Authentication** - Ini adalah foundation untuk semua fitur lain
2. **Test di setiap layer** - Jangan langsung ke UI, test logic dulu
3. **Handle errors dengan baik** - Gunakan try-catch dan custom exceptions
4. **Gunakan const widgets** - Untuk performa lebih baik
5. **Follow MVVM strictly** - Jangan skip layers

---

**Happy Coding! 🚀**
