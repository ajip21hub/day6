import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

/// API Service
/// Service untuk handle semua HTTP requests ke backend
/// Includes automatic token injection, error handling, dan retry logic

class ApiService {
  final StorageService _storageService;
  final http.Client _client;

  ApiService({
    required StorageService storageService,
    http.Client? client,
  })  : _storageService = storageService,
        _client = client ?? http.Client();

  // ====================
  // HTTP METHODS
  // ====================

  /// GET Request
  /// Contoh: await apiService.get('/tax/reports');
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = await _buildHeaders(requiresAuth);

      final response = await _client
          .get(uri, headers: headers)
          .timeout(Duration(seconds: ApiConstants.timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST Request
  /// Contoh: await apiService.post('/auth/login', body: {'email': 'user@mail.com'});
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _buildHeaders(requiresAuth);

      final response = await _client
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: ApiConstants.timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT Request
  /// Contoh: await apiService.put('/profile', body: {'name': 'John Doe'});
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _buildHeaders(requiresAuth);

      final response = await _client
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: ApiConstants.timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE Request
  /// Contoh: await apiService.delete('/tax/reports/123');
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _buildHeaders(requiresAuth);

      final response = await _client
          .delete(uri, headers: headers)
          .timeout(Duration(seconds: ApiConstants.timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ====================
  // HELPER METHODS
  // ====================

  /// Build URI dengan base URL dan query parameters
  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final url = ApiConstants.getFullUrl(endpoint);
    final uri = Uri.parse(url);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }

    return uri;
  }

  /// Build headers dengan automatic token injection
  Future<Map<String, String>> _buildHeaders(bool requiresAuth) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add token jika requires authentication
    if (requiresAuth) {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle HTTP response
  /// Convert response ke Map dan handle error codes
  Map<String, dynamic> _handleResponse(http.Response response) {
    // Success responses (200-299)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body);
    }

    // Error responses
    final errorBody = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {'message': 'Unknown error'};

    switch (response.statusCode) {
      case 400:
        throw ApiException('Bad Request: ${errorBody['message']}');
      case 401:
        throw UnauthorizedException(
            errorBody['message'] ?? AppConstants.unauthorizedError);
      case 403:
        throw ApiException('Forbidden: ${errorBody['message']}');
      case 404:
        throw ApiException('Not Found: ${errorBody['message']}');
      case 409:
        // Conflict - untuk device already logged in
        throw DeviceConflictException(
            errorBody['message'] ?? AppConstants.deviceLoggedInError,
            deviceInfo: errorBody['deviceInfo']);
      case 422:
        throw ValidationException(
            errorBody['message'] ?? 'Validation error',
            errors: errorBody['errors']);
      case 500:
        throw ServerException(
            errorBody['message'] ?? AppConstants.serverError);
      default:
        throw ApiException(
            'Error ${response.statusCode}: ${errorBody['message']}');
    }
  }

  /// Handle errors dari network atau timeout
  Exception _handleError(dynamic error) {
    if (error is SocketException) {
      return NetworkException(AppConstants.networkError);
    } else if (error is TimeoutException) {
      return TimeoutException(AppConstants.timeoutError);
    } else if (error is ApiException) {
      return error;
    } else {
      return ApiException('Unexpected error: $error');
    }
  }

  /// Close HTTP client
  void dispose() {
    _client.close();
  }
}

// ====================
// CUSTOM EXCEPTIONS
// ====================

/// Base exception untuk API errors
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

/// Exception untuk network errors (no internet)
class NetworkException extends ApiException {
  NetworkException(super.message);
}

/// Exception untuk timeout
class TimeoutException extends ApiException {
  TimeoutException(super.message);
}

/// Exception untuk unauthorized (401)
/// Trigger auto logout
class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

/// Exception untuk server errors (500)
class ServerException extends ApiException {
  ServerException(super.message);
}

/// Exception untuk device conflict (409)
/// User sudah login di device lain
class DeviceConflictException extends ApiException {
  final Map<String, dynamic>? deviceInfo;

  DeviceConflictException(super.message, {this.deviceInfo});
}

/// Exception untuk validation errors (422)
/// Berisi field-specific errors
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException(super.message, {this.errors});
}
