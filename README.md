# Tax Retribution App - MVVM Flutter

Aplikasi pelaporan retribusi pajak dengan arsitektur MVVM yang mudah dipahami untuk solo developer / mini team.

## 📱 Fitur Utama

- ✅ Authentication (Login/Register)
- 🔐 Login dengan Fingerprint
- 👤 Login dengan Face ID
- 📱 Single Device Login (harus logout di device lain)
- 📊 Pelaporan Retribusi Pajak
- 📝 History Pajak yang Sudah Dibayarkan
- 🏢 History Tempat Kerja
- 💰 Akumulasi Total Pajak
- 👤 Profile User

## 🏗️ Struktur Folder MVVM

```
lib/
├── main.dart                          # Entry point aplikasi
├── app/
│   ├── app.dart                       # Material App & routing
│   └── routes.dart                    # Definisi routes
│
├── core/                              # Core utilities & constants
│   ├── constants/
│   │   ├── api_constants.dart        # API endpoints
│   │   ├── app_constants.dart        # App constants
│   │   └── storage_keys.dart         # Keys untuk local storage
│   ├── utils/
│   │   ├── validators.dart           # Form validators
│   │   ├── date_formatter.dart       # Date utilities
│   │   └── currency_formatter.dart   # Format currency
│   └── services/
│       ├── api_service.dart          # HTTP client wrapper
│       ├── storage_service.dart      # Local storage (SharedPreferences)
│       ├── biometric_service.dart    # Fingerprint & Face ID
│       └── device_service.dart       # Device ID management
│
├── data/                              # Data Layer (API, Local DB)
│   ├── models/                        # Data models (dari API)
│   │   ├── user_model.dart
│   │   ├── tax_report_model.dart
│   │   ├── work_history_model.dart
│   │   └── device_info_model.dart
│   ├── repositories/                  # Repository implementations
│   │   ├── auth_repository.dart
│   │   ├── tax_repository.dart
│   │   └── profile_repository.dart
│   └── data_sources/                  # Remote/Local data sources
│       ├── remote/
│       │   ├── auth_remote_datasource.dart
│       │   ├── tax_remote_datasource.dart
│       │   └── profile_remote_datasource.dart
│       └── local/
│           └── auth_local_datasource.dart
│
├── domain/                            # Business Logic Layer
│   ├── entities/                      # Business entities
│   │   ├── user.dart
│   │   ├── tax_report.dart
│   │   └── work_history.dart
│   └── repositories/                  # Repository interfaces
│       ├── auth_repository_interface.dart
│       ├── tax_repository_interface.dart
│       └── profile_repository_interface.dart
│
└── presentation/                      # UI Layer (Views & ViewModels)
    ├── view_models/                   # ViewModels (State Management)
    │   ├── auth_view_model.dart
    │   ├── tax_view_model.dart
    │   ├── history_view_model.dart
    │   └── profile_view_model.dart
    │
    ├── views/                         # Screens/Pages
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   ├── register_screen.dart
    │   │   └── biometric_setup_screen.dart
    │   ├── home/
    │   │   └── home_screen.dart
    │   ├── tax/
    │   │   ├── tax_report_screen.dart
    │   │   └── tax_detail_screen.dart
    │   ├── history/
    │   │   ├── tax_history_screen.dart
    │   │   └── work_history_screen.dart
    │   └── profile/
    │       └── profile_screen.dart
    │
    └── widgets/                       # Reusable widgets
        ├── custom_button.dart
        ├── custom_text_field.dart
        ├── loading_indicator.dart
        └── tax_card.dart
```

## 🎯 MVVM Pattern Explanation

### 1. **Model** (Data Layer)
- Berisi data models dan repositories
- Handle API calls dan local storage
- Convert data dari JSON ke object Dart

### 2. **View** (Presentation Layer)
- UI components (Screens & Widgets)
- Menampilkan data dari ViewModel
- Mengirim user actions ke ViewModel

### 3. **ViewModel** (Business Logic)
- Bridge antara View dan Model
- Handle business logic
- Manage state dengan Provider/Riverpod
- Expose data ke View

## 🚀 Setup Project

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Setup Environment

