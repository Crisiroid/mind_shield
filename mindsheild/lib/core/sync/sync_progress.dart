/// Immutable snapshot of an in-flight sync operation.
///
/// Exposed by [AppProvider] via a [ValueListenable] so the sync dialog can
/// render progress without coupling the UI to sync internals.
class SyncProgress {
  /// Number of features finished (successfully or not).
  final int done;

  /// Total number of features being synced.
  final int total;

  /// The feature currently being processed (for logging/diagnostics).
  final String? currentFeature;

  /// A calming, human-friendly remark shown to the user.
  final String remark;

  /// Whether the whole sync run has finished.
  final bool isComplete;

  const SyncProgress({
    this.done = 0,
    this.total = 0,
    this.currentFeature,
    this.remark = '',
    this.isComplete = false,
  });

  /// Fractional progress in the range 0.0–1.0. Returns 0 when [total] is 0.
  double get fraction => total == 0 ? 0 : (done / total).clamp(0.0, 1.0);

  SyncProgress copyWith({
    int? done,
    int? total,
    String? currentFeature,
    String? remark,
    bool? isComplete,
  }) {
    return SyncProgress(
      done: done ?? this.done,
      total: total ?? this.total,
      currentFeature: currentFeature ?? this.currentFeature,
      remark: remark ?? this.remark,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
