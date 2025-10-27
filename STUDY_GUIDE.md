# 📚 Study Guide - Tax Retribution App MVVM

Panduan belajar step-by-step untuk memahami arsitektur MVVM Flutter ini.

## 🎯 Tujuan Pembelajaran

Setelah mempelajari project ini, Anda akan memahami:
1. Arsitektur MVVM (Model-View-ViewModel)
2. Separation of Concerns dalam development
3. State management dengan Provider
4. Authentication flow dengan biometric
5. Single device login implementation
6. API integration best practices

## 📖 Urutan Pembelajaran

### Level 1: Foundation (Core)

#### 1.1 Constants
**File**: `lib/core/constants/`

Mulai dengan membaca file constants untuk memahami apa saja yang dipakai di aplikasi:

```dart
// Urutan baca:
1. app_constants.dart    - Konstanta umum aplikasi
2. storage_keys.dart     - Keys untuk local storage
3. api_constants.dart    - API endpoints
```

**Key Learning**:
- Mengapa perlu centralize constants?
- Bagaimana manage API endpoints yang banyak?
- Best practice untuk naming keys

#### 1.2 Utils
**File**: `lib/core/utils/`

Utility functions yang sering dipakai:

```dart
// Urutan baca:
1. validators.dart         - Form validation
2. date_formatter.dart     - Format tanggal Indonesia
3. currency_formatter.dart - Format Rupiah
```

**Key Learning**:
- Reusable validators untuk form
- Format tanggal dengan locale Indonesia
- Format currency dengan NumberFormat
- Cara combine multiple validators

**Latihan**:
```dart
// Coba test validators:
print(Validators.email('test@example.com')); // null (valid)
print(Validators.email('invalid')); // 'Format email tidak valid'

// Coba date formatter:
print(DateFormatter.toDisplayDate(DateTime.now())); // "26 Okt 2025"
print(DateFormatter.toRelativeTime(DateTime.now().subtract(Duration(hours: 2)))); // "2 jam lalu"

// Coba currency formatter:
print(CurrencyFormatter.format(1500000)); // "Rp 1.500.000"
print(CurrencyFormatter.formatCompact(1500000)); // "Rp 1,5 Jt"
```

#### 1.3 Services
**File**: `lib/core/services/`

Core services yang dipakai di seluruh aplikasi:

```dart
// Urutan baca (dari simple ke complex):
1. storage_service.dart    - Local storage wrapper
2. device_service.dart     - Device info management
3. biometric_service.dart  - Fingerprint/Face ID
4. api_service.dart        - HTTP client wrapper
```

**Key Learning - StorageService**:
```dart
// Perbedaan SharedPreferences vs FlutterSecureStorage:

// SharedPreferences - untuk data NON-SENSITIF
await storageService.setLoggedIn(true);
final isLoggedIn = storageService.isLoggedIn();

// FlutterSecureStorage - untuk data SENSITIF (encrypted)
await storageService.saveAccessToken('token_abc_123');
final token = await storageService.getAccessToken();
```

**Key Learning - BiometricService**:
```dart
// Check availability
final isAvailable = await biometricService.isDeviceSupported();

// Authenticate
final result = await biometricService.authenticate(
  localizedReason: 'Login ke aplikasi',
);

if (result.success) {
  // Biometric success
} else {
  // Handle error: result.errorType, result.message
}
```

**Key Learning - DeviceService**:
```dart
// Get device ID untuk single device login
final deviceId = await deviceService.getDeviceId();

// Get device info
final deviceInfo = await deviceService.getDeviceInfo();
// {
//   'deviceId': 'abc123',
//   'deviceName': 'iPhone 12 Pro',
//   'platform': 'ios',
//   'osVersion': '16.0'
// }
```

**Key Learning - ApiService**:
```dart
// GET request
final response = await apiService.get('/tax/reports');

// POST request dengan body
final response = await apiService.post(
  '/auth/login',
  body: {
    'email': 'user@example.com',
    'password': 'password123',
    'deviceId': deviceId,
  },
);

// Automatic error handling:
try {
  final response = await apiService.get('/protected-endpoint');
} on UnauthorizedException {
  // Token expired - redirect to login
} on DeviceConflictException catch (e) {
  // User logged in di device lain
  print(e.deviceInfo); // Info device yang sedang login
} on NetworkException {
  // No internet connection
}
```

---

### Level 2: Data Layer

#### 2.1 Models
**File**: `lib/data/models/`

Models adalah representasi data dari API (JSON to Dart object):

```dart
// Contoh struktur model:
class UserModel {
  final String id;
  final String email;
  final String name;
  
  // Constructor
  UserModel({required this.id, required this.email, required this.name});
  
  // fromJson - convert dari JSON ke object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }
  
  // toJson - convert dari object ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}
```

**Key Learning**:
- Model adalah data structure dari API
- `fromJson` untuk parse API response
- `toJson` untuk send data ke API

#### 2.2 Data Sources
**File**: `lib/data/data_sources/`

