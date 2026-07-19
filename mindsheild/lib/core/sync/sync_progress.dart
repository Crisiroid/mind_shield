class SyncProgress {
  final int done;

  final int total;

  final String? currentFeature;

  final String remark;

  final bool isComplete;

  const SyncProgress({
    this.done = 0,
    this.total = 0,
    this.currentFeature,
    this.remark = '',
    this.isComplete = false,
  });

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
