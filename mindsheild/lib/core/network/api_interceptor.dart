import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import '../services/token_service.dart';

/// Centralized HTTP error interceptor for Dio.
///
/// Maps every server error status code to a typed [AppException]
/// so feature code never deals with raw status codes or DioExceptions.
/// This is the single place where error → exception mapping happens
/// (Single Responsibility Principle).
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Attach auth token if available
    final token = TokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final AppException exception = _mapDioError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: exception,
        type: err.type,
      ),
    );
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check response status codes that Dio considers "valid" (< 500)
    // but still represent errors (4xx)
    if (response.statusCode != null && response.statusCode! >= 400) {
      final exception = _mapStatusCode(
        response.statusCode!,
        _extractMessage(response.data),
      );
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: exception,
        ),
      );
      return;
    }
    handler.next(response);
  }

  // ─── Private Helpers ────────────────────────────────────────

  AppException _mapDioError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final message = _extractMessage(err.response?.data);
        return _mapStatusCode(statusCode, message);

      default:
        return const ServerException(message: 'خطای نامشخص رخ داد');
    }
  }

  AppException _mapStatusCode(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        return ServerException(message: message, statusCode: 400);
      case 401:
        return const UnauthorizedException();
      case 403:
        return const ForbiddenException();
      case 404:
        return const NotFoundException();
      case 409:
        return ServerException(message: message, statusCode: 409);
      case 422:
        return ServerException(message: message, statusCode: 422);
      case 500:
      case 502:
      case 503:
        return ServerException(
          message: 'خطای سرور، لطفاً بعداً تلاش کنید',
          statusCode: statusCode,
        );
      default:
        return ServerException(message: message, statusCode: statusCode);
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'] ?? 'خطای سرور') as String;
    }
    if (data is String && data.isNotEmpty) return data;
    return 'خطای سرور، لطفاً بعداً تلاش کنید';
  }
}

/// Logging interceptor for debug builds.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('┌─── REQUEST ───');
    // ignore: avoid_print
    print('│ ${options.method} ${options.uri}');
    // ignore: avoid_print
    print('│ Headers: ${options.headers}');
    // ignore: avoid_print
    print('│ Body: ${options.data}');
    // ignore: avoid_print
    print('└───────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('┌─── RESPONSE ───');
    // ignore: avoid_print
    print('│ ${response.statusCode} ${response.requestOptions.uri}');
    // ignore: avoid_print
    print('│ Data: ${response.data}');
    // ignore: avoid_print
    print('└────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('┌─── ERROR ───');
    // ignore: avoid_print
    print('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
    // ignore: avoid_print
    print('│ Error: ${err.error}');
    // ignore: avoid_print
    print('│ Message: ${err.message}');
    // ignore: avoid_print
    print('└──────────────');
    handler.next(err);
  }
}
