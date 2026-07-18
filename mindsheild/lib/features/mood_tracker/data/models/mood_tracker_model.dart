/// Mood tracker model matching the backend API contract.
///
/// Represents one before/after mood measurement tied to a micro-activity,
/// proving the effect of small activities on mood.
class MoodTrackerModel {
  final String id;
  final String userId;
  final String? activityId;
  final String? activityName;
  final int moodBefore;
  final int moodAfter;
  final int? moodDelta;
  final String? notes;
  final int? dayNumber;
  final DateTime? createdAt;

  const MoodTrackerModel({
    required this.id,
    required this.userId,
    this.activityId,
    this.activityName,
    required this.moodBefore,
    required this.moodAfter,
    this.moodDelta,
    this.notes,
    this.dayNumber,
    this.createdAt,
  });

  /// Computed delta (after - before) when the backend value is absent.
  int get delta => moodDelta ?? (moodAfter - moodBefore);

  factory MoodTrackerModel.fromJson(Map<String, dynamic> json) {
    return MoodTrackerModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      activityId: json['activity_id'] as String?,
      activityName: json['activity_name'] as String?,
      moodBefore: json['mood_before'] as int? ?? 0,
      moodAfter: json['mood_after'] as int? ?? 0,
      moodDelta: json['mood_delta'] as int?,
      notes: json['notes'] as String?,
      dayNumber: json['day_number'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (activityName != null && activityName!.isNotEmpty)
        'activity_name': activityName,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (dayNumber != null) 'day_number': dayNumber,
    };
  }

  /// Serialize to a local SQLite row (typed columns).
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'activity_id': activityId,
      'activity_name': activityName,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'mood_delta': moodDelta,
      'notes': notes,
      'day_number': dayNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Reconstruct from a local SQLite row.
  factory MoodTrackerModel.fromDbMap(Map<String, dynamic> map) {
    return MoodTrackerModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      activityId: map['activity_id'] as String?,
      activityName: map['activity_name'] as String?,
      moodBefore: (map['mood_before'] as num?)?.toInt() ?? 0,
      moodAfter: (map['mood_after'] as num?)?.toInt() ?? 0,
      moodDelta: (map['mood_delta'] as num?)?.toInt(),
      notes: map['notes'] as String?,
      dayNumber: (map['day_number'] as num?)?.toInt(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
