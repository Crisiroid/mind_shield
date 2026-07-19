class BreathingSessionModel {
  final String id;
  final String userId;
  final DateTime sessionStart;
  final DateTime? sessionEnd;
  final int? durationSeconds;
  final String? breathingPattern;
  final bool isCompleted;
  final bool calendarTicked;
  final int? dayNumber;
  final DateTime? createdAt;

  const BreathingSessionModel({
    required this.id,
    required this.userId,
    required this.sessionStart,
    this.sessionEnd,
    this.durationSeconds,
    this.breathingPattern,
    this.isCompleted = false,
    this.calendarTicked = false,
    this.dayNumber,
    this.createdAt,
  });

  factory BreathingSessionModel.fromJson(Map<String, dynamic> json) {
    return BreathingSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sessionStart: DateTime.parse(json['session_start'] as String),
      sessionEnd: json['session_end'] != null
          ? DateTime.tryParse(json['session_end'] as String)
          : null,
      durationSeconds: json['duration_seconds'] as int?,
      breathingPattern: json['breathing_pattern'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      calendarTicked: json['calendar_ticked'] as bool? ?? false,
      dayNumber: json['day_number'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (breathingPattern != null) 'breathing_pattern': breathingPattern,
      if (dayNumber != null) 'day_number': dayNumber,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      if (sessionEnd != null) 'session_end': sessionEnd!.toIso8601String(),
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      'is_completed': isCompleted,
      'calendar_ticked': calendarTicked,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'session_start': sessionStart.toIso8601String(),
      'session_end': sessionEnd?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'breathing_pattern': breathingPattern,
      'is_completed': isCompleted ? 1 : 0,
      'calendar_ticked': calendarTicked ? 1 : 0,
      'day_number': dayNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory BreathingSessionModel.fromDbMap(Map<String, dynamic> map) {
    return BreathingSessionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      sessionStart:
          DateTime.tryParse(map['session_start'] as String? ?? '') ??
          DateTime.now(),
      sessionEnd: map['session_end'] != null
          ? DateTime.tryParse(map['session_end'] as String)
          : null,
      durationSeconds: (map['duration_seconds'] as num?)?.toInt(),
      breathingPattern: map['breathing_pattern'] as String?,
      isCompleted: (map['is_completed'] as num?)?.toInt() == 1,
      calendarTicked: (map['calendar_ticked'] as num?)?.toInt() == 1,
      dayNumber: (map['day_number'] as num?)?.toInt(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
