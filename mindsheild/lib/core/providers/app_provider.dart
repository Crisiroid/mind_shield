import 'package:flutter/material.dart';
import '../services/dialog_service.dart';
import '../services/sync_manager.dart';
import '../services/sync_service.dart';
import '../services/token_service.dart';
import '../sync/sync_progress.dart';
import '../constants/app_strings.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Root application provider that manages connectivity state, drives the
/// offline-first sync lifecycle, and triggers background sync when internet
/// is restored.
///
/// Uses Provider for state management as per project convention. Sync work is
/// delegated to [SyncManager] (Dependency Inversion) so this provider never
/// knows about individual features.
class AppProvider extends ChangeNotifier {
  bool _isOnline = false;
  bool _isSyncing = false;
  String? _lastSyncMessage;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String? get lastSyncMessage => _lastSyncMessage;

  final InternetConnection _connectionChecker;
  final SyncManager _syncManager;

  /// Live progress of the current sync run, observed by the sync dialog.
  final ValueNotifier<SyncProgress> progress = ValueNotifier<SyncProgress>(
    const SyncProgress(),
  );

  AppProvider(this._connectionChecker, this._syncManager) {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    _isOnline = await _connectionChecker.hasInternetAccess;

    // Listen for connectivity changes
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

  /// Run the first server→client pull after successful authentication.
  ///
  /// Shows the animated sync dialog, populates every local table from the
  /// server, then clears the [TokenService.needsInitialSync] flag. Safe to
  /// call when offline — it simply completes without data and the flag stays
  /// set so the pull is retried on the next launch.
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
      // Consider the initial sync done even with partial failures — the
      // reconcile-on-reconnect path will retry the stragglers.
      await TokenService.setNeedsInitialSync(false);
      _lastSyncMessage = failures.isEmpty
          ? AppStrings.syncCompleted
          : AppStrings.dataSynced;
    } catch (e) {
      _lastSyncMessage = AppStrings.dataSyncFailed;
    } finally {
      // Ensure the dialog dismisses even if no completion frame fired.
      DialogService.hideSyncProgress();
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _onConnectivityRestored() async {
    _isSyncing = true;
    notifyListeners();

    try {
      // Flush the legacy generic outbox first (backward compatible), then
      // push every feature's pending writes and reconcile via a full pull.
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
