import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Device Service
/// Service untuk handle device information dan device ID management
/// Digunakan untuk single device login feature

class DeviceService {
  final DeviceInfoPlugin _deviceInfo;
  final StorageService _storageService;

  DeviceService({
    DeviceInfoPlugin? deviceInfo,
    required StorageService storageService,
  })  : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
        _storageService = storageService;

  // ====================
  // DEVICE ID
  // ====================

  /// Get atau generate device ID
  /// Device ID adalah unique identifier untuk device ini
  /// Digunakan untuk track device mana yang sedang login
  Future<String> getDeviceId() async {
    // Check apakah sudah ada device ID tersimpan
    final savedDeviceId = _storageService.getDeviceId();
    if (savedDeviceId != null) {
      return savedDeviceId;
    }

    // Generate device ID baru
    final deviceId = await _generateDeviceId();
    await _storageService.saveDeviceId(deviceId);
    return deviceId;
  }

  /// Generate device ID berdasarkan platform
  /// Android: menggunakan androidId
  /// iOS: menggunakan identifierForVendor
  /// Web/Desktop: menggunakan combination dari device info
  Future<String> _generateDeviceId() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      // Android ID adalah unique identifier per device
      return androidInfo.id; // androidId pada device_info_plus 9.x+
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      // identifierForVendor adalah unique per vendor (app developer)
      return iosInfo.identifierForVendor ?? _generateFallbackId();
    } else {
      // Fallback untuk platform lain (web, desktop)
      return _generateFallbackId();
    }
  }

  /// Generate fallback ID jika platform tidak support unique ID
  String _generateFallbackId() {
    // Generate random string
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString();
    return 'device_$random';
  }

  // ====================
  // DEVICE INFO
  // ====================

  /// Get device name/model
  /// Contoh: "iPhone 12 Pro", "Samsung Galaxy S21"
  Future<String> getDeviceName() async {
    // Check apakah sudah ada device name tersimpan
    final savedDeviceName = _storageService.getDeviceName();
    if (savedDeviceName != null) {
      return savedDeviceName;
    }

    // Get device name
    final deviceName = await _fetchDeviceName();
    await _storageService.saveDeviceName(deviceName);
    return deviceName;
  }

  /// Fetch device name dari device info
  Future<String> _fetchDeviceName() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      // Contoh: "Samsung SM-G991B" atau "Google Pixel 5"
      return '${androidInfo.manufacturer} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      // Contoh: "iPhone 12 Pro"
      return iosInfo.name;
    } else {
      return 'Unknown Device';
    }
  }

  /// Get full device information
  /// Return Map dengan detail device info
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceId = await getDeviceId();
    final deviceName = await getDeviceName();

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'platform': 'android',
        'osVersion': androidInfo.version.release,
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'platform': 'ios',
        'osVersion': iosInfo.systemVersion,
        'model': iosInfo.model,
        'name': iosInfo.name,
        'isPhysicalDevice': iosInfo.isPhysicalDevice,
      };
    } else {
      return {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'platform': kIsWeb ? 'web' : Platform.operatingSystem,
      };
    }
  }

  // ====================
  // DEVICE COMPATIBILITY
  // ====================

  /// Check apakah device adalah physical device (bukan emulator)
  Future<bool> isPhysicalDevice() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.isPhysicalDevice;
    }
    return true; // Assume true untuk platform lain
  }

  /// Get platform name
  /// Return: "android", "ios", "web", etc
  String getPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (kIsWeb) return 'web';
    return Platform.operatingSystem;
  }

  /// Get OS version
  Future<String> getOSVersion() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return 'iOS ${iosInfo.systemVersion}';
    }
    return 'Unknown';
  }

  // ====================
  // RESET DEVICE
  // ====================

  /// Reset device ID (generate new one)
  /// Digunakan saat logout atau clear data
  Future<String> resetDeviceId() async {
    final newDeviceId = await _generateDeviceId();
    await _storageService.saveDeviceId(newDeviceId);
    return newDeviceId;
  }
}
