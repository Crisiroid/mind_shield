import '../../../../core/database/syncable_local_data_source.dart';
import '../models/body_tension_model.dart';

class BodyTensionLocalDataSource
    extends SyncableLocalDataSource<BodyTensionModel> {
  @override
  String get tableName => 'body_tension_maps';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS body_tension_maps (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      mapping_date TEXT,
      body_regions TEXT,
      overall_intensity INTEGER,
      severity_color TEXT,
      notes TEXT,
      day_number INTEGER,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(BodyTensionModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(BodyTensionModel item) => item.toDbMap();

  @override
  BodyTensionModel fromDbMap(Map<String, dynamic> map) =>
      BodyTensionModel.fromDbMap(map);
}
