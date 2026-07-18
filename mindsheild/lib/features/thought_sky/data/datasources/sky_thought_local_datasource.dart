import '../../../../core/database/syncable_local_data_source.dart';
import '../models/sky_thought_model.dart';

/// Local SQLite mirror + outbox for sky thoughts.
class SkyThoughtLocalDataSource
    extends SyncableLocalDataSource<SkyThoughtModel> {
  @override
  String get tableName => 'sky_thoughts';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS sky_thoughts (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      thought_text TEXT,
      cloud_swiped INTEGER,
      day_number INTEGER,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(SkyThoughtModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(SkyThoughtModel item) => item.toDbMap();

  @override
  SkyThoughtModel fromDbMap(Map<String, dynamic> map) =>
      SkyThoughtModel.fromDbMap(map);
}
