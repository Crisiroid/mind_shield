import '../../../../core/database/syncable_local_data_source.dart';
import '../models/role_value_model.dart';

class RoleValueLocalDataSource extends SyncableLocalDataSource<RoleValueModel> {
  @override
  String get tableName => 'role_value_entries';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS role_value_entries (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      entry_type TEXT,
      entry_text TEXT,
      day_number INTEGER,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(RoleValueModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(RoleValueModel item) => item.toDbMap();

  @override
  RoleValueModel fromDbMap(Map<String, dynamic> map) =>
      RoleValueModel.fromDbMap(map);
}
