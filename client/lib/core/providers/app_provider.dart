import 'package:flutter/material.dart';
import '../services/dialog_service.dart';
import '../services/sync_manager.dart';
import '../services/sync_service.dart';
import '../services/token_service.dart';
import '../sync/sync_progress.dart';
import '../constants/app_strings.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class AppProvider extends ChangeNotifier {
  bool _isOnline = false;
  bool _isSyncing = false;
  String? _lastSyncMessage;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String? get lastSyncMessage => _lastSyncMessage;

  final InternetConnection _connectionChecker;
  final SyncManager _syncManager;

  final ValueNotifier<SyncProgress> progress = ValueNotifier<SyncProgress>(
    const SyncProgress(),
  );

  AppProvider(this._connectionChecker, this._syncManager) {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    _isOnline = await _connectionChecker.hasInternetAccess;

    _connectionChecker.onStatusChange.listen((status) {
      final wasOffline = !_isOnline;
      _isOnline = status == InternetStatus.connected;

      if (wasOffline && _isOnline) {
        _onConnectivityRestored();
      }

      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> runInitialSync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    progress.value = SyncProgress(
      total: _syncManager.featureCount,
      remark: AppStrings.preparingSpace,
    );
    notifyListeners();

    DialogService.showSyncProgress(progress);

    try {
      final failures = await _syncManager.pullAll(
        onProgress: (p) => progress.value = p,
      );
      await TokenService.setNeedsInitialSync(false);
      _lastSyncMessage = failures.isEmpty
          ? AppStrings.syncCompleted
          : AppStrings.dataSynced;
    } catch (e) {
      _lastSyncMessage = AppStrings.dataSyncFailed;
    } finally {
      DialogService.hideSyncProgress();
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _onConnectivityRestored() async {
    _isSyncing = true;
    notifyListeners();

    try {
      await SyncService.processPendingQueue();
      final failures = await _syncManager.pushAll();
      if (failures.isEmpty) {
        _lastSyncMessage = AppStrings.dataSynced;
      } else {
        _lastSyncMessage =
            '${_syncManager.featureCount - failures.length} از ${_syncManager.featureCount} مورد همگام‌سازی شد';
      }
    } catch (e) {
      _lastSyncMessage = AppStrings.dataSyncFailed;
      DialogService.showError(
        title: AppStrings.error,
        message: AppStrings.dataSyncFailed,
      );
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    progress.dispose();
    super.dispose();
  }
}
