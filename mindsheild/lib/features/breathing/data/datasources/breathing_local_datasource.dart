import '../../../../core/database/syncable_local_data_source.dart';
import '../models/breathing_session_model.dart';

/// Local SQLite mirror + outbox for breathing sessions.
class BreathingLocalDataSource
    extends SyncableLocalDataSource<BreathingSessionModel> {
  @override
  String get tableName => 'breathing_sessions';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS breathing_sessions (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      session_start TEXT,
      session_end TEXT,
      duration_seconds INTEGER,
      breathing_pattern TEXT,
      is_completed INTEGER,
      calendar_ticked INTEGER,
      day_number INTEGER,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(BreathingSessionModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(BreathingSessionModel item) => item.toDbMap();

  @override
  BreathingSessionModel fromDbMap(Map<String, dynamic> map) =>
      BreathingSessionModel.fromDbMap(map);
}
