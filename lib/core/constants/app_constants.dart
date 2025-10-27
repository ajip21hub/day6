/// App Constants
/// File ini berisi konstanta umum yang digunakan di seluruh aplikasi

class AppConstants {
  // ====================
  // APP INFO
  // ====================
  
  static const String appName = 'Tax Retribution';
  static const String appVersion = '1.0.0';
  
  // ====================
  // PAGINATION
  // ====================
  
  /// Jumlah item per page untuk list
  static const int itemsPerPage = 20;
  
  /// Jumlah item untuk initial load
  static const int initialLoadCount = 10;

  // ====================
  // DATE FORMATS
  // ====================
  
  /// Format tanggal untuk display: 15 Jan 2024
  static const String displayDateFormat = 'dd MMM yyyy';
  
  /// Format tanggal lengkap: 15 Januari 2024
  static const String fullDateFormat = 'dd MMMM yyyy';
  
  /// Format tanggal untuk API: 2024-01-15
  static const String apiDateFormat = 'yyyy-MM-dd';
  
  /// Format waktu: 14:30
  static const String timeFormat = 'HH:mm';
  
  /// Format tanggal dan waktu: 15 Jan 2024, 14:30
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';

  // ====================
  // CURRENCY
  // ====================
  
  /// Symbol mata uang
  static const String currencySymbol = 'Rp';
  
  /// Locale untuk format currency Indonesia
  static const String currencyLocale = 'id_ID';

  // ====================
  // VALIDATION
  // ====================
  
  /// Minimum panjang password
  static const int minPasswordLength = 8;
  
  /// Maximum panjang password
  static const int maxPasswordLength = 50;
  
  /// Regex pattern untuk email validation
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  /// Regex pattern untuk phone number Indonesia
  static const String phonePattern = r'^(^\+62|62|^08)(\d{3,4}-?){2}\d{3,4}$';

  // ====================
  // BIOMETRIC
  // ====================
  
  /// Reason untuk biometric authentication (ditampilkan di dialog)
  static const String biometricReason = 'Autentikasi untuk login';
  
  /// Title untuk biometric dialog iOS
  static const String biometricTitle = 'Verifikasi Identitas';
  
  /// Cancel button text untuk biometric
  static const String biometricCancelButton = 'Batal';

  // ====================
  // ERROR MESSAGES
  // ====================
  
  /// Error message untuk network error
  static const String networkError = 'Tidak ada koneksi internet';
  
  /// Error message untuk timeout
  static const String timeoutError = 'Request timeout. Silakan coba lagi';
  
  /// Error message untuk server error
  static const String serverError = 'Terjadi kesalahan pada server';
  
  /// Error message untuk unauthorized
  static const String unauthorizedError = 'Sesi Anda telah berakhir. Silakan login kembali';
  
  /// Error message untuk device already logged in
  static const String deviceLoggedInError = 'Akun Anda sedang login di device lain. Silakan logout terlebih dahulu';

  // ====================
  // SUCCESS MESSAGES
  // ====================
  
  static const String loginSuccess = 'Login berhasil';
  static const String logoutSuccess = 'Logout berhasil';
  static const String updateProfileSuccess = 'Profile berhasil diperbarui';
  static const String createReportSuccess = 'Laporan berhasil dibuat';

  // ====================
  // CACHE DURATION
  // ====================
  
  /// Durasi cache dalam menit
  static const int cacheDurationMinutes = 30;
  
  /// Durasi cache untuk profile (lebih lama)
  static const int profileCacheDurationMinutes = 60;

  // ====================
  // ANIMATION DURATION
  // ====================
  
  /// Durasi animasi standar (ms)
  static const int standardAnimationDuration = 300;
  
  /// Durasi animasi cepat (ms)
  static const int fastAnimationDuration = 150;
  
  /// Durasi animasi lambat (ms)
  static const int slowAnimationDuration = 500;
}
