import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

/// Storage Service
/// Service untuk handle local storage (SharedPreferences & Secure Storage)
/// - SharedPreferences: untuk data non-sensitif
/// - FlutterSecureStorage: untuk data sensitif (token, credentials)

class StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  StorageService({
    required SharedPreferences prefs,
    FlutterSecureStorage? secureStorage,
  })  : _prefs = prefs,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ====================
  // SECURE STORAGE (untuk data sensitif)
  // ====================

  /// Save access token (encrypted)
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(
      key: StorageKeys.accessToken,
      value: token,
    );
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: StorageKeys.accessToken);
  }

  /// Delete access token
  Future<void> deleteAccessToken() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
  }

  /// Save refresh token (encrypted)
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: StorageKeys.refreshToken,
      value: token,
    );
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: StorageKeys.refreshToken);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: StorageKeys.refreshToken);
  }

  /// Save biometric credentials (email/password hash)
  /// Digunakan untuk auto-login dengan biometric
  Future<void> saveBiometricCredential(String credential) async {
    await _secureStorage.write(
      key: StorageKeys.biometricCredential,
      value: credential,
    );
  }

  /// Get biometric credentials
  Future<String?> getBiometricCredential() async {
    return await _secureStorage.read(key: StorageKeys.biometricCredential);
  }

  /// Delete biometric credentials
  Future<void> deleteBiometricCredential() async {
    await _secureStorage.delete(key: StorageKeys.biometricCredential);
  }

  // ====================
  // SHARED PREFERENCES (untuk data non-sensitif)
  // ====================

  // --- Boolean ---

  /// Set login status
  Future<void> setLoggedIn(bool isLoggedIn) async {
    await _prefs.setBool(StorageKeys.isLoggedIn, isLoggedIn);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  /// Set biometric enabled status
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(StorageKeys.isBiometricEnabled, enabled);
  }

  /// Check if biometric is enabled
  bool isBiometricEnabled() {
    return _prefs.getBool(StorageKeys.isBiometricEnabled) ?? false;
  }

  /// Set first launch flag
  Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs.setBool(StorageKeys.isFirstLaunch, isFirst);
  }

  /// Check if this is first launch
  bool isFirstLaunch() {
    return _prefs.getBool(StorageKeys.isFirstLaunch) ?? true;
  }

  // --- String ---

  /// Save user data as JSON string
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(StorageKeys.userData, jsonEncode(userData));
  }

  /// Get user data
  Map<String, dynamic>? getUserData() {
    final userDataString = _prefs.getString(StorageKeys.userData);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  /// Delete user data
  Future<void> deleteUserData() async {
    await _prefs.remove(StorageKeys.userData);
  }

  /// Save device ID
  Future<void> saveDeviceId(String deviceId) async {
    await _prefs.setString(StorageKeys.deviceId, deviceId);
  }

  /// Get device ID
  String? getDeviceId() {
    return _prefs.getString(StorageKeys.deviceId);
  }

  /// Save device name
  Future<void> saveDeviceName(String deviceName) async {
    await _prefs.setString(StorageKeys.deviceName, deviceName);
  }

  /// Get device name
  String? getDeviceName() {
    return _prefs.getString(StorageKeys.deviceName);
  }

  /// Save theme mode
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(StorageKeys.themeMode, themeMode);
  }

  /// Get theme mode
  String getThemeMode() {
    return _prefs.getString(StorageKeys.themeMode) ?? 'system';
  }

  // --- Cache Management ---

  /// Save cache with expiry time
  Future<void> saveCache(String key, Map<String, dynamic> data,
      {int durationMinutes = 30}) async {
    final cacheData = {
      'data': data,
      'expiry': DateTime.now()
          .add(Duration(minutes: durationMinutes))
          .toIso8601String(),
    };
    await _prefs.setString(key, jsonEncode(cacheData));
  }

  /// Get cache (returns null if expired)
  Map<String, dynamic>? getCache(String key) {
    final cacheString = _prefs.getString(key);
    if (cacheString == null) return null;

    try {
      final cacheData = jsonDecode(cacheString);
      final expiry = DateTime.parse(cacheData['expiry']);

      // Check if cache expired
      if (DateTime.now().isAfter(expiry)) {
        _prefs.remove(key); // Remove expired cache
        return null;
      }

      return cacheData['data'];
    } catch (e) {
      return null;
    }
  }

  /// Clear specific cache
  Future<void> clearCache(String key) async {
    await _prefs.remove(key);
  }

  // ====================
  // CLEAR ALL DATA
  // ====================

  /// Clear all data (logout)
  /// Hapus semua tokens, user data, dan cache
  Future<void> clearAll() async {
    // Clear secure storage
    await _secureStorage.deleteAll();

    // Clear selected shared preferences
    await _prefs.remove(StorageKeys.isLoggedIn);
    await _prefs.remove(StorageKeys.userData);
    await _prefs.remove(StorageKeys.cachedTaxReports);
    await _prefs.remove(StorageKeys.cachedWorkHistory);
    await _prefs.remove(StorageKeys.cachedProfile);
    await _prefs.remove(StorageKeys.cachedTaxAccumulation);

    // Keep device ID, biometric settings, dan theme preferences
  }

  /// Clear all cache only
  Future<void> clearAllCache() async {
    await _prefs.remove(StorageKeys.cachedTaxReports);
    await _prefs.remove(StorageKeys.cachedWorkHistory);
    await _prefs.remove(StorageKeys.cachedProfile);
    await _prefs.remove(StorageKeys.cachedTaxAccumulation);
  }
}
