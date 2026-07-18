import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';

/// Common result type alias for cleaner signatures.
typedef Result<T> = Future<Either<Failure, T>>;

/// Auth repository — bridges data source and domain layer.
///
/// Follows the Dependency Inversion Principle: depends on the
/// [AuthRemoteDataSource] abstraction, not on Dio directly.
/// Converts exceptions to [Failure] using dartz Either pattern.
class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepository(this._remoteDataSource);

  /// Authenticate user with phone number and password.
  Result<AuthTokenData> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Register a new user with phone number and password.
  Result<AuthTokenData> register({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.register(
        phoneNumber: phoneNumber,
        password: password,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Refresh the access token using the refresh token.
  Result<AuthTokenData> refreshToken({required String refreshToken}) async {
    try {
      final result = await _remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Logout the current user.
  Result<void> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Accept the digital therapy agreement on the server.
  Result<void> acceptAgreement() async {
    try {
      await _remoteDataSource.acceptAgreement();
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Send device/app version info to the server (best-effort).
  Result<void> updateLoginInfo({
    required String androidVersion,
    required String appVersion,
  }) async {
    try {
      await _remoteDataSource.updateLoginInfo(
        androidVersion: androidVersion,
        appVersion: appVersion,
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
          message: 'شماره تلفن یا رمز عبور اشتباه است',
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
