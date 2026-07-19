class StressEventModel {
  final String id;
  final String userId;
  final DateTime eventTimestamp;
  final String situationType;
  final String? situationDescription;
  final int intensityLevel;
  final String? location;
  final int? dayNumber;
  final DateTime? createdAt;

  const StressEventModel({
    required this.id,
    required this.userId,
    required this.eventTimestamp,
    required this.situationType,
    this.situationDescription,
    required this.intensityLevel,
    this.location,
    this.dayNumber,
    this.createdAt,
  });

  factory StressEventModel.fromJson(Map<String, dynamic> json) {
    return StressEventModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventTimestamp: DateTime.parse(json['event_timestamp'] as String),
      situationType: json['situation_type'] as String,
      situationDescription: json['situation_description'] as String?,
      intensityLevel: json['intensity_level'] as int,
      location: json['location'] as String?,
      dayNumber: json['day_number'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'situation_type': situationType,
      if (situationDescription != null)
        'situation_description': situationDescription,
      'intensity_level': intensityLevel,
      if (location != null) 'location': location,
      if (dayNumber != null) 'day_number': dayNumber,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'event_timestamp': eventTimestamp.toIso8601String(),
      'situation_type': situationType,
      'situation_description': situationDescription,
      'intensity_level': intensityLevel,
      'location': location,
      'day_number': dayNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory StressEventModel.fromDbMap(Map<String, dynamic> map) {
    return StressEventModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      eventTimestamp:
          DateTime.tryParse(map['event_timestamp'] as String? ?? '') ??
          DateTime.now(),
      situationType: map['situation_type'] as String? ?? '',
      situationDescription: map['situation_description'] as String?,
      intensityLevel: (map['intensity_level'] as num?)?.toInt() ?? 0,
      location: map['location'] as String?,
      dayNumber: (map['day_number'] as num?)?.toInt(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
