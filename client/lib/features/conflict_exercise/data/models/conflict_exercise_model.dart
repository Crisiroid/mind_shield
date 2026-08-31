class ConflictExerciseModel {
  final String id;
  final String userId;
  final int scenarioId;
  final int practiceCount;
  final int? performanceScore;
  final int? dayNumber;
  final DateTime? createdAt;

  const ConflictExerciseModel({
    required this.id,
    required this.userId,
    required this.scenarioId,
    this.practiceCount = 0,
    this.performanceScore,
    this.dayNumber,
    this.createdAt,
  });

  factory ConflictExerciseModel.fromJson(Map<String, dynamic> json) {
    return ConflictExerciseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      scenarioId: json['scenario_id'] as int,
      practiceCount: json['practice_count'] as int? ?? 0,
      performanceScore: json['performance_score'] as int?,
      dayNumber: json['day_number'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scenario_id': scenarioId,
      if (performanceScore != null) 'performance_score': performanceScore,
      if (dayNumber != null) 'day_number': dayNumber,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'scenario_id': scenarioId,
      'practice_count': practiceCount,
      'performance_score': performanceScore,
      'day_number': dayNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory ConflictExerciseModel.fromDbMap(Map<String, dynamic> map) {
    return ConflictExerciseModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      scenarioId: map['scenario_id'] as int,
      practiceCount: map['practice_count'] as int? ?? 0,
      performanceScore: map['performance_score'] as int?,
      dayNumber: map['day_number'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
