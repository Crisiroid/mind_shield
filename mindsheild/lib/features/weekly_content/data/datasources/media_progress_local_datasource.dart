import '../../../../core/database/syncable_local_data_source.dart';
import '../models/media_progress_model.dart';

/// Offline cache for per-user media progress. Mirrors the shape of the backend
/// `user_media_progress` table and follows the shared syncable-table contract
/// (`sync_status` + `updated_at` columns required by [SyncableLocalDataSource]).
class MediaProgressLocalDataSource
    extends SyncableLocalDataSource<MediaProgressModel> {
  @override
  String get tableName => 'media_progress';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS media_progress (
      id TEXT PRIMARY KEY,
      media_content_id TEXT,
      status TEXT,
      progress_seconds INTEGER,
      completed_at TEXT,
      created_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      updated_at TEXT
    )
  ''';

  @override
  String idOf(MediaProgressModel item) => item.id;

  @override
  Map<String, dynamic> toDbMap(MediaProgressModel item) => item.toDbMap();

  @override
  MediaProgressModel fromDbMap(Map<String, dynamic> map) =>
      MediaProgressModel.fromDbMap(map);
}
