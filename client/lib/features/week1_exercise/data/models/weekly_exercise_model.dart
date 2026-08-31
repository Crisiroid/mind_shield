class WeeklyExerciseModel {
  final String id;
  final String userId;
  final int weekNumber;
  final int dayNumber;
  final String exerciseType;
  final String responseData;
  final DateTime? completedAt;
  final DateTime? createdAt;

  const WeeklyExerciseModel({
    required this.id,
    required this.userId,
    required this.weekNumber,
    required this.dayNumber,
    required this.exerciseType,
    required this.responseData,
    this.completedAt,
    this.createdAt,
  });

  factory WeeklyExerciseModel.fromJson(Map<String, dynamic> json) {
    return WeeklyExerciseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      weekNumber: json['week_number'] as int,
      dayNumber: json['day_number'] as int,
      exerciseType: json['exercise_type'] as String,
      responseData: json['response_data'] as String? ?? '{}',
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_number': weekNumber,
      'day_number': dayNumber,
      'exercise_type': exerciseType,
      'response_data': responseData,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'response_data': responseData,
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'week_number': weekNumber,
      'day_number': dayNumber,
      'exercise_type': exerciseType,
      'response_data': responseData,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory WeeklyExerciseModel.fromDbMap(Map<String, dynamic> map) {
    return WeeklyExerciseModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      weekNumber: (map['week_number'] as num?)?.toInt() ?? 1,
      dayNumber: (map['day_number'] as num?)?.toInt() ?? 1,
      exerciseType: map['exercise_type'] as String? ?? '',
      responseData: map['response_data'] as String? ?? '{}',
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
