import '../../../../core/database/syncable_local_data_source.dart';
import '../models/mood_tracker_model.dart';

/// Local SQLite mirror + outbox for mood tracker records.
class MoodTrackerLocalDataSource
    extends SyncableLocalDataSource<MoodTrackerModel> {
  @override
  String get tableName => 'mood_tracker_entries';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS mood_tracker_entries (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      activity_id TEXT,
      activity_name TEXT,
      mood_before INTEGER,
      mood_after INTEGER,
      mood_delta INTEGER,
      notes TEXT,
      day_number INTEGER,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(MoodTrackerModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(MoodTrackerModel item) => item.toDbMap();

  @override
  MoodTrackerModel fromDbMap(Map<String, dynamic> map) =>
      MoodTrackerModel.fromDbMap(map);
}
