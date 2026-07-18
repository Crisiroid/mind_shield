import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../datasources/breathing_local_datasource.dart';
import '../datasources/breathing_remote_datasource.dart';
import '../models/breathing_session_model.dart';

/// Breathing repository — offline-first bridge between the data sources and
/// the domain layer. Supports create, update and list, all offline-first.
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
  Future<BreathingSessionModel> pushCreate(BreathingSessionModel item) =>
      _remoteDataSource.createSession(session: item);

  @override
  Future<BreathingSessionModel> pushUpdate(BreathingSessionModel item) =>
      _remoteDataSource.updateSession(id: item.id, data: item.toUpdateJson());

  /// Create a new breathing session (offline-first).
  Result<BreathingSessionModel> createSession({
    required BreathingSessionModel session,
  }) {
    return writeCreate(
      session,
      (i) => _remoteDataSource.createSession(session: i),
    );
  }

  /// Update an existing breathing session (offline-first).
  Result<BreathingSessionModel> updateSession({
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

  /// List breathing sessions (offline-first).
  Result<List<BreathingSessionModel>> listSessions({
    int page = 1,
    int pageSize = 20,
  }) {
    return readList(
      () => _remoteDataSource.listSessions(page: page, pageSize: pageSize),
    );
  }

  /// Build the updated session model by applying the partial [data] map onto
  /// the [existing] mirror row, so the outbox carries the full new state.
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
