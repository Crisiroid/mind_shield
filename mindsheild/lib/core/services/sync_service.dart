import 'dart:convert';
import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import '../network/dio_client.dart';
import 'storage_service.dart';

class SyncService {
  SyncService._();

  static const int _maxRetries = 3;

  static Future<SyncResult> processPendingQueue() async {
    final pendingItems = await StorageService.getPendingSyncItems();
    if (pendingItems.isEmpty) {
      return SyncResult(successCount: 0, failCount: 0, total: 0);
    }

    int successCount = 0;
    int failCount = 0;

    for (final item in pendingItems) {
      final id = item['id'] as int;
      final endpoint = item['endpoint'] as String;
      final method = item['method'] as String;
      final payload = jsonDecode(item['payload'] as String);
      final retryCount = item['retry_count'] as int;

      try {
        await _sendRequest(method, endpoint, payload);
        await StorageService.deletePendingSync(id);
        successCount++;
      } catch (e) {
        if (retryCount >= _maxRetries) {
          await StorageService.deletePendingSync(id);
          failCount++;
        } else {
          await StorageService.incrementRetryCount(id);
        }
      }
    }

    return SyncResult(
      successCount: successCount,
      failCount: failCount,
      total: pendingItems.length,
    );
  }

  static Future<void> queueForSync({
    required String endpoint,
    required String method,
    required Map<String, dynamic> payload,
  }) async {
    await StorageService.insertPendingSync(
      endpoint: endpoint,
      method: method,
      payload: jsonEncode(payload),
    );
  }

  static Future<Response> _sendRequest(
    String method,
    String endpoint,
    dynamic data,
  ) async {
    final dio = DioClient.instance;
    switch (method.toUpperCase()) {
      case 'POST':
        return dio.post(endpoint, data: data);
      case 'PUT':
        return dio.put(endpoint, data: data);
      case 'PATCH':
        return dio.patch(endpoint, data: data);
      case 'DELETE':
        return dio.delete(endpoint, data: data);
      default:
        return dio.get(endpoint);
    }
  }
}

class SyncResult {
  final int successCount;
  final int failCount;
  final int total;

  const SyncResult({
    required this.successCount,
    required this.failCount,
    required this.total,
  });

  bool get hasFailures => failCount > 0;
  bool get allSucceeded => successCount == total;
}
