import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../shared/services/storage_service.dart';

class DioService {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_AuthInterceptor(dio));

    return dio;
  }
}

// ─── Auth Interceptor ─────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final Dio _dio;

  _AuthInterceptor(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuthInterceptor'] == true) {
      return handler.next(options);
    }

    final token = await StorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If refresh request itself fails, do not try to refresh again.
    if (err.requestOptions.extra['skipAuthInterceptor'] == true) {
      await StorageService.clearAuth();
      return handler.next(err);
    }

    // Auto-refresh on 401 Unauthorized
    if (err.response?.statusCode == 401) {
      final refreshToken = await StorageService.getRefreshToken();

      if (refreshToken != null) {
        try {
          final response = await _dio.post(
            ApiConstants.refreshToken,
            data: {'refreshToken': refreshToken},
            options: Options(
              extra: {'skipAuthInterceptor': true},
            ),
          );

          final newAccessToken = response.data['data']['accessToken'] as String;
          final newRefreshToken = response.data['data']['refreshToken'] as String;

          await StorageService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          // Retry the original request with the new token
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await _dio.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          // Refresh failed — clear auth and let the error propagate
          await StorageService.clearAuth();
        }
      }
    }

    handler.next(err);
  }
}
