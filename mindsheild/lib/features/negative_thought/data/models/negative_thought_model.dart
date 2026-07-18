/// Negative thought model matching the backend API contract.
///
/// Parses the JSON response from negative-thoughts endpoints.
class NegativeThoughtModel {
  final String id;
  final String userId;
  final String thoughtText;
  final String? situation;
  final String? cognitiveErrorType;
  final int? impactLevel;
  final String? recordedAt;
  final int? dayNumber;
  final DateTime? createdAt;

  const NegativeThoughtModel({
    required this.id,
    required this.userId,
    required this.thoughtText,
    this.situation,
    this.cognitiveErrorType,
    this.impactLevel,
    this.recordedAt,
    this.dayNumber,
    this.createdAt,
  });

  factory NegativeThoughtModel.fromJson(Map<String, dynamic> json) {
    return NegativeThoughtModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      thoughtText: json['thought_text'] as String,
      situation: json['situation'] as String?,
      cognitiveErrorType: json['cognitive_error_type'] as String?,
      impactLevel: json['impact_level'] as int?,
      recordedAt: json['recorded_at'] as String?,
      dayNumber: json['day_number'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thought_text': thoughtText,
      if (situation != null) 'situation': situation,
      if (cognitiveErrorType != null)
        'cognitive_error_type': cognitiveErrorType,
      if (impactLevel != null) 'impact_level': impactLevel,
      if (dayNumber != null) 'day_number': dayNumber,
    };
  }

  /// Serialize to a local SQLite row (typed columns).
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'thought_text': thoughtText,
      'situation': situation,
      'cognitive_error_type': cognitiveErrorType,
      'impact_level': impactLevel,
      'recorded_at': recordedAt,
      'day_number': dayNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Reconstruct from a local SQLite row.
  factory NegativeThoughtModel.fromDbMap(Map<String, dynamic> map) {
    return NegativeThoughtModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      thoughtText: map['thought_text'] as String? ?? '',
      situation: map['situation'] as String?,
      cognitiveErrorType: map['cognitive_error_type'] as String?,
      impactLevel: (map['impact_level'] as num?)?.toInt(),
      recordedAt: map['recorded_at'] as String?,
      dayNumber: (map['day_number'] as num?)?.toInt(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
