import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../datasources/profile_remote_datasource.dart';

typedef Result<T> = Future<Either<Failure, T>>;

class ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  const ProfileRepository(this._remoteDataSource);

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
