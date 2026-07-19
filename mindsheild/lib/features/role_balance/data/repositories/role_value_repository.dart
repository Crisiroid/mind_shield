import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/role_value_local_datasource.dart';
import '../datasources/role_value_remote_datasource.dart';
import '../models/role_value_model.dart';

class RoleValueRepository extends OfflineFirstRepository<RoleValueModel> {
  final RoleValueRemoteDataSource _remoteDataSource;
  final RoleValueLocalDataSource _localDataSource;

  RoleValueRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'role_value';

  @override
  SyncableLocalDataSource<RoleValueModel> get local => _localDataSource;

  @override
  Future<List<RoleValueModel>> fetchRemoteList() =>
      _remoteDataSource.listRolesValues(page: 1, pageSize: 200);

  @override
  Future<RoleValueModel> pushCreate(RoleValueModel item) async =>
      (await _remoteDataSource.createRoleValue(entry: item)).data;

  Result<WriteResult<RoleValueModel>> createRoleValue({
    required RoleValueModel entry,
  }) {
    return writeCreate(
      entry,
      (i) => _remoteDataSource.createRoleValue(entry: i),
    );
  }

  Result<List<RoleValueModel>> listRolesValues({
    int page = 1,
    int pageSize = 50,
  }) {
    return readList(
      () => _remoteDataSource.listRolesValues(page: page, pageSize: pageSize),
    );
  }
}
