abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'اتصال به اینترنت برقرار نیست'});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'خطا در ذخیره‌سازی محلی'});
}

class SyncFailure extends Failure {
  const SyncFailure({super.message = 'همگام‌سازی داده‌ها ناموفق بود'});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'خطای نامشخص رخ داد'});
}
