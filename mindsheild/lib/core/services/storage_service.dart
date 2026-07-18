import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../errors/exceptions.dart';

/// Local SQLite database service for offline data storage.
///
/// Handles all database operations in one place so feature repositories
/// can delegate persistence without knowing SQL details
/// (Single Responsibility Principle).
class StorageService {
  StorageService._();

  static Database? _database;

  static Database get database {
    if (_database == null) {
      throw const CacheException(
        message: 'Database not initialized. Call init() first.',
      );
    }
    return _database!;
  }

  /// Initialize the SQLite database. Call once at app startup.
  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'mindsheild.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create all tables on first run.
  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // Pending sync queue — stores data to sync when online
    batch.execute('''
      CREATE TABLE IF NOT EXISTS pending_sync (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        endpoint TEXT NOT NULL,
        method TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // User data cache
    batch.execute('''
      CREATE TABLE IF NOT EXISTS user_cache (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // App settings
    batch.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await batch.commit(noResult: true);
  }

  /// Handle database upgrades.
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Future migrations go here
  }

  // ─── Generic Typed-Table Helpers ────────────────────────────
  //
  // Feature local datasources own their own table schema and create it
  // lazily via [ensureTable]. StorageService stays the single DB gateway
  // (Single Responsibility) without importing any feature code
  // (Open/Closed) — new feature tables need no changes here.

  static final Set<String> _ensuredDdl = <String>{};

  /// Run a `CREATE TABLE IF NOT EXISTS` statement once per session.
  /// [ddl] must be the full create statement; it is de-duplicated so calling
  /// this on every datasource access is cheap.
  static Future<void> ensureTable(String ddl) async {
    if (_ensuredDdl.contains(ddl)) return;
    await database.execute(ddl);
    _ensuredDdl.add(ddl);
  }

  /// Insert or replace a batch of rows in [table] (upsert by primary key).
  static Future<void> upsertAll(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return;
    final batch = database.batch();
    for (final row in rows) {
      batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Query all rows from [table], optionally filtered/ordered.
  static Future<List<Map<String, dynamic>>> queryAll(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    return database.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  /// Convenience wrapper around [queryAll] for filtered reads.
  static Future<List<Map<String, dynamic>>> queryWhere(
    String table, {
    required String where,
    required List<Object?> whereArgs,
    String? orderBy,
  }) async {
    return queryAll(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  /// Delete rows from [table]; deletes everything when no filter is given.
  static Future<int> deleteAll(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return database.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Update matching rows in [table] with [values].
  static Future<int> updateWhere(
    String table,
    Map<String, dynamic> values, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    return database.update(table, values, where: where, whereArgs: whereArgs);
  }

  // ─── Pending Sync Operations ────────────────────────────────

  static Future<int> insertPendingSync({
    required String endpoint,
    required String method,
    required String payload,
  }) async {
    return database.insert('pending_sync', {
      'endpoint': endpoint,
      'method': method,
      'payload': payload,
    });
  }

  static Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    return database.query('pending_sync', orderBy: 'created_at ASC');
  }

  static Future<int> deletePendingSync(int id) async {
    return database.delete('pending_sync', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> incrementRetryCount(int id) async {
    return database.rawUpdate(
      'UPDATE pending_sync SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  // ─── Key-Value Cache ────────────────────────────────────────

  static Future<void> putCache(String key, String value) async {
    await database.insert('user_cache', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<String?> getCache(String key) async {
    final result = await database.query(
      'user_cache',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String;
  }

  static Future<int> deleteCache(String key) async {
    return database.delete('user_cache', where: 'key = ?', whereArgs: [key]);
  }

  // ─── App Settings ───────────────────────────────────────────

  static Future<void> putSetting(String key, String value) async {
    await database.insert('app_settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<String?> getSetting(String key) async {
    final result = await database.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String;
  }

  /// Close the database connection.
  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
