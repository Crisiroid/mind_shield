import '../constants/app_strings.dart';
import '../sync/sync_progress.dart';
import '../sync/syncable_repository.dart';

/// Orchestrates offline-first sync across all registered feature repositories.
///
/// Holds the list of [SyncableRepository] instances injected at construction
/// and coordinates full pulls (server → client) and outbox pushes
/// (client → server). It knows nothing about individual features, so adding a
/// new syncable feature never requires changes here (Open/Closed Principle).
class SyncManager {
  final List<SyncableRepository> _repositories;

  const SyncManager(this._repositories);

  /// Number of features participating in sync.
  int get featureCount => _repositories.length;

  /// Pull every feature's data from the server into the local mirror.
  ///
  /// Per-feature failures are collected rather than aborting the whole run, so
  /// one unreachable endpoint never blocks the rest. [onProgress] is invoked
  /// after each feature with the running counters and a rotating remark.
  /// Returns the list of feature keys that failed to pull.
  Future<List<String>> pullAll({
    void Function(SyncProgress progress)? onProgress,
  }) async {
    final total = _repositories.length;
    final failures = <String>[];
    var done = 0;

    for (final repo in _repositories) {
      onProgress?.call(
        SyncProgress(
          done: done,
          total: total,
          currentFeature: repo.featureKey,
          remark: _remarkFor(done),
        ),
      );
      try {
        await repo.pullFromServer();
      } catch (_) {
        failures.add(repo.featureKey);
      }
      done++;
    }

    onProgress?.call(
      SyncProgress(
        done: done,
        total: total,
        remark: AppStrings.syncCompleted,
        isComplete: true,
      ),
    );
    return failures;
  }

  /// Flush every feature's outbox to the server, then reconcile by pulling the
  /// authoritative state back down. Per-feature push failures are swallowed
  /// (rows stay pending for the next attempt).
  Future<List<String>> pushAll({
    void Function(SyncProgress progress)? onProgress,
  }) async {
    for (final repo in _repositories) {
      try {
        await repo.pushPending();
      } catch (_) {
        // Ignore — pending rows remain queued for the next push.
      }
    }
    return pullAll(onProgress: onProgress);
  }

  /// Pick a calming remark for the current step, cycling through the curated
  /// list so long syncs never show a static message.
  String _remarkFor(int index) {
    final remarks = AppStrings.syncRemarks;
    if (remarks.isEmpty) return AppStrings.syncing;
    return remarks[index % remarks.length];
  }
}
