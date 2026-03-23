import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'api_service.dart';

/// 认证API服务
class AuthApiService {
  final ApiService _api = ApiService();

  /// 用户登录
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        debugPrint('Login response data: $responseData');
        debugPrint('Login response data type: ${responseData.runtimeType}');

        // 从响应中提取数据
        final innerData = responseData['data'] as Map<String, dynamic>?;
        debugPrint('Inner data: $innerData');

        if (innerData == null) {
          throw Exception('Login failed: No data in response');
        }

        // 保存token
        final accessToken = innerData['access_token'] as String? ?? innerData['accessToken'] as String?;
        final refreshToken = innerData['refresh_token'] as String? ?? innerData['refreshToken'] as String?;

        if (accessToken == null) {
          throw Exception('Login failed: No access token in response');
        }

        debugPrint('Access token: $accessToken');
        debugPrint('Refresh token: $refreshToken');
        debugPrint('Inner data keys: ${innerData.keys.toList()}');

        // 检查是否包含用户信息
        if (innerData.containsKey('user')) {
          debugPrint('User data found in login response: ${innerData['user']}');
        } else if (innerData.containsKey('id') || innerData.containsKey('username')) {
          debugPrint('User data is directly in innerData');
        } else {
          debugPrint('No user data in login response, will call getCurrentUser()');
        }

        _api.setTokens(accessToken, refreshToken);

        return responseData;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 用户注册
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // 使用公开请求，不包含token
      final response = await _api.postPublic(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 获取当前用户信息
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _api.get('/auth/me');

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('Get current user response: $data');
        debugPrint('Get current user response type: ${data.runtimeType}');

        // 检查响应结构,可能是 {data: {...user...}} 或直接用户数据
        if (data is Map && data.containsKey('data')) {
          debugPrint('User data found in "data" field');
          return data['data'] as Map<String, dynamic>;
        }
        if (data is Map && data.containsKey('user')) {
          debugPrint('User data found in "user" field');
          return data['user'] as Map<String, dynamic>;
        }
        // 否则直接返回数据
        return data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get user info: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 修改密码
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _api.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to change password: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 刷新token
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _api.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];
        _api.setTokens(newAccessToken, newRefreshToken);
        return newAccessToken;
      } else {
        throw Exception('Failed to refresh token: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } finally {
      _api.clearTokens();
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'An error occurred';
        return 'Error $statusCode: $message';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
