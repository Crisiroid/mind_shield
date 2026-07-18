import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/sky_thought_local_datasource.dart';
import '../datasources/sky_thought_remote_datasource.dart';
import '../models/sky_thought_model.dart';

/// Sky thought repository — offline-first bridge between the data sources and
/// the domain layer. Supports create, update (swipe) and list.
class SkyThoughtRepository extends OfflineFirstRepository<SkyThoughtModel> {
  final SkyThoughtRemoteDataSource _remoteDataSource;
  final SkyThoughtLocalDataSource _localDataSource;

  SkyThoughtRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'sky_thought';

  @override
  SyncableLocalDataSource<SkyThoughtModel> get local => _localDataSource;

  @override
  Future<List<SkyThoughtModel>> fetchRemoteList() =>
      _remoteDataSource.listSkyThoughts(page: 1, pageSize: 200);

  @override
  Future<SkyThoughtModel> pushCreate(SkyThoughtModel item) async =>
      (await _remoteDataSource.createSkyThought(thought: item)).data;

  @override
  Future<SkyThoughtModel> pushUpdate(SkyThoughtModel item) async =>
      (await _remoteDataSource.updateSkyThought(
        id: item.id,
        cloudSwiped: item.cloudSwiped,
      )).data;

  /// Create a new sky thought (offline-first).
  Result<WriteResult<SkyThoughtModel>> createSkyThought({
    required SkyThoughtModel thought,
  }) {
    return writeCreate(
      thought,
      (i) => _remoteDataSource.createSkyThought(thought: i),
    );
  }

  /// Update a sky thought, e.g. mark its cloud swiped away (offline-first).
  Result<WriteResult<SkyThoughtModel>> updateSkyThought({
    required String id,
    required bool cloudSwiped,
  }) async {
    final existing = await _localDataSource.getById(id);
    final updated =
        (existing ?? SkyThoughtModel(id: id, userId: '', thoughtText: ''))
            .copyWith(cloudSwiped: cloudSwiped);
    return writeUpdate(
      updated,
      (i) => _remoteDataSource.updateSkyThought(
        id: id,
        cloudSwiped: i.cloudSwiped,
      ),
    );
  }

  /// List sky thoughts (offline-first).
  Result<List<SkyThoughtModel>> listSkyThoughts({
    int page = 1,
    int pageSize = 50,
  }) {
    return readList(
      () => _remoteDataSource.listSkyThoughts(page: page, pageSize: pageSize),
    );
  }
}
