import '../../../../core/database/syncable_local_data_source.dart';
import '../models/mind_court_model.dart';

class MindCourtLocalDataSource extends SyncableLocalDataSource<MindCourtModel> {
  @override
  String get tableName => 'mind_court_entries';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS mind_court_entries (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      negative_thought_id TEXT,
      supporting_evidence TEXT,
      contradicting_evidence TEXT,
      guide_helper_used INTEGER,
      alternative_thought TEXT,
      day_number INTEGER,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(MindCourtModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(MindCourtModel item) => item.toDbMap();

  @override
  MindCourtModel fromDbMap(Map<String, dynamic> map) =>
      MindCourtModel.fromDbMap(map);
}
