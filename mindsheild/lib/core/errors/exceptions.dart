/// Base exception class for all application errors.
///
/// Follows the Dependency Inversion Principle — high-level modules depend
/// on this abstraction, not on concrete Dio or platform exceptions.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException({required this.message, this.statusCode, this.data});

  @override
  String toString() =>
      'AppException(message: $message, statusCode: $statusCode)';
}

/// Thrown when a network connectivity error occurs.
class NetworkException extends AppException {
  const NetworkException({super.message = 'اتصال به اینترنت برقرار نیست'});
}

/// Thrown when the server returns a 4xx/5xx response.
class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode, super.data});
}

/// Thrown when authentication fails (401).
class UnauthorizedException extends ServerException {
  const UnauthorizedException({
    super.message = 'لطفاً وارد حساب کاربری خود شوید',
    super.statusCode = 401,
  });
}

/// Thrown when access is forbidden (403).
class ForbiddenException extends ServerException {
  const ForbiddenException({
    super.message = 'شما دسترسی به این بخش را ندارید',
    super.statusCode = 403,
  });
}

/// Thrown when a requested resource is not found (404).
class NotFoundException extends ServerException {
  const NotFoundException({
    super.message = 'مورد درخواستی یافت نشد',
    super.statusCode = 404,
  });
}

/// Thrown when a request times out.
class TimeoutException extends AppException {
  const TimeoutException({super.message = 'زمان درخواست به پایان رسید'});
}

/// Thrown when local database operations fail.
class CacheException extends AppException {
  const CacheException({super.message = 'خطا در ذخیره‌سازی محلی'});
}
