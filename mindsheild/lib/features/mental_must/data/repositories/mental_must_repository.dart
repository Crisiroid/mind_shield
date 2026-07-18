import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/mental_must_local_datasource.dart';
import '../datasources/mental_must_remote_datasource.dart';
import '../models/mental_must_model.dart';

/// Mental must repository — offline-first bridge between the data sources and
/// the domain layer. Supports create, update (release) and list.
class MentalMustRepository extends OfflineFirstRepository<MentalMustModel> {
  final MentalMustRemoteDataSource _remoteDataSource;
  final MentalMustLocalDataSource _localDataSource;

  MentalMustRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'mental_must';

  @override
  SyncableLocalDataSource<MentalMustModel> get local => _localDataSource;

  @override
  Future<List<MentalMustModel>> fetchRemoteList() =>
      _remoteDataSource.listMentalMusts(page: 1, pageSize: 200);

  @override
  Future<MentalMustModel> pushCreate(MentalMustModel item) async =>
      (await _remoteDataSource.createMentalMust(must: item)).data;

  @override
  Future<MentalMustModel> pushUpdate(MentalMustModel item) async =>
      (await _remoteDataSource.updateMentalMust(
        id: item.id,
        data: item.toUpdateJson(isReleased: item.isReleased),
      )).data;

  /// Create a new mental must entry (offline-first).
  Result<WriteResult<MentalMustModel>> createMentalMust({
    required MentalMustModel must,
  }) {
    return writeCreate(
      must,
      (i) => _remoteDataSource.createMentalMust(must: i),
    );
  }

  /// Update a mental must entry, e.g. release it (offline-first).
  Result<WriteResult<MentalMustModel>> updateMentalMust({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final existing = await _localDataSource.getById(id);
    final isReleased =
        data['is_released'] as bool? ?? existing?.isReleased ?? false;
    final updated = MentalMustModel(
      id: id,
      userId: existing?.userId ?? '',
      mustText: existing?.mustText ?? '',
      createdDate: existing?.createdDate ?? '',
      isReleased: isReleased,
      releasedDate: existing?.releasedDate,
      dayNumber: existing?.dayNumber,
      createdAt: existing?.createdAt,
    );
    return writeUpdate(
      updated,
      (i) => _remoteDataSource.updateMentalMust(
        id: id,
        data: i.toUpdateJson(isReleased: i.isReleased),
      ),
    );
  }

  /// List mental must entries (offline-first).
  Result<List<MentalMustModel>> listMentalMusts({
    int page = 1,
    int pageSize = 50,
  }) {
    return readList(
      () => _remoteDataSource.listMentalMusts(page: page, pageSize: pageSize),
    );
  }
}
