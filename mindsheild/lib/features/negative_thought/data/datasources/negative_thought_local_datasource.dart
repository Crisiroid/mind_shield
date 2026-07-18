import '../../../../core/database/syncable_local_data_source.dart';
import '../models/negative_thought_model.dart';

/// Local SQLite mirror + outbox for negative thought entries.
class NegativeThoughtLocalDataSource
    extends SyncableLocalDataSource<NegativeThoughtModel> {
  @override
  String get tableName => 'negative_thoughts';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS negative_thoughts (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      thought_text TEXT,
      situation TEXT,
      cognitive_error_type TEXT,
      impact_level INTEGER,
      recorded_at TEXT,
      day_number INTEGER,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(NegativeThoughtModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(NegativeThoughtModel item) => item.toDbMap();

  @override
  NegativeThoughtModel fromDbMap(Map<String, dynamic> map) =>
      NegativeThoughtModel.fromDbMap(map);
}
