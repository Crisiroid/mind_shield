/// Mental must model matching the backend API contract.
///
/// Parses the JSON response from mental-musts endpoints.
class MentalMustModel {
  final String id;
  final String userId;
  final String mustText;
  final String createdDate;
  final bool isReleased;
  final String? releasedDate;
  final int? dayNumber;
  final DateTime? createdAt;

  const MentalMustModel({
    required this.id,
    required this.userId,
    required this.mustText,
    required this.createdDate,
    this.isReleased = false,
    this.releasedDate,
    this.dayNumber,
    this.createdAt,
  });

  factory MentalMustModel.fromJson(Map<String, dynamic> json) {
    return MentalMustModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mustText: json['must_text'] as String,
      createdDate: json['created_date'] as String,
      isReleased: json['is_released'] as bool? ?? false,
      releasedDate: json['released_date'] as String?,
      dayNumber: json['day_number'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'must_text': mustText,
      if (dayNumber != null) 'day_number': dayNumber,
    };
  }

  Map<String, dynamic> toUpdateJson({required bool isReleased}) {
    return {'is_released': isReleased};
  }

  /// Serialize to a local SQLite row (typed columns).
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'must_text': mustText,
      'created_date': createdDate,
      'is_released': isReleased ? 1 : 0,
      'released_date': releasedDate,
      'day_number': dayNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Reconstruct from a local SQLite row.
  factory MentalMustModel.fromDbMap(Map<String, dynamic> map) {
    return MentalMustModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      mustText: map['must_text'] as String? ?? '',
      createdDate: map['created_date'] as String? ?? '',
      isReleased: (map['is_released'] as num?)?.toInt() == 1,
      releasedDate: map['released_date'] as String?,
      dayNumber: (map['day_number'] as num?)?.toInt(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
