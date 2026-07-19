import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../errors/exceptions.dart';

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

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

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

    batch.execute('''
      CREATE TABLE IF NOT EXISTS user_cache (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    batch.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await batch.commit(noResult: true);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {}

  static final Set<String> _ensuredDdl = <String>{};

  static Future<void> ensureTable(String ddl) async {
    if (_ensuredDdl.contains(ddl)) return;
    await database.execute(ddl);
    _ensuredDdl.add(ddl);
  }

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

  static Future<int> deleteAll(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return database.delete(table, where: where, whereArgs: whereArgs);
  }

  static Future<int> updateWhere(
    String table,
    Map<String, dynamic> values, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    return database.update(table, values, where: where, whereArgs: whereArgs);
  }

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

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
