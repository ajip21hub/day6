import '../../../core/services/storage_service.dart';
import '../../models/user_model.dart';

/// Auth Local Data Source
/// Handle caching dan local storage untuk authentication
/// Layer ini bertanggung jawab untuk menyimpan data user secara lokal

class AuthLocalDataSource {
  final StorageService storageService;

  AuthLocalDataSource({required this.storageService});

  // ====================
  // USER DATA
  // ====================

  /// Save user data ke local storage (SharedPreferences)
  /// Data disimpan sebagai JSON string
  Future<void> saveUser(UserModel user) async {
    await storageService.saveUserData(user.toJson());
  }

  /// Get cached user data dari local storage
  /// Return null jika tidak ada user tersimpan
  UserModel? getCachedUser() {
    final userData = storageService.getUserData();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  /// Delete user data dari local storage
  Future<void> deleteUser() async {
    await storageService.deleteUserData();
  }

  // ====================
  // TOKENS
  // ====================

  /// Save tokens ke secure storage (encrypted)
  /// PENTING: Token disimpan di secure storage, bukan SharedPreferences
  /// untuk keamanan yang lebih baik
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await storageService.saveAccessToken(accessToken);
    await storageService.saveRefreshToken(refreshToken);
  }

  /// Get access token dari secure storage
  Future<String?> getAccessToken() async {
    return await storageService.getAccessToken();
  }

  /// Get refresh token dari secure storage
  Future<String?> getRefreshToken() async {
    return await storageService.getRefreshToken();
  }

  /// Delete tokens dari secure storage
  Future<void> deleteTokens() async {
    await storageService.deleteAccessToken();
    await storageService.deleteRefreshToken();
  }

  // ====================
  // LOGIN STATUS
  // ====================

  /// Set login status
  /// Flag untuk cek apakah user sudah login atau belum
  Future<void> setLoggedIn(bool status) async {
    await storageService.setLoggedIn(status);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return storageService.isLoggedIn();
  }

  // ====================
  // BIOMETRIC CREDENTIALS
  // ====================

  /// Save biometric credentials untuk auto-login
  /// Credential adalah hash dari email+password yang encrypted
  /// Hanya disimpan jika user enable biometric login
  Future<void> saveBiometricCredential(String credential) async {
    await storageService.saveBiometricCredential(credential);
  }

  /// Get biometric credentials
  Future<String?> getBiometricCredential() async {
    return await storageService.getBiometricCredential();
  }

  /// Delete biometric credentials
  Future<void> deleteBiometricCredential() async {
    await storageService.deleteBiometricCredential();
  }

  /// Check if biometric is enabled
  bool isBiometricEnabled() {
    return storageService.isBiometricEnabled();
  }

  /// Set biometric enabled status
  Future<void> setBiometricEnabled(bool enabled) async {
    await storageService.setBiometricEnabled(enabled);
  }

  // ====================
  // CLEAR ALL
  // ====================

  /// Clear all auth data (logout)
  /// Hapus user data, tokens, dan biometric credentials
  Future<void> clearAuthData() async {
    await storageService.clearAll();
  }
}