Data sources handle komunikasi dengan API:

```dart
// Remote Data Source - fetch dari API
class TaxRemoteDataSource {
  final ApiService apiService;
  
  Future<List<TaxReportModel>> getTaxReports() async {
    final response = await apiService.get('/tax/reports');
    final list = response['data'] as List;
    return list.map((json) => TaxReportModel.fromJson(json)).toList();
  }
}

// Local Data Source - fetch dari cache
class AuthLocalDataSource {
  final StorageService storageService;
  
  Future<UserModel?> getCachedUser() async {
    final userData = storageService.getUserData();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }
}
```

**Key Learning**:
- Remote data source = API calls
- Local data source = cache/local storage
- Separation untuk mudah testing

#### 2.3 Repositories
**File**: `lib/data/repositories/`

Repository adalah layer yang menggabungkan data sources:

```dart
class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  // Login: call API + save to cache
  Future<User> login(String email, String password) async {
    // 1. Call API
    final userModel = await remoteDataSource.login(email, password);
    
    // 2. Save to cache
    await localDataSource.saveUser(userModel);
    
    // 3. Convert model to entity
    return userModel.toEntity();
  }
  
  // Get user: coba dari cache dulu, kalau ga ada baru call API
  Future<User> getUser() async {
    // 1. Try get from cache
    final cachedUser = await localDataSource.getCachedUser();
    if (cachedUser != null) {
      return cachedUser.toEntity();
    }
    
    // 2. If cache miss, fetch from API
    final userModel = await remoteDataSource.getUser();
    await localDataSource.saveUser(userModel);
    return userModel.toEntity();
  }
}
```

**Key Learning**:
- Repository adalah single source of truth
- Handle caching strategy di sini
- ViewModel hanya call repository, tidak peduli data dari mana

---

### Level 3: Domain Layer

#### 3.1 Entities
**File**: `lib/domain/entities/`

Entities adalah business objects (pure Dart, tidak tergantung framework):

```dart
class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  
  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
  });
}
```

**Key Learning**:
- Entity vs Model: Entity untuk business logic, Model untuk data transfer
- Entity tidak punya `fromJson`/`toJson`
- Immutable (semua field final)

#### 3.2 Repository Interfaces
**File**: `lib/domain/repositories/`

Interface untuk repository (untuk dependency inversion):

```dart
abstract class IAuthRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<User> getCurrentUser();
}
```

**Key Learning**:
- Interface memudahkan testing (bisa mock)
- Dependency inversion principle
- ViewModel depend on interface, bukan concrete class

---

### Level 4: Presentation Layer

#### 4.1 ViewModels
**File**: `lib/presentation/view_models/`

ViewModel adalah bridge antara View dan Model:

```dart
class AuthViewModel extends ChangeNotifier {
  final IAuthRepository authRepository;
  final BiometricService biometricService;
  
  // State
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  
  // Methods
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Update UI
    
    try {
      _currentUser = await authRepository.login(email, password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loginWithBiometric() async {
    // 1. Authenticate dengan biometric
    final result = await biometricService.authenticate();
    
    if (!result.success) {
      _errorMessage = result.message;
      notifyListeners();
      return;
    }
    
    // 2. Get saved credentials
    // 3. Auto login
    // ...
  }
}
```

**Key Learning**:
- ViewModel extends `ChangeNotifier` (Provider)
- `notifyListeners()` untuk trigger UI rebuild
- Semua business logic ada di ViewModel
- View hanya display data dari ViewModel

#### 4.2 Views/Screens
**File**: `lib/presentation/views/`

View adalah UI layer (pure widget):

```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Column(
            children: [
              // Email field
              TextField(
                onChanged: (value) => email = value,
              ),
              
              // Password field
              TextField(
                onChanged: (value) => password = value,
              ),
              
              // Login button
              ElevatedButton(
                onPressed: viewModel.isLoading 
                  ? null 
                  : () => viewModel.login(email, password),
                child: viewModel.isLoading
                  ? CircularProgressIndicator()
                  : Text('Login'),
              ),
              
              // Error message
              if (viewModel.errorMessage != null)
                Text(viewModel.errorMessage!),
              
              // Biometric button
              IconButton(
                icon: Icon(Icons.fingerprint),
                onPressed: () => viewModel.loginWithBiometric(),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

**Key Learning**:
- View hanya render UI
- Tidak ada business logic di View
- `Consumer<T>` untuk listen changes dari ViewModel
- Reactive UI: UI auto rebuild saat `notifyListeners()` dipanggil

---

## 🔄 Flow Example: Login Process

```
1. USER ACTION
   ↓
   User tap login button di LoginScreen
   
2. VIEW → VIEWMODEL
   ↓
   LoginScreen.onPressed() calls authViewModel.login(email, password)
   
3. VIEWMODEL → REPOSITORY
   ↓
   AuthViewModel calls authRepository.login()
   
