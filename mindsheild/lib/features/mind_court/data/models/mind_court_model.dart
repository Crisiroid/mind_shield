class MindCourtModel {
  final String id;
  final String userId;
  final String negativeThoughtId;
  final String? supportingEvidence;
  final String? contradictingEvidence;
  final bool guideHelperUsed;
  final String? alternativeThought;
  final int? dayNumber;
  final DateTime? createdAt;

  const MindCourtModel({
    required this.id,
    required this.userId,
    required this.negativeThoughtId,
    this.supportingEvidence,
    this.contradictingEvidence,
    this.guideHelperUsed = false,
    this.alternativeThought,
    this.dayNumber,
    this.createdAt,
  });

  factory MindCourtModel.fromJson(Map<String, dynamic> json) {
    return MindCourtModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      negativeThoughtId: json['negative_thought_id'] as String,
      supportingEvidence: json['supporting_evidence'] as String?,
      contradictingEvidence: json['contradicting_evidence'] as String?,
      guideHelperUsed: json['guide_helper_used'] as bool? ?? false,
      alternativeThought: json['alternative_thought'] as String?,
      dayNumber: json['day_number'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'negative_thought_id': negativeThoughtId,
      if (supportingEvidence != null) 'supporting_evidence': supportingEvidence,
      if (contradictingEvidence != null)
        'contradicting_evidence': contradictingEvidence,
      'guide_helper_used': guideHelperUsed,
      if (alternativeThought != null) 'alternative_thought': alternativeThought,
      if (dayNumber != null) 'day_number': dayNumber,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'negative_thought_id': negativeThoughtId,
      'supporting_evidence': supportingEvidence,
      'contradicting_evidence': contradictingEvidence,
      'guide_helper_used': guideHelperUsed ? 1 : 0,
      'alternative_thought': alternativeThought,
      'day_number': dayNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory MindCourtModel.fromDbMap(Map<String, dynamic> map) {
    return MindCourtModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      negativeThoughtId: map['negative_thought_id'] as String? ?? '',
      supportingEvidence: map['supporting_evidence'] as String?,
      contradictingEvidence: map['contradicting_evidence'] as String?,
      guideHelperUsed: (map['guide_helper_used'] as num?)?.toInt() == 1,
      alternativeThought: map['alternative_thought'] as String?,
      dayNumber: (map['day_number'] as num?)?.toInt(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
