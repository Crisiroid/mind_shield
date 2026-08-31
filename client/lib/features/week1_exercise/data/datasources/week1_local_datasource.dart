import '../../../../core/database/syncable_local_data_source.dart';
import '../models/weekly_exercise_model.dart';
import '../models/day_progress_model.dart';

class WeeklyExerciseLocalDataSource
    extends SyncableLocalDataSource<WeeklyExerciseModel> {
  @override
  String get tableName => 'weekly_exercise_responses';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS weekly_exercise_responses (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      week_number INTEGER,
      day_number INTEGER,
      exercise_type TEXT,
      response_data TEXT,
      completed_at TEXT,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(WeeklyExerciseModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(WeeklyExerciseModel item) => item.toDbMap();

  @override
  WeeklyExerciseModel fromDbMap(Map<String, dynamic> map) =>
      WeeklyExerciseModel.fromDbMap(map);
}

class DayProgressLocalDataSource
    extends SyncableLocalDataSource<DayProgressModel> {
  @override
  String get tableName => 'day_progress';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS day_progress (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      week_number INTEGER,
      day_number INTEGER,
      opened_at TEXT,
      is_completed INTEGER,
      completed_at TEXT,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(DayProgressModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(DayProgressModel item) => item.toDbMap();

  @override
  DayProgressModel fromDbMap(Map<String, dynamic> map) =>
      DayProgressModel.fromDbMap(map);
}
