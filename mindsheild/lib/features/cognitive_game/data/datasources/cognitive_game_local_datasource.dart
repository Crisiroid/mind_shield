import '../../../../core/database/syncable_local_data_source.dart';
import '../models/cognitive_game_model.dart';

class CognitiveGameLocalDataSource
    extends SyncableLocalDataSource<CognitiveGameModel> {
  @override
  String get tableName => 'cognitive_games';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS cognitive_games (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      game_date TEXT,
      scenario_id INTEGER,
      scenario_type TEXT,
      score INTEGER,
      is_correct INTEGER,
      time_taken_seconds INTEGER,
      day_number INTEGER,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(CognitiveGameModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(CognitiveGameModel item) => item.toDbMap();

  @override
  CognitiveGameModel fromDbMap(Map<String, dynamic> map) =>
      CognitiveGameModel.fromDbMap(map);
}
