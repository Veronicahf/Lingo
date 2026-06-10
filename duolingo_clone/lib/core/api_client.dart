import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([String message = 'No autorizado'])
    : super(message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([String message = 'Acceso prohibido'])
    : super(message, statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException([String message = 'Recurso no encontrado'])
    : super(message, statusCode: 404);
}

class ServerException extends ApiException {
  const ServerException([String message = 'Error interno del servidor'])
    : super(message, statusCode: 500);
}

class NetworkException extends ApiException {
  const NetworkException([String message = 'Error de red'])
    : super(message);
}

class ApiClient {
  ApiClient({Dio? dio})
    : _dio = dio ?? _createDio();

  ApiClient._internal() : _dio = _createDio();

  /// Instancia global compartida con el interceptor de Firebase configurado.
  static final ApiClient instance = ApiClient._internal();

  static const String _defaultBaseUrl = 'http://localhost:8080';

  final Dio _dio;

  static Dio _createDio() {
    // String.fromEnvironment solo puede usarse en un contexto const porque
    // evalúa variables de compilación (--dart-define) en tiempo de compilación.
    const baseUrl = String.fromEnvironment(
      'API_URL',
      defaultValue: _defaultBaseUrl,
    );

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(_ErrorInterceptor());

    return dio;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final token = await user.getIdToken();
        options.headers['Authorization'] = 'Bearer $token';
      } catch (_) {
      }
    }

    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final statusCode = err.response?.statusCode;

    switch (statusCode) {
      case 401:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: const UnauthorizedException(),
          ),
        );
      case 403:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: const ForbiddenException(),
          ),
        );
      case 404:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: const NotFoundException(),
          ),
        );
      case 500:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: const ServerException(),
          ),
        );
      default:
        if (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError) {
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              error: const NetworkException(),
            ),
          );
        } else {
          handler.next(err);
        }
    }
  }
}
