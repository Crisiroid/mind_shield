import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/negative_thought_local_datasource.dart';
import '../datasources/negative_thought_remote_datasource.dart';
import '../models/negative_thought_model.dart';

/// Negative thought repository — offline-first bridge between the data
/// sources and the domain layer.
class NegativeThoughtRepository
    extends OfflineFirstRepository<NegativeThoughtModel> {
  final NegativeThoughtRemoteDataSource _remoteDataSource;
  final NegativeThoughtLocalDataSource _localDataSource;

  NegativeThoughtRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'negative_thought';

  @override
  SyncableLocalDataSource<NegativeThoughtModel> get local => _localDataSource;

  @override
  Future<List<NegativeThoughtModel>> fetchRemoteList() =>
      _remoteDataSource.listNegativeThoughts(page: 1, pageSize: 200);

  @override
  Future<NegativeThoughtModel> pushCreate(NegativeThoughtModel item) async =>
      (await _remoteDataSource.createNegativeThought(thought: item)).data;

  /// Create a new negative thought entry (offline-first).
  Result<WriteResult<NegativeThoughtModel>> createNegativeThought({
    required NegativeThoughtModel thought,
  }) {
    return writeCreate(
      thought,
      (i) => _remoteDataSource.createNegativeThought(thought: i),
    );
  }

  /// List negative thought entries (offline-first).
  Result<List<NegativeThoughtModel>> listNegativeThoughts({
    int page = 1,
    int pageSize = 20,
  }) {
    return readList(
      () => _remoteDataSource.listNegativeThoughts(
        page: page,
        pageSize: pageSize,
      ),
    );
  }
}
