/// Cognitive game model matching the backend API contract.
///
/// Parses the JSON response from cognitive-games endpoints.
class CognitiveGameModel {
  final String id;
  final String userId;
  final String gameDate;
  final int scenarioId;
  final String? scenarioType;
  final int? score;
  final bool? isCorrect;
  final int? timeTakenSeconds;
  final int? dayNumber;
  final DateTime? createdAt;

  const CognitiveGameModel({
    required this.id,
    required this.userId,
    required this.gameDate,
    required this.scenarioId,
    this.scenarioType,
    this.score,
    this.isCorrect,
    this.timeTakenSeconds,
    this.dayNumber,
    this.createdAt,
  });

  factory CognitiveGameModel.fromJson(Map<String, dynamic> json) {
    return CognitiveGameModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      gameDate: json['game_date'] as String,
      scenarioId: json['scenario_id'] as int,
      scenarioType: json['scenario_type'] as String?,
      score: json['score'] as int?,
      isCorrect: json['is_correct'] as bool?,
      timeTakenSeconds: json['time_taken_seconds'] as int?,
      dayNumber: json['day_number'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scenario_id': scenarioId,
      if (scenarioType != null) 'scenario_type': scenarioType,
      if (score != null) 'score': score,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (timeTakenSeconds != null) 'time_taken_seconds': timeTakenSeconds,
      if (dayNumber != null) 'day_number': dayNumber,
    };
  }

  /// Serialize to a local SQLite row (typed columns).
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'game_date': gameDate,
      'scenario_id': scenarioId,
      'scenario_type': scenarioType,
      'score': score,
      'is_correct': isCorrect == null ? null : (isCorrect! ? 1 : 0),
      'time_taken_seconds': timeTakenSeconds,
      'day_number': dayNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Rebuild from a local SQLite row.
  factory CognitiveGameModel.fromDbMap(Map<String, dynamic> map) {
    return CognitiveGameModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      gameDate: map['game_date'] as String,
      scenarioId: map['scenario_id'] as int,
      scenarioType: map['scenario_type'] as String?,
      score: map['score'] as int?,
      isCorrect: map['is_correct'] == null
          ? null
          : (map['is_correct'] as int) == 1,
      timeTakenSeconds: map['time_taken_seconds'] as int?,
      dayNumber: map['day_number'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
