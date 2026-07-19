import '../../../../core/database/syncable_local_data_source.dart';
import '../models/emotion_interaction_model.dart';

class EmotionTriangleLocalDataSource
    extends SyncableLocalDataSource<EmotionInteractionModel> {
  @override
  String get tableName => 'emotion_interactions';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS emotion_interactions (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      interaction_date TEXT,
      side_clicked TEXT,
      thought_accounts_viewed TEXT,
      vibration_triggered INTEGER,
      day_number INTEGER,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(EmotionInteractionModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(EmotionInteractionModel item) => item.toDbMap();

  @override
  EmotionInteractionModel fromDbMap(Map<String, dynamic> map) =>
      EmotionInteractionModel.fromDbMap(map);
}
