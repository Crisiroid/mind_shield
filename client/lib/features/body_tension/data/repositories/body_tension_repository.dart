import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/body_tension_local_datasource.dart';
import '../datasources/body_tension_remote_datasource.dart';
import '../models/body_tension_model.dart';

class BodyTensionRepository extends OfflineFirstRepository<BodyTensionModel> {
  final BodyTensionRemoteDataSource _remoteDataSource;
  final BodyTensionLocalDataSource _localDataSource;

  BodyTensionRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'body_tension';

  @override
  SyncableLocalDataSource<BodyTensionModel> get local => _localDataSource;

  @override
  Future<List<BodyTensionModel>> fetchRemoteList() =>
      _remoteDataSource.listBodyTensions(page: 1, pageSize: 200);

  @override
  Future<BodyTensionModel> pushCreate(BodyTensionModel item) async =>
      (await _remoteDataSource.createBodyTension(bodyTension: item)).data;

  Result<WriteResult<BodyTensionModel>> createBodyTension({
    required BodyTensionModel bodyTension,
  }) {
    return writeCreate(
      bodyTension,
      (i) => _remoteDataSource.createBodyTension(bodyTension: i),
    );
  }

  Result<List<BodyTensionModel>> listBodyTensions({
    int page = 1,
    int pageSize = 20,
  }) {
    return readList(
      () => _remoteDataSource.listBodyTensions(page: page, pageSize: pageSize),
    );
  }
}
