import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../constants/app_strings.dart';
import '../database/syncable_local_data_source.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../utils/uuid_generator.dart';
import 'syncable_repository.dart';
import 'write_result.dart';

typedef Result<T> = Future<Either<Failure, T>>;

abstract class OfflineFirstRepository<T> implements SyncableRepository {
  SyncableLocalDataSource<T> get local;

  Future<List<T>> fetchRemoteList();

  Future<T> pushCreate(T item);

  Future<T> pushUpdate(T item) =>
      throw UnsupportedError('$runtimeType does not support updates');

  Future<Either<Failure, List<T>>> readList(
    Future<List<T>> Function() remoteList,
  ) async {
    try {
      final remote = await remoteList();
      await local.replaceAll(remote);
      return Right(remote);
    } catch (e) {
      if (_isConnectivityError(e)) {
        final cached = await local.getAll();
        if (cached.isNotEmpty) return Right(cached);
      }
      return Left(mapExceptionToFailure(e));
    }
  }

  Future<Either<Failure, WriteResult<T>>> writeCreate(
    T item,
    Future<WriteResult<T>> Function(T) remoteCreate,
  ) async {
    final optimistic = await local.savePending(item);
    final localId = local.idOf(optimistic);
    try {
      final saved = await remoteCreate(item);
      await local.deleteById(localId);
      await local.saveSynced(saved.data);
      return Right(saved);
    } catch (e) {
      if (_isConnectivityError(e)) {
        return Right(
          WriteResult(optimistic, AppStrings.dataWillSync, fromServer: false),
        );
      }
      await local.deleteById(localId);
      return Left(mapExceptionToFailure(e));
    }
  }

  Future<Either<Failure, WriteResult<T>>> writeUpdate(
    T item,
    Future<WriteResult<T>> Function(T) remoteUpdate,
  ) async {
    final optimistic = await local.savePending(item);
    try {
      final saved = await remoteUpdate(item);
      await local.saveSynced(saved.data);
      return Right(saved);
    } catch (e) {
      if (_isConnectivityError(e)) {
        return Right(
          WriteResult(optimistic, AppStrings.dataWillSync, fromServer: false),
        );
      }
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<void> pullFromServer() async {
    final remote = await fetchRemoteList();
    await local.replaceAll(remote);
  }

  @override
  Future<void> pushPending() async {
    final pending = await local.getPending();
    for (final item in pending) {
      try {
        final id = local.idOf(item);
        final saved = UuidGenerator.isLocal(id)
            ? await pushCreate(item)
            : await pushUpdate(item);
        await local.deleteById(id);
        await local.saveSynced(saved);
      } catch (_) {}
    }
  }

  bool _isConnectivityError(dynamic error) {
    final ex = error is DioException ? error.error : error;
    if (ex is NetworkException || ex is TimeoutException) return true;
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return true;
        default:
          return false;
      }
    }
    return false;
  }

  Failure mapExceptionToFailure(dynamic error) {
    if (error is DioException) {
      final appException = error.error;
      if (appException is NetworkException) return const NetworkFailure();
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
      if (_isConnectivityError(error)) return const NetworkFailure();
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
