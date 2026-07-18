import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../datasources/profile_remote_datasource.dart';

typedef Result<T> = Future<Either<Failure, T>>;

/// Profile repository — bridges data source and domain layer.
///
/// Follows the Dependency Inversion Principle: depends on the
/// [ProfileRemoteDataSource] abstraction, not on Dio directly.
/// Converts exceptions to [Failure] using dartz Either pattern.
class ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  const ProfileRepository(this._remoteDataSource);

  /// Fetch the current user's profile.
  Result<UserModel> getProfile() async {
    try {
      final result = await _remoteDataSource.getProfile();
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Update the current user's profile settings.
  Result<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final result = await _remoteDataSource.updateProfile(data);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Change the current user's password.
  Result<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return const Right(null);
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
