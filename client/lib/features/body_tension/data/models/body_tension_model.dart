class BodyTensionModel {
  final String id;
  final String userId;
  final DateTime mappingDate;
  final String bodyRegions;
  final int? overallIntensity;
  final String? severityColor;
  final String? notes;
  final int? dayNumber;
  final DateTime? createdAt;

  const BodyTensionModel({
    required this.id,
    required this.userId,
    required this.mappingDate,
    required this.bodyRegions,
    this.overallIntensity,
    this.severityColor,
    this.notes,
    this.dayNumber,
    this.createdAt,
  });

  factory BodyTensionModel.fromJson(Map<String, dynamic> json) {
    return BodyTensionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mappingDate: DateTime.parse(json['mapping_date'] as String),
      bodyRegions: json['body_regions'] as String,
      overallIntensity: json['overall_intensity'] as int?,
      severityColor: json['severity_color'] as String?,
      notes: json['notes'] as String?,
      dayNumber: json['day_number'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body_regions': bodyRegions,
      if (overallIntensity != null) 'overall_intensity': overallIntensity,
      if (severityColor != null) 'severity_color': severityColor,
      if (notes != null) 'notes': notes,
      if (dayNumber != null) 'day_number': dayNumber,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'mapping_date': mappingDate.toIso8601String(),
      'body_regions': bodyRegions,
      'overall_intensity': overallIntensity,
      'severity_color': severityColor,
      'notes': notes,
      'day_number': dayNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory BodyTensionModel.fromDbMap(Map<String, dynamic> map) {
    return BodyTensionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      mappingDate: DateTime.parse(map['mapping_date'] as String),
      bodyRegions: map['body_regions'] as String,
      overallIntensity: map['overall_intensity'] as int?,
      severityColor: map['severity_color'] as String?,
      notes: map['notes'] as String?,
      dayNumber: map['day_number'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
