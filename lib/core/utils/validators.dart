import '../constants/app_constants.dart';

/// Validators
/// Class ini berisi semua fungsi validasi untuk form input
/// Memudahkan untuk validasi yang konsisten di seluruh aplikasi

class Validators {
  // ====================
  // EMAIL VALIDATION
  // ====================
  
  /// Validasi email
  /// Return null jika valid, return error message jika tidak valid
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    // Check apakah format email valid
    final emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  // ====================
  // PASSWORD VALIDATION
  // ====================
  
  /// Validasi password
  /// Cek minimal length dan karakter yang dibutuhkan
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password minimal ${AppConstants.minPasswordLength} karakter';
    }
    
    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password maksimal ${AppConstants.maxPasswordLength} karakter';
    }
    
    // Optional: Cek apakah password mengandung minimal 1 huruf dan 1 angka
    if (!value.contains(RegExp(r'[A-Za-z]'))) {
      return 'Password harus mengandung minimal 1 huruf';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung minimal 1 angka';
    }
    
    return null;
  }

  /// Validasi confirm password
  /// Cek apakah password dan confirm password sama
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    
    if (value != password) {
      return 'Password tidak sama';
    }
    
    return null;
  }

  // ====================
  // PHONE VALIDATION
  // ====================
  
  /// Validasi nomor telepon Indonesia
  /// Format: 08xx-xxxx-xxxx atau +62xx-xxxx-xxxx
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    
    // Remove spaces dan dashes
    String cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check minimum length
    if (cleanPhone.length < 10) {
      return 'Nomor telepon terlalu pendek';
    }
    
    // Check apakah format valid
    final phoneRegex = RegExp(AppConstants.phonePattern);
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Format nomor telepon tidak valid';
    }
    
    return null;
  }

  // ====================
  // REQUIRED FIELD VALIDATION
  // ====================
  
  /// Validasi field yang wajib diisi
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  // ====================
  // NUMERIC VALIDATION
  // ====================
  
  /// Validasi input harus angka
  static String? numeric(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName harus berupa angka';
    }
    
    return null;
  }

  /// Validasi angka dengan minimum value
  static String? minValue(String? value, double min, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName harus berupa angka';
    }
    
    if (number < min) {
      return '$fieldName minimal $min';
    }
    
    return null;
  }

  /// Validasi angka dengan maximum value
  static String? maxValue(String? value, double max, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName harus berupa angka';
    }
    
    if (number > max) {
      return '$fieldName maksimal $max';
    }
    
    return null;
  }

  // ====================
  // LENGTH VALIDATION
  // ====================
  
  /// Validasi minimum length
  static String? minLength(String? value, int min, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    if (value.length < min) {
      return '$fieldName minimal $min karakter';
    }
    
    return null;
  }

  /// Validasi maximum length
  static String? maxLength(String? value, int max, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    if (value.length > max) {
      return '$fieldName maksimal $max karakter';
    }
    
    return null;
  }

  // ====================
  // CUSTOM VALIDATION
  // ====================
  
  /// Helper untuk combine multiple validators
  /// Contoh: Validators.combine([Validators.required, Validators.email])
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result; // Return error pertama yang ditemukan
        }
      }
      return null; // Semua validasi passed
    };
  }
}
