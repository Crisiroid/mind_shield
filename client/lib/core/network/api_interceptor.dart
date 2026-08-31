import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import '../services/token_service.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
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

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌─── REQUEST ───');
    print('│ ${options.method} ${options.uri}');
    print('│ Headers: ${options.headers}');
    print('│ Body: ${options.data}');
    print('└───────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌─── RESPONSE ───');
    print('│ ${response.statusCode} ${response.requestOptions.uri}');
    print('│ Data: ${response.data}');
    print('└────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌─── ERROR ───');
    print('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
    print('│ Error: ${err.error}');
    print('│ Message: ${err.message}');
    print('└──────────────');
    handler.next(err);
  }
}
