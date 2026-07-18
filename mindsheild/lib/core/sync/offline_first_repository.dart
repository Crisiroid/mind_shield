import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../database/syncable_local_data_source.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../utils/uuid_generator.dart';
import 'syncable_repository.dart';

/// Common result type alias (kept identical to the one in auth_repository so
/// feature repositories can migrate without signature changes).
typedef Result<T> = Future<Either<Failure, T>>;

/// Base class for every offline-first feature repository.
///
/// Centralizes the read/write/sync flow and the exception→[Failure] mapping so
/// the twelve feature repositories stay thin and consistent (DRY). Concrete
/// repositories supply their [local] mirror plus the two remote hooks used for
/// sync: [fetchRemoteList] and [pushCreate].
///
/// Behavioural contract (server is the source of truth):
///   * Reads  — try remote, replace mirror, return remote; on connectivity
///              failure fall back to the local mirror. Surface a [Failure]
///              only when offline AND the mirror is empty.
///   * Writes — persist an optimistic `pending` row immediately; try remote;
///              on success swap it for the server copy; on connectivity
///              failure keep it pending (the row is the outbox entry).
abstract class OfflineFirstRepository<T> implements SyncableRepository {
  /// The local mirror + outbox for this feature.
  SyncableLocalDataSource<T> get local;

  /// Fetch the full server list for this feature (used by pull/reconcile).
  Future<List<T>> fetchRemoteList();

  /// Push a single locally-created model to the server, returning the
  /// server-confirmed model (with its assigned id).
  Future<T> pushCreate(T item);

  /// Push a locally-updated model to the server. Only features that support
  /// updates override this; the default rejects the call so create-only
  /// features never accidentally re-push an update as a create.
  Future<T> pushUpdate(T item) =>
      throw UnsupportedError('$runtimeType does not support updates');

  // ─── Read (offline-first) ─────────────────────────────────────

  /// Fetch [remoteList] online and mirror it locally, falling back to the
  /// local mirror when the network/server is unavailable.
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

  // ─── Write (offline-first) ────────────────────────────────────

  /// Persist [item] optimistically, then attempt [remoteCreate].
  ///
  /// Returns the server model on success, the optimistic local model when
  /// offline (kept pending as an outbox entry), or a [Failure] for genuine
  /// server rejections (the optimistic row is rolled back in that case).
  Future<Either<Failure, T>> writeCreate(
    T item,
    Future<T> Function(T) remoteCreate,
  ) async {
    final optimistic = await local.savePending(item);
    final localId = local.idOf(optimistic);
    try {
      final saved = await remoteCreate(item);
      await local.deleteById(localId);
      await local.saveSynced(saved);
      return Right(saved);
    } catch (e) {
      if (_isConnectivityError(e)) {
        // Stay offline: the pending row is the outbox entry.
        return Right(optimistic);
      }
      // Genuine server rejection — undo the optimistic write.
      await local.deleteById(localId);
      return Left(mapExceptionToFailure(e));
    }
  }

  /// Persist an optimistic update to [item] (kept under its existing id),
  /// then attempt [remoteUpdate].
  ///
  /// Mirrors [writeCreate] semantics: returns the server copy on success, the
  /// optimistic copy when offline (kept pending as an outbox entry), or a
  /// [Failure] on genuine server rejection.
  Future<Either<Failure, T>> writeUpdate(
    T item,
    Future<T> Function(T) remoteUpdate,
  ) async {
    final optimistic = await local.savePending(item);
    try {
      final saved = await remoteUpdate(item);
      await local.saveSynced(saved);
      return Right(saved);
    } catch (e) {
      if (_isConnectivityError(e)) {
        // Stay offline: the pending row is the outbox entry.
        return Right(optimistic);
      }
      return Left(mapExceptionToFailure(e));
    }
  }

  // ─── SyncableRepository ───────────────────────────────────────

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
        // Local UUID -> the row was created offline (POST); a server id -> the
        // row already exists remotely and was edited offline (PUT).
        final saved = UuidGenerator.isLocal(id)
            ? await pushCreate(item)
            : await pushUpdate(item);
        await local.deleteById(id);
        await local.saveSynced(saved);
      } catch (_) {
        // Leave the row pending; it will be retried on the next push.
      }
    }
  }

  // ─── Shared helpers ───────────────────────────────────────────

  /// Whether [error] represents a lost connection / unreachable server rather
  /// than a deliberate 4xx rejection.
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

  /// Maps any thrown error to the appropriate [Failure]. Shared by all feature
  /// repositories to avoid duplicating the mapping logic (DRY).
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