4. REPOSITORY → DATA SOURCE
   ↓
   AuthRepository calls authRemoteDataSource.login()
   
5. DATA SOURCE → API
   ↓
   AuthRemoteDataSource calls apiService.post('/auth/login')
   
6. API → DATA SOURCE
   ↓
   API returns JSON response
   
7. DATA SOURCE → REPOSITORY
   ↓
   Parse JSON to UserModel using fromJson()
   
8. REPOSITORY → VIEWMODEL
   ↓
   Save to cache, convert Model to Entity, return User
   
9. VIEWMODEL → VIEW
   ↓
   Set state, call notifyListeners()
   
10. VIEW UPDATE
    ↓
    Consumer rebuilds with new state
    Navigate to home screen
```

---

## 🎨 Single Device Login Flow

```
LOGIN REQUEST
    ↓
1. Get Device ID
   deviceId = await deviceService.getDeviceId()
   
2. Call Login API dengan deviceId
   response = await apiService.post('/auth/login', body: {
     'email': email,
     'password': password,
     'deviceId': deviceId,
   })
   
3. BACKEND CHECK:
   ├─ Apakah user sudah login di device lain?
   │  
   ├─ YES → Return 409 Conflict
   │         {
   │           'message': 'Logout dari device lain dulu',
   │           'deviceInfo': {
   │             'deviceName': 'iPhone 12',
   │             'lastLogin': '2024-01-20 10:30'
   │           }
   │         }
   │         ↓
   │         Throw DeviceConflictException
   │         ↓
   │         Show error dialog ke user dengan info device
   │
   └─ NO → Allow Login
             ↓
          Save deviceId ke database
             ↓
          Return token & user data
             ↓
          Save token & user data locally
             ↓
          Navigate to Home
```

---

## 🔐 Biometric Login Flow

```
BIOMETRIC LOGIN
    ↓
1. Check if biometric enabled
   if (!storageService.isBiometricEnabled()) {
     // Show: "Biometric belum diaktifkan"
     return;
   }
   
2. Authenticate dengan biometric
   result = await biometricService.authenticate()
   
3. Check result
   if (!result.success) {
     // Show error: result.message
     return;
   }
   
4. Get saved credentials
   credential = await storageService.getBiometricCredential()
   // credential = encrypted email + password hash
   
5. Auto login dengan saved credentials
   await authViewModel.loginWithCredential(credential)
   
6. Navigate to Home
```

---

## 💡 Best Practices yang Diimplementasikan

### 1. Separation of Concerns
```
View        → Hanya UI, tidak ada logic
ViewModel   → Business logic, state management
Repository  → Data access logic
Data Source → API calls / local storage
```

### 2. Single Responsibility
Setiap class punya 1 tanggung jawab:
- `ApiService` → HTTP requests
- `StorageService` → Local storage
- `BiometricService` → Biometric auth
- `Validators` → Form validation

### 3. Dependency Injection
```dart
// Bad: hard-coded dependency
class AuthViewModel {
  final repository = AuthRepository(); // ❌
}

// Good: inject dependency
class AuthViewModel {
  final IAuthRepository repository;
  AuthViewModel({required this.repository}); // ✅
}
```

### 4. Error Handling
```dart
// Specific exceptions untuk berbagai error types
try {
  await apiService.get('/endpoint');
} on UnauthorizedException {
  // Handle 401
} on DeviceConflictException {
  // Handle 409 (device conflict)
} on NetworkException {
  // Handle network error
} on ApiException catch (e) {
  // Handle general API error
}
```

---

## 📝 Checklist Pembelajaran

### Core (Foundation)
- [ ] Pahami semua constants
- [ ] Coba semua validators
- [ ] Coba date & currency formatters
- [ ] Pahami StorageService (SharedPreferences vs SecureStorage)
- [ ] Pahami ApiService & exception handling
- [ ] Pahami BiometricService
- [ ] Pahami DeviceService

### Data Layer
- [ ] Pahami Model structure (fromJson, toJson)
- [ ] Pahami Data Source pattern
- [ ] Pahami Repository pattern
- [ ] Pahami caching strategy

### Domain Layer
- [ ] Pahami Entity vs Model
- [ ] Pahami Repository Interface

### Presentation Layer
- [ ] Pahami ViewModel & ChangeNotifier
- [ ] Pahami Consumer & Provider
- [ ] Pahami reactive UI concept

### Flows
- [ ] Pahami complete login flow
- [ ] Pahami single device login
- [ ] Pahami biometric login

---

## 🚀 Next Steps

Setelah memahami struktur, Anda bisa:

1. **Implement Missing Features**
   - Tax report screen
   - Work history screen
   - Profile screen

2. **Add Tests**
   - Unit tests untuk ViewModels
   - Widget tests untuk Views
   - Integration tests

3. **Improve Error Handling**
   - Retry mechanism
   - Offline mode
   - Error logging

4. **Add Features**
   - Pull to refresh
   - Pagination
   - Search & filter

---

**Happy Learning! 🎉**
