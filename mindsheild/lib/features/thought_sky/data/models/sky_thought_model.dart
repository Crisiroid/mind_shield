/// Sky Thought model matching the backend `sky-thoughts` API contract.
///
/// Represents a single negative thought that the user externalizes as a
/// drifting cloud, and can "swipe away" to let it pass across the sky.
class SkyThoughtModel {
  final String id;
  final String userId;
  final String thoughtText;
  final bool cloudSwiped;
  final int? dayNumber;
  final DateTime? createdAt;

  const SkyThoughtModel({
    required this.id,
    required this.userId,
    required this.thoughtText,
    this.cloudSwiped = false,
    this.dayNumber,
    this.createdAt,
  });

  factory SkyThoughtModel.fromJson(Map<String, dynamic> json) {
    return SkyThoughtModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      thoughtText: json['thought_text'] as String? ?? '',
      cloudSwiped: json['cloud_swiped'] as bool? ?? false,
      dayNumber: json['day_number'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thought_text': thoughtText,
      if (dayNumber != null) 'day_number': dayNumber,
    };
  }

  SkyThoughtModel copyWith({bool? cloudSwiped}) {
    return SkyThoughtModel(
      id: id,
      userId: userId,
      thoughtText: thoughtText,
      cloudSwiped: cloudSwiped ?? this.cloudSwiped,
      dayNumber: dayNumber,
      createdAt: createdAt,
    );
  }

  /// Serialize to a local SQLite row (typed columns).
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'thought_text': thoughtText,
      'cloud_swiped': cloudSwiped ? 1 : 0,
      'day_number': dayNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Reconstruct from a local SQLite row.
  factory SkyThoughtModel.fromDbMap(Map<String, dynamic> map) {
    return SkyThoughtModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      thoughtText: map['thought_text'] as String? ?? '',
      cloudSwiped: (map['cloud_swiped'] as num?)?.toInt() == 1,
      dayNumber: (map['day_number'] as num?)?.toInt(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
