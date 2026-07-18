import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/mind_court_local_datasource.dart';
import '../datasources/mind_court_remote_datasource.dart';
import '../models/mind_court_model.dart';

/// Mind court repository — offline-first bridge between the data sources
/// and the domain layer.
class MindCourtRepository extends OfflineFirstRepository<MindCourtModel> {
  final MindCourtRemoteDataSource _remoteDataSource;
  final MindCourtLocalDataSource _localDataSource;

  MindCourtRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'mind_court';

  @override
  SyncableLocalDataSource<MindCourtModel> get local => _localDataSource;

  @override
  Future<List<MindCourtModel>> fetchRemoteList() =>
      _remoteDataSource.listMindCourt(page: 1, pageSize: 200);

  @override
  Future<MindCourtModel> pushCreate(MindCourtModel item) async =>
      (await _remoteDataSource.createMindCourt(evidence: item)).data;

  /// Create a new mind court evidence entry (offline-first).
  Result<WriteResult<MindCourtModel>> createMindCourt({
    required MindCourtModel evidence,
  }) {
    return writeCreate(
      evidence,
      (i) => _remoteDataSource.createMindCourt(evidence: i),
    );
  }

  /// List mind court evidence entries (offline-first).
  Result<List<MindCourtModel>> listMindCourt({
    int page = 1,
    int pageSize = 20,
  }) {
    return readList(
      () => _remoteDataSource.listMindCourt(page: page, pageSize: pageSize),
    );
  }
}
