import '../services/storage_service.dart';
import '../utils/uuid_generator.dart';

class SyncStatus {
  SyncStatus._();

  static const String synced = 'synced';

  static const String pending = 'pending';
}

abstract class SyncableLocalDataSource<T> {
  String get tableName;

  String get createTableSql;

  String idOf(T item);

  Map<String, dynamic> toDbMap(T item);

  T fromDbMap(Map<String, dynamic> map);

  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await StorageService.ensureTable(createTableSql);
    _initialized = true;
  }

  Future<List<T>> getAll() async {
    await ensureInitialized();
    final rows = await StorageService.queryAll(
      tableName,
      orderBy: 'created_at DESC',
    );
    return rows.map(fromDbMap).toList();
  }

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

  Future<void> saveSynced(T item) async {
    await ensureInitialized();
    final row = Map<String, dynamic>.from(toDbMap(item))
      ..['sync_status'] = SyncStatus.synced
      ..['updated_at'] = DateTime.now().toIso8601String();
    await StorageService.upsertAll(tableName, [row]);
  }

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

  Future<void> deleteById(String id) async {
    await ensureInitialized();
    await StorageService.deleteAll(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
