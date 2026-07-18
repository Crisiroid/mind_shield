/// Base failure class for use with dartz Either pattern.
///
/// Each feature extends this to create domain-specific failures,
/// keeping the error flow type-safe and consistent across layers.
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';
}

/// Network-related failures.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'اتصال به اینترنت برقرار نیست'});
}

/// Server-related failures.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Cache/local storage failures.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'خطا در ذخیره‌سازی محلی'});
}

/// Sync-related failures.
class SyncFailure extends Failure {
  const SyncFailure({super.message = 'همگام‌سازی داده‌ها ناموفق بود'});
}

/// Unknown/unexpected failures.
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'خطای نامشخص رخ داد'});
}
