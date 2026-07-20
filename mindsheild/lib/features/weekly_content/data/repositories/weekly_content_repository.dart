import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/storage_service.dart';
import '../../../home/data/models/weekly_media_model.dart';
import '../datasources/weekly_content_remote_datasource.dart';

/// Lightweight repository for the read-only media library. Content is fetched
/// from the backend and mirrored into the shared key/value cache so the library
/// still renders offline. It is intentionally *not* a [SyncableRepository]: the
/// library is server-owned and never written from the client.
class WeeklyContentRepository {
  final WeeklyContentRemoteDataSource _remoteDataSource;

  WeeklyContentRepository(this._remoteDataSource);

  static const String _cacheKey = 'weekly_content_library';

  Future<Either<Failure, List<WeeklyMediaModel>>> getAllContent() async {
    try {
      final content = await _remoteDataSource.getAllContent();
      await _writeCache(content);
      return Right(content);
    } catch (e) {
      final cached = await _readCache();
      if (cached.isNotEmpty) return Right(cached);
      return const Left(
        ServerFailure(message: 'بارگذاری محتوا با خطا مواجه شد'),
      );
    }
  }

  Future<void> _writeCache(List<WeeklyMediaModel> content) async {
    final encoded = jsonEncode(content.map((m) => m.toJson()).toList());
    await StorageService.putCache(_cacheKey, encoded);
  }

  Future<List<WeeklyMediaModel>> _readCache() async {
    final raw = await StorageService.getCache(_cacheKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => WeeklyMediaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
