import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/breathing_local_datasource.dart';
import '../datasources/breathing_remote_datasource.dart';
import '../models/breathing_session_model.dart';

class BreathingRepository
    extends OfflineFirstRepository<BreathingSessionModel> {
  final BreathingRemoteDataSource _remoteDataSource;
  final BreathingLocalDataSource _localDataSource;

  BreathingRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'breathing';

  @override
  SyncableLocalDataSource<BreathingSessionModel> get local => _localDataSource;

  @override
  Future<List<BreathingSessionModel>> fetchRemoteList() =>
      _remoteDataSource.listSessions(page: 1, pageSize: 200);

  @override
  Future<BreathingSessionModel> pushCreate(BreathingSessionModel item) async =>
      (await _remoteDataSource.createSession(session: item)).data;

  @override
  Future<BreathingSessionModel> pushUpdate(BreathingSessionModel item) async =>
      (await _remoteDataSource.updateSession(
        id: item.id,
        data: item.toUpdateJson(),
      )).data;

  Result<WriteResult<BreathingSessionModel>> createSession({
    required BreathingSessionModel session,
  }) {
    return writeCreate(
      session,
      (i) => _remoteDataSource.createSession(session: i),
    );
  }

  Result<WriteResult<BreathingSessionModel>> updateSession({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final existing = await _localDataSource.getById(id);
    final updated = _merge(existing, id, data);
    return writeUpdate(
      updated,
      (i) => _remoteDataSource.updateSession(id: id, data: i.toUpdateJson()),
    );
  }

  Result<List<BreathingSessionModel>> listSessions({
    int page = 1,
    int pageSize = 20,
  }) {
    return readList(
      () => _remoteDataSource.listSessions(page: page, pageSize: pageSize),
    );
  }

  BreathingSessionModel _merge(
    BreathingSessionModel? existing,
    String id,
    Map<String, dynamic> data,
  ) {
    return BreathingSessionModel(
      id: id,
      userId: existing?.userId ?? '',
      sessionStart: existing?.sessionStart ?? DateTime.now(),
      sessionEnd: data['session_end'] != null
          ? DateTime.tryParse(data['session_end'] as String)
          : existing?.sessionEnd,
      durationSeconds:
          (data['duration_seconds'] as num?)?.toInt() ??
          existing?.durationSeconds,
      breathingPattern: existing?.breathingPattern,
      isCompleted:
          data['is_completed'] as bool? ?? existing?.isCompleted ?? false,
      calendarTicked:
          data['calendar_ticked'] as bool? ?? existing?.calendarTicked ?? false,
      dayNumber: existing?.dayNumber,
      createdAt: existing?.createdAt,
    );
  }
}
