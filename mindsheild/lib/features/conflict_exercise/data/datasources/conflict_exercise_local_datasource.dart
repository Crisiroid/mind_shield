import '../../../../core/database/syncable_local_data_source.dart';
import '../models/conflict_exercise_model.dart';

/// Local SQLite mirror + outbox for conflict exercise attempts.
class ConflictExerciseLocalDataSource
    extends SyncableLocalDataSource<ConflictExerciseModel> {
  @override
  String get tableName => 'conflict_exercises';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS conflict_exercises (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      scenario_id INTEGER,
      practice_count INTEGER,
      performance_score INTEGER,
      day_number INTEGER,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(ConflictExerciseModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(ConflictExerciseModel item) => item.toDbMap();

  @override
  ConflictExerciseModel fromDbMap(Map<String, dynamic> map) =>
      ConflictExerciseModel.fromDbMap(map);
}
