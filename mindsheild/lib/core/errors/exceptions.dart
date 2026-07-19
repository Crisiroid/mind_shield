abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException({required this.message, this.statusCode, this.data});

  @override
  String toString() =>
      'AppException(message: $message, statusCode: $statusCode)';
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'اتصال به اینترنت برقرار نیست'});
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode, super.data});
}

class UnauthorizedException extends ServerException {
  const UnauthorizedException({
    super.message = 'لطفاً وارد حساب کاربری خود شوید',
    super.statusCode = 401,
  });
}

class ForbiddenException extends ServerException {
  const ForbiddenException({
    super.message = 'شما دسترسی به این بخش را ندارید',
    super.statusCode = 403,
  });
}

class NotFoundException extends ServerException {
  const NotFoundException({
    super.message = 'مورد درخواستی یافت نشد',
    super.statusCode = 404,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({super.message = 'زمان درخواست به پایان رسید'});
}

class CacheException extends AppException {
  const CacheException({super.message = 'خطا در ذخیره‌سازی محلی'});
}
