/// Watched / progress status values shared with the backend
/// (`not_started | in_progress | completed`).
class MediaProgressStatus {
  MediaProgressStatus._();

  static const String notStarted = 'not_started';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
}

/// Per-user watched/progress state for a single piece of weekly media content.
///
/// The backend keys progress by `(user_id, media_content_id)` and exposes an
/// idempotent upsert, so [mediaContentId] is the stable business key while
/// [id] is the progress record's own identifier (a local UUID until the row
/// has been synced, then the server id).
class MediaProgressModel {
  final String id;
  final String mediaContentId;
  final String status;
  final int progressSeconds;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MediaProgressModel({
    required this.id,
    required this.mediaContentId,
    this.status = MediaProgressStatus.notStarted,
    this.progressSeconds = 0,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isCompleted => status == MediaProgressStatus.completed;
  bool get isInProgress => status == MediaProgressStatus.inProgress;

  MediaProgressModel copyWith({
    String? id,
    String? mediaContentId,
    String? status,
    int? progressSeconds,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaProgressModel(
      id: id ?? this.id,
      mediaContentId: mediaContentId ?? this.mediaContentId,
      status: status ?? this.status,
      progressSeconds: progressSeconds ?? this.progressSeconds,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory MediaProgressModel.fromJson(Map<String, dynamic> json) {
    return MediaProgressModel(
      id: json['id'] as String? ?? '',
      mediaContentId: json['media_content_id'] as String? ?? '',
      status: json['status'] as String? ?? MediaProgressStatus.notStarted,
      progressSeconds: (json['progress_seconds'] as num?)?.toInt() ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Payload for the `PUT /media/progress/:media_id` upsert endpoint.
  Map<String, dynamic> toUpsertJson() {
    return {'status': status, 'progress_seconds': progressSeconds};
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'media_content_id': mediaContentId,
      'status': status,
      'progress_seconds': progressSeconds,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory MediaProgressModel.fromDbMap(Map<String, dynamic> map) {
    return MediaProgressModel(
      id: map['id'] as String,
      mediaContentId: map['media_content_id'] as String? ?? '',
      status: map['status'] as String? ?? MediaProgressStatus.notStarted,
      progressSeconds: (map['progress_seconds'] as num?)?.toInt() ?? 0,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }
}
