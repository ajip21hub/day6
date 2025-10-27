/// API Constants
/// File ini berisi semua endpoint API yang digunakan dalam aplikasi
/// Memudahkan untuk maintain dan update API endpoints

class ApiConstants {
  // Base URL - sebaiknya diambil dari environment variable
  static const String baseUrl = 'https://api.example.com/v1';
  
  // Timeout untuk HTTP requests (dalam detik)
  static const int timeoutDuration = 30;

  // ====================
  // AUTH ENDPOINTS
  // ====================
  
  /// Endpoint untuk login user
  /// POST /auth/login
  /// Body: {email, password, deviceId}
  static const String login = '/auth/login';
  
  /// Endpoint untuk register user baru
  /// POST /auth/register
  /// Body: {name, email, password, phone}
  static const String register = '/auth/register';
  
  /// Endpoint untuk logout
  /// POST /auth/logout
  /// Body: {deviceId}
  static const String logout = '/auth/logout';
  
  /// Endpoint untuk refresh token
  /// POST /auth/refresh
  static const String refreshToken = '/auth/refresh';
  
  /// Endpoint untuk check device login status
  /// GET /auth/device-status?deviceId=xxx
  static const String deviceStatus = '/auth/device-status';

  // ====================
  // TAX ENDPOINTS
  // ====================
  
  /// Endpoint untuk mendapatkan list laporan pajak
  /// GET /tax/reports
  static const String taxReports = '/tax/reports';
  
  /// Endpoint untuk mendapatkan detail laporan pajak
  /// GET /tax/reports/:id
  static String taxReportDetail(String id) => '/tax/reports/$id';
  
  /// Endpoint untuk submit laporan pajak baru
  /// POST /tax/reports
  /// Body: {workplaceId, amount, period, description}
  static const String createTaxReport = '/tax/reports';
  
  /// Endpoint untuk mendapatkan total akumulasi pajak
  /// GET /tax/accumulation
  static const String taxAccumulation = '/tax/accumulation';

  // ====================
  // WORK HISTORY ENDPOINTS
  // ====================
  
  /// Endpoint untuk mendapatkan history tempat kerja
  /// GET /work-history
  static const String workHistory = '/work-history';
  
  /// Endpoint untuk mendapatkan detail tempat kerja
  /// GET /work-history/:id
  static String workHistoryDetail(String id) => '/work-history/$id';
  
  /// Endpoint untuk menambah tempat kerja baru
  /// POST /work-history
  /// Body: {companyName, position, startDate, endDate, salary}
  static const String createWorkHistory = '/work-history';

  // ====================
  // PROFILE ENDPOINTS
  // ====================
  
  /// Endpoint untuk mendapatkan profile user
  /// GET /profile
  static const String profile = '/profile';
  
  /// Endpoint untuk update profile
  /// PUT /profile
  /// Body: {name, phone, address, etc}
  static const String updateProfile = '/profile';
  
  /// Endpoint untuk update foto profile
  /// POST /profile/photo
  /// Body: multipart/form-data
  static const String updateProfilePhoto = '/profile/photo';

  // ====================
  // HELPER METHODS
  // ====================
  
  /// Helper untuk generate full URL
  /// Contoh: getFullUrl('/auth/login') -> 'https://api.example.com/v1/auth/login'
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
