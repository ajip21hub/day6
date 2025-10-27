/// Storage Keys
/// File ini berisi semua key yang digunakan untuk local storage
/// Memudahkan untuk avoid typo dan maintain keys

class StorageKeys {
  // ====================
  // SECURE STORAGE KEYS (untuk flutter_secure_storage)
  // ====================
  // Keys ini digunakan untuk data sensitif yang dienkripsi
  
  /// Key untuk menyimpan access token
  static const String accessToken = 'access_token';
  
  /// Key untuk menyimpan refresh token
  static const String refreshToken = 'refresh_token';
  
  /// Key untuk menyimpan biometric credential
  /// Digunakan untuk login dengan fingerprint/face ID
  static const String biometricCredential = 'biometric_credential';

  // ====================
  // SHARED PREFERENCES KEYS
  // ====================
  // Keys ini digunakan untuk data non-sensitif
  
  /// Key untuk flag apakah user sudah login
  static const String isLoggedIn = 'is_logged_in';
  
  /// Key untuk menyimpan data user (JSON string)
  static const String userData = 'user_data';
  
  /// Key untuk menyimpan device ID
  static const String deviceId = 'device_id';
  
  /// Key untuk menyimpan device name
  static const String deviceName = 'device_name';
  
  /// Key untuk flag apakah biometric sudah di-enable
  static const String isBiometricEnabled = 'is_biometric_enabled';
  
  /// Key untuk flag apakah ini first launch
  static const String isFirstLaunch = 'is_first_launch';
  
  /// Key untuk theme mode (light/dark)
  static const String themeMode = 'theme_mode';
  
  /// Key untuk language preference
  static const String language = 'language';
  
  /// Key untuk menyimpan terakhir kali sync data
  static const String lastSyncTime = 'last_sync_time';

  // ====================
  // CACHE KEYS
  // ====================
  // Keys untuk cache temporary data
  
  /// Key untuk cache list tax reports
  static const String cachedTaxReports = 'cached_tax_reports';
  
  /// Key untuk cache work history
  static const String cachedWorkHistory = 'cached_work_history';
  
  /// Key untuk cache profile
  static const String cachedProfile = 'cached_profile';
  
  /// Key untuk cache tax accumulation
  static const String cachedTaxAccumulation = 'cached_tax_accumulation';
}
