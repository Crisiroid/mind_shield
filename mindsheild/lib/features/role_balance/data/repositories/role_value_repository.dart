import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../datasources/role_value_local_datasource.dart';
import '../datasources/role_value_remote_datasource.dart';
import '../models/role_value_model.dart';

/// Role/Value repository — offline-first bridge between the data sources
/// and the domain layer.
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
  Future<RoleValueModel> pushCreate(RoleValueModel item) =>
      _remoteDataSource.createRoleValue(entry: item);

  /// Create a new role or value entry (offline-first).
  Result<RoleValueModel> createRoleValue({required RoleValueModel entry}) {
    return writeCreate(
      entry,
      (i) => _remoteDataSource.createRoleValue(entry: i),
    );
  }

  /// List role/value entries (offline-first).
  Result<List<RoleValueModel>> listRolesValues({
    int page = 1,
    int pageSize = 50,
  }) {
    return readList(
      () => _remoteDataSource.listRolesValues(page: page, pageSize: pageSize),
    );
  }
}