Buat file `.env` di root project:

```env
API_BASE_URL=https://api.example.com/v1
API_TIMEOUT=30000
```

### 3. Setup iOS (untuk Face ID)

Edit `ios/Runner/Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Kami memerlukan Face ID untuk login aman</string>
```

### 4. Setup Android (untuk Fingerprint)

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

### 5. Run App

```bash
flutter run
```

## 📦 Dependencies Utama

- `provider` - State management
- `http` - HTTP client
- `shared_preferences` - Local storage
- `local_auth` - Biometric authentication
- `device_info_plus` - Device information
- `flutter_secure_storage` - Secure storage untuk token
- `intl` - Date & currency formatting

## 🔐 Authentication Flow

1. User input email & password
2. App cek apakah device sudah terdaftar
3. Jika device baru, cek apakah user sudah login di device lain
4. Jika ya, tampilkan error "Logout dulu di device sebelumnya"
5. Jika tidak, lakukan login dan simpan device ID
6. Simpan token ke secure storage
7. Enable biometric authentication (optional)

## 📊 Single Device Login Flow

```
Login Request
    ↓
Cek Device ID
    ↓
Server Check: Is another device logged in?
    ↓
    ├─ YES → Return Error: "Logout from other device first"
    │          Show device info (model, last login time)
    │
    └─ NO → Allow Login
            ↓
         Save Device ID to Server
            ↓
         Save Token & User Data Locally
            ↓
         Navigate to Home
```

## 📝 Cara Menambah Fitur Baru

### 1. Buat Model (Data Layer)

```dart
// data/models/new_feature_model.dart
class NewFeatureModel {
  final String id;
  final String name;
  
  NewFeatureModel({required this.id, required this.name});
  
  factory NewFeatureModel.fromJson(Map<String, dynamic> json) {
    return NewFeatureModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
```

### 2. Buat Entity (Domain Layer)

```dart
// domain/entities/new_feature.dart
class NewFeature {
  final String id;
  final String name;
  
  NewFeature({required this.id, required this.name});
}
```

### 3. Buat Repository

```dart
// data/repositories/new_feature_repository.dart
class NewFeatureRepository {
  Future<List<NewFeature>> getFeatures() async {
    // API call implementation
  }
}
```

### 4. Buat ViewModel

```dart
// presentation/view_models/new_feature_view_model.dart
class NewFeatureViewModel extends ChangeNotifier {
  List<NewFeature> features = [];
  
  Future<void> loadFeatures() async {
    // Load data from repository
    notifyListeners();
  }
}
```

### 5. Buat View

```dart
// presentation/views/new_feature_screen.dart
class NewFeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NewFeatureViewModel>(
      builder: (context, viewModel, child) {
        // Build UI
      },
    );
  }
}
```

## 🎨 Best Practices

1. **Separation of Concerns**: Setiap layer punya tanggung jawab sendiri
2. **Dependency Injection**: Gunakan Provider untuk inject dependencies
3. **Error Handling**: Selalu handle error dari API
4. **Loading States**: Tampilkan loading indicator saat fetch data
5. **Secure Storage**: Simpan token di flutter_secure_storage, bukan SharedPreferences
6. **Code Comments**: Setiap class & method ada komentar bahasa Indonesia

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test
```

## 📱 Platform Support

- ✅ Android (API 23+)
- ✅ iOS (12+)

## 👨‍💻 Team Structure (Recommended)

### Solo Developer
Kerjakan secara sequential:
1. Setup struktur & core services
2. Auth features
3. Main features (Tax, History)
4. Polish & testing

### Mini Team (2-3 orang)
- **Developer 1**: Core & Auth
- **Developer 2**: Tax & History Features
- **Developer 3**: UI/UX & Profile

## 📚 Learning Resources

- [Flutter MVVM Guide](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Local Auth Plugin](https://pub.dev/packages/local_auth)

## 🐛 Troubleshooting

### Biometric tidak berfungsi
- Pastikan device support biometric
- Check permissions di AndroidManifest.xml & Info.plist

### API Error 401
- Check apakah token masih valid
- Implement refresh token mechanism

---

**Happy Coding! 🚀**
