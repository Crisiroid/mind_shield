import '../services/storage_service.dart';
import '../utils/uuid_generator.dart';

/// Sync status stored alongside every mirrored row.
class SyncStatus {
  SyncStatus._();

  /// Row is confirmed present on the server.
  static const String synced = 'synced';

  /// Row is a local write awaiting push to the server (outbox entry).
  static const String pending = 'pending';
}

/// Generic, typed local mirror + outbox for a single feature.
///
/// Each feature provides its own table name, DDL and row mapping (honouring
/// the "typed per-feature tables" decision) while the shared CRUD/sync logic
/// lives here once (DRY). The class stays persistence-agnostic by delegating
/// all SQL to [StorageService] (Dependency Inversion).
///
/// Every table is expected to expose these system columns in addition to the
/// feature's own typed columns:
///   * `id TEXT PRIMARY KEY`      — server id, or a client UUID while offline
///   * `sync_status TEXT`         — [SyncStatus.synced] | [SyncStatus.pending]
///   * `created_at TEXT`          — used for ordering (newest first)
///   * `updated_at TEXT`          — bookkeeping for last local write
abstract class SyncableLocalDataSource<T> {
  /// Physical table name for this feature's mirror.
  String get tableName;

  /// Full `CREATE TABLE IF NOT EXISTS` statement for [tableName].
  String get createTableSql;

  /// The stable id of a model instance (server id or local UUID).
  String idOf(T item);

  /// Serialize a model to its typed column map (including the `id` column).
  /// System columns (`sync_status`, `updated_at`) are added by this base.
  Map<String, dynamic> toDbMap(T item);

  /// Rebuild a model from a stored row.
  T fromDbMap(Map<String, dynamic> map);

  bool _initialized = false;

  /// Lazily create the feature table (once per session).
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await StorageService.ensureTable(createTableSql);
    _initialized = true;
  }

  /// All rows for this feature, newest first (pending + synced).
  Future<List<T>> getAll() async {
    await ensureInitialized();
    final rows = await StorageService.queryAll(
      tableName,
      orderBy: 'created_at DESC',
    );
    return rows.map(fromDbMap).toList();
  }

  /// A single row by id, or null when absent.
  Future<T?> getById(String id) async {
    await ensureInitialized();
    final rows = await StorageService.queryWhere(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return fromDbMap(rows.first);
  }

  /// Replace the server-authoritative mirror with [items].
  ///
  /// Only `synced` rows are cleared; `pending` local writes are preserved so
  /// an outbox entry is never lost during a pull (server is source of truth
  /// for already-synced data only).
  Future<void> replaceAll(List<T> items) async {
    await ensureInitialized();
    await StorageService.deleteAll(
      tableName,
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.synced],
    );
    final now = DateTime.now().toIso8601String();
    final rows = items.map((item) {
      return Map<String, dynamic>.from(toDbMap(item))
        ..['sync_status'] = SyncStatus.synced
        ..['updated_at'] = now;
    }).toList();
    await StorageService.upsertAll(tableName, rows);
  }

  /// Store a server-confirmed row (upsert as `synced`).
  Future<void> saveSynced(T item) async {
    await ensureInitialized();
    final row = Map<String, dynamic>.from(toDbMap(item))
      ..['sync_status'] = SyncStatus.synced
      ..['updated_at'] = DateTime.now().toIso8601String();
    await StorageService.upsertAll(tableName, [row]);
  }

  /// Store an optimistic local write as `pending` (outbox entry) and return
  /// the persisted model (re-read so the caller gets the assigned id).
  ///
  /// When the model has no id yet (offline create) a client UUID is generated.
  Future<T> savePending(T item, {String? withId}) async {
    await ensureInitialized();
    final existingId = idOf(item);
    final id =
        withId ??
        (existingId.isNotEmpty ? existingId : UuidGenerator.generate());
    final row = Map<String, dynamic>.from(toDbMap(item))
      ..['id'] = id
      ..['sync_status'] = SyncStatus.pending
      ..['updated_at'] = DateTime.now().toIso8601String();
    await StorageService.upsertAll(tableName, [row]);
    final stored = await getById(id);
    return stored ?? item;
  }

  /// All rows still awaiting a server push (the outbox for this feature).
  Future<List<T>> getPending() async {
    await ensureInitialized();
    final rows = await StorageService.queryWhere(
      tableName,
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pending],
      orderBy: 'created_at ASC',
    );
    return rows.map(fromDbMap).toList();
  }

  /// Flip a row's status to `synced` (used when a pending row is confirmed
  /// under its existing id).
  Future<void> markSynced(String id) async {
    await ensureInitialized();
    await StorageService.updateWhere(
      tableName,
      {
        'sync_status': SyncStatus.synced,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Remove a row by id (e.g. an optimistic row replaced by the server copy).
  Future<void> deleteById(String id) async {
    await ensureInitialized();
    await StorageService.deleteAll(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
