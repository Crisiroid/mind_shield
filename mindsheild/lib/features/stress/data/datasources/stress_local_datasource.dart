import '../../../../core/database/syncable_local_data_source.dart';
import '../models/stress_event_model.dart';

/// Local SQLite mirror + outbox for stress events.
class StressLocalDataSource extends SyncableLocalDataSource<StressEventModel> {
  @override
  String get tableName => 'stress_events';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS stress_events (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      event_timestamp TEXT,
      situation_type TEXT,
      situation_description TEXT,
      intensity_level INTEGER,
      location TEXT,
      day_number INTEGER,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(StressEventModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(StressEventModel item) => item.toDbMap();

  @override
  StressEventModel fromDbMap(Map<String, dynamic> map) =>
      StressEventModel.fromDbMap(map);
}
