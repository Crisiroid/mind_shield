import '../constants/app_strings.dart';
import '../sync/sync_progress.dart';
import '../sync/syncable_repository.dart';

class SyncManager {
  final List<SyncableRepository> _repositories;

  const SyncManager(this._repositories);

  int get featureCount => _repositories.length;

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

  Future<List<String>> pushAll({
    void Function(SyncProgress progress)? onProgress,
  }) async {
    for (final repo in _repositories) {
      try {
        await repo.pushPending();
      } catch (_) {}
    }
    return pullAll(onProgress: onProgress);
  }

  String _remarkFor(int index) {
    final remarks = AppStrings.syncRemarks;
    if (remarks.isEmpty) return AppStrings.syncing;
    return remarks[index % remarks.length];
  }
}
