import 'package:dio/dio.dart';

/// API配置和基础服务类
class ApiService {
  static const String _baseUrl = 'https://bulletinapi.rindra.org/api/v1';
  
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  Dio get dio => _dio;

  /// 初始化Dio实例
  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加拦截器用于自动添加token和处理错误
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401 && _refreshToken != null) {
          // Token过期，尝试刷新
          _refreshTokenAndRetry(error, handler);
        } else {
          return handler.next(error);
        }
      },
    ));
  }

  /// 设置认证token
  void setTokens(String accessToken, String? refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  /// 清除认证token
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  /// 刷新token并重试请求
  Future<void> _refreshTokenAndRetry(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': _refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];
        setTokens(newAccessToken, newRefreshToken);

        // 重试原请求
        final options = error.requestOptions;
        options.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(options);
        return handler.resolve(retryResponse);
      }
    } catch (e) {
      // 刷新失败，清除token
      clearTokens();
    }
    return handler.next(error);
  }

  /// GET请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters, options: options);
  }

  /// POST请求
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT请求
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE请求
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
