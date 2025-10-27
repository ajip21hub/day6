import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import '../constants/app_constants.dart';

/// Biometric Service
/// Service untuk handle biometric authentication (Fingerprint & Face ID)
/// Support Android fingerprint dan iOS Face ID / Touch ID

class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  // ====================
  // CHECK CAPABILITIES
  // ====================

  /// Check apakah device support biometric
  /// Return true jika device punya hardware biometric
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Check apakah device support dan ada biometric yang ter-enroll
  /// Return true jika user sudah setup fingerprint/face ID
  Future<bool> isDeviceSupported() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types pada device
  /// Return list of BiometricType (fingerprint, face, iris, weak, strong)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Get string deskripsi untuk available biometrics
  /// Contoh: "Fingerprint", "Face ID", "Touch ID"
  Future<String> getBiometricTypeDescription() async {
    final types = await getAvailableBiometrics();
    
    if (types.isEmpty) {
      return 'Tidak ada biometric tersedia';
    }

    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.strong) || 
               types.contains(BiometricType.weak)) {
      return 'Biometric';
    }

    return 'Biometric';
  }

  // ====================
  // AUTHENTICATION
  // ====================

  /// Authenticate dengan biometric
  /// Return true jika authentication berhasil
  /// 
  /// Parameters:
  /// - localizedReason: Pesan yang ditampilkan ke user
  /// - useErrorDialogs: Tampilkan error dialog jika auth gagal
  /// - stickyAuth: Keep auth session tetap active
  /// 
  /// Contoh:
  /// ```dart
  /// final success = await biometricService.authenticate(
  ///   localizedReason: 'Login ke aplikasi',
  /// );
  /// ```
  Future<BiometricResult> authenticate({
    String? localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Check apakah biometric available
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return BiometricResult(
          success: false,
          errorType: BiometricErrorType.notAvailable,
          message: 'Biometric tidak tersedia pada device ini',
        );
      }

      // Authenticate
      final authenticated = await _localAuth.authenticate(
        localizedReason:
            localizedReason ?? AppConstants.biometricReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true, // Hanya pakai biometric, tidak pakai PIN/pattern
        ),
      );

      if (authenticated) {
        return BiometricResult(
          success: true,
          message: 'Authentication berhasil',
        );
      } else {
        return BiometricResult(
          success: false,
          errorType: BiometricErrorType.authFailed,
          message: 'Authentication gagal',
        );
      }
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return BiometricResult(
        success: false,
        errorType: BiometricErrorType.unknown,
        message: 'Error: $e',
      );
    }
  }

  /// Stop authentication (cancel)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      // Ignore error
    }
  }

  // ====================
  // ERROR HANDLING
  // ====================

  /// Handle PlatformException dari local_auth
  BiometricResult _handlePlatformException(PlatformException e) {
    BiometricErrorType errorType;
    String message;

    switch (e.code) {
      case auth_error.notAvailable:
        errorType = BiometricErrorType.notAvailable;
        message = 'Biometric tidak tersedia';
        break;
      case auth_error.notEnrolled:
        errorType = BiometricErrorType.notEnrolled;
        message = 'Tidak ada biometric terdaftar. Silakan setup di Settings.';
        break;
      case auth_error.lockedOut:
        errorType = BiometricErrorType.lockedOut;
        message = 'Terlalu banyak percobaan gagal. Coba lagi nanti.';
        break;
      case auth_error.permanentlyLockedOut:
        errorType = BiometricErrorType.permanentlyLockedOut;
        message = 'Biometric dikunci permanent. Gunakan PIN/password.';
        break;
      case auth_error.passcodeNotSet:
        errorType = BiometricErrorType.passcodeNotSet;
        message = 'Silakan setup PIN/password device terlebih dahulu.';
        break;
      default:
        errorType = BiometricErrorType.unknown;
        message = e.message ?? 'Terjadi kesalahan';
    }

    return BiometricResult(
      success: false,
      errorType: errorType,
      message: message,
    );
  }
}

// ====================
// BIOMETRIC RESULT
// ====================

/// Result object dari biometric authentication
class BiometricResult {
  final bool success;
  final BiometricErrorType? errorType;
  final String message;

  BiometricResult({
    required this.success,
    this.errorType,
    required this.message,
  });
}

/// Enum untuk biometric error types
enum BiometricErrorType {
  notAvailable,       // Biometric hardware tidak ada
  notEnrolled,        // User belum setup biometric
  lockedOut,          // Temporary locked karena terlalu banyak fail
  permanentlyLockedOut, // Permanent locked
  passcodeNotSet,     // Device PIN/password belum diset
  authFailed,         // Authentication gagal (user cancel atau tidak cocok)
  unknown,            // Unknown error
}
