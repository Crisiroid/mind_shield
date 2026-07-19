import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/stress_local_datasource.dart';
import '../datasources/stress_remote_datasource.dart';
import '../models/stress_event_model.dart';

class StressRepository extends OfflineFirstRepository<StressEventModel> {
  final StressRemoteDataSource _remoteDataSource;
  final StressLocalDataSource _localDataSource;

  StressRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'stress';

  @override
  SyncableLocalDataSource<StressEventModel> get local => _localDataSource;

  @override
  Future<List<StressEventModel>> fetchRemoteList() =>
      _remoteDataSource.listStressEvents(page: 1, pageSize: 200);

  @override
  Future<StressEventModel> pushCreate(StressEventModel item) async =>
      (await _remoteDataSource.createStressEvent(stressEvent: item)).data;

  Result<WriteResult<StressEventModel>> createStressEvent({
    required StressEventModel stressEvent,
  }) {
    return writeCreate(
      stressEvent,
      (i) => _remoteDataSource.createStressEvent(stressEvent: i),
    );
  }

  Result<List<StressEventModel>> listStressEvents({
    int page = 1,
    int pageSize = 20,
  }) {
    return readList(
      () => _remoteDataSource.listStressEvents(page: page, pageSize: pageSize),
    );
  }
}
