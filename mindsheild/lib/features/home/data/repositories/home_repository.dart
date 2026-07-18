import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/weekly_media_model.dart';

/// Home repository — bridges data source and domain layer.
///
/// Follows the Dependency Inversion Principle: depends on the
/// [HomeRemoteDataSource] abstraction, not on Dio directly.
/// Converts exceptions to [Failure] using dartz Either pattern.
class HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  const HomeRepository(this._remoteDataSource);

  /// Fetch weekly media content for a specific week.
  Result<List<WeeklyMediaModel>> getMediaByWeek({
    required int weekNumber,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await _remoteDataSource.getMediaByWeek(
        weekNumber: weekNumber,
        page: page,
        pageSize: pageSize,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Fetch all active weekly media content.
  Result<List<WeeklyMediaModel>> getAllMedia({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await _remoteDataSource.getAllMedia(
        page: page,
        pageSize: pageSize,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Maps any exception to the appropriate [Failure].
  Failure _mapExceptionToFailure(dynamic error) {
    if (error is DioException) {
      final appException = error.error;
      if (appException is NetworkException) {
        return const NetworkFailure();
      }
      if (appException is TimeoutException) {
        return const ServerFailure(message: 'زمان درخواست به پایان رسید');
      }
      if (appException is UnauthorizedException) {
        return const ServerFailure(
          message: 'لطفاً وارد حساب کاربری خود شوید',
          statusCode: 401,
        );
      }
      if (appException is ServerException) {
        return ServerFailure(
          message: appException.message,
          statusCode: appException.statusCode,
        );
      }
    }
    if (error is AppException) {
      if (error is NetworkException) return const NetworkFailure();
      if (error is TimeoutException) {
        return const ServerFailure(message: 'زمان درخواست به پایان رسید');
      }
      return ServerFailure(
        message: error.message,
        statusCode: error.statusCode,
      );
    }
    return const UnknownFailure();
  }
}
