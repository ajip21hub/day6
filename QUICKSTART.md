# 🚀 Quick Start Guide

## 5 Menit untuk Running App

### Step 1: Install Dependencies (1 menit)
```bash
flutter pub get
```

### Step 2: Run App (1 menit)
```bash
flutter run
```
Pilih device (Chrome/iOS/Android)

### Step 3: Test App (3 menit)

#### Test Register:
1. Tap "Daftar Akun Baru"
2. Isi form (nama, email, phone, password)
3. Tap "Daftar"
4. ✅ Auto login ke Home

#### Test Login:
1. Logout dari Home
2. Input email & password yang tadi
3. Tap "Login"  
4. ✅ Masuk ke Home

#### Test Biometric (jika di real device):
1. Login dulu
2. Di Home, tap "Aktifkan" biometric
3. Authenticate dengan fingerprint
4. Logout
5. Tap "Login dengan Biometric"
6. ✅ Auto login

---

## 📖 Dokumentasi Lengkap

1. **README.md** - Overview & struktur
2. **STUDY_GUIDE.md** - Pembelajaran step-by-step
3. **IMPLEMENTATION_GUIDE.md** - Cara tambah fitur baru
4. **PROJECT_COMPLETE.md** - Summary lengkap

---

## 🎯 Files Penting

### Ubah API URL:
```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'https://your-api.com/v1';
```

### Tambah Fitur Baru:
Follow pattern di `IMPLEMENTATION_GUIDE.md`

---

## ⚡ Cheat Sheet

### Architecture Layers:
```
View → ViewModel → Repository → DataSource → API
     ←            ←            ←             ←
```

### Folder Structure:
```
lib/
├── core/         # Constants, Utils, Services
├── domain/       # Entities (Business objects)
├── data/         # Models, Repositories, DataSources
└── presentation/ # ViewModels, Views
```

### Add New Feature:
1. Create Entity (domain/entities/)
2. Create Model (data/models/)
3. Create DataSource (data/data_sources/)
4. Create Repository (data/repositories/)
5. Create ViewModel (presentation/view_models/)
6. Create View (presentation/views/)

---

## 🐛 Common Issues

**Error: Biometric not working**
→ Test di real device, bukan emulator

**Error: API call failed**  
→ Update API URL di `api_constants.dart`

**Error: Build failed**
→ Run `flutter clean && flutter pub get`

---

**Happy Coding! 🎉**
