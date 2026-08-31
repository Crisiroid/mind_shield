import '../../../../core/database/syncable_local_data_source.dart';
import '../models/mental_must_model.dart';

class MentalMustLocalDataSource
    extends SyncableLocalDataSource<MentalMustModel> {
  @override
  String get tableName => 'mental_musts';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS mental_musts (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      must_text TEXT,
      created_date TEXT,
      is_released INTEGER,
      released_date TEXT,
      day_number INTEGER,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(MentalMustModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(MentalMustModel item) => item.toDbMap();

  @override
  MentalMustModel fromDbMap(Map<String, dynamic> map) =>
      MentalMustModel.fromDbMap(map);
}
