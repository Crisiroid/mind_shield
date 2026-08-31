class DayProgressModel {
  final String id;
  final String userId;
  final int weekNumber;
  final int dayNumber;
  final DateTime? openedAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? createdAt;

  const DayProgressModel({
    required this.id,
    required this.userId,
    required this.weekNumber,
    required this.dayNumber,
    this.openedAt,
    this.isCompleted = false,
    this.completedAt,
    this.createdAt,
  });

  factory DayProgressModel.fromJson(Map<String, dynamic> json) {
    return DayProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      weekNumber: json['week_number'] as int,
      dayNumber: json['day_number'] as int,
      openedAt: json['opened_at'] != null
          ? DateTime.tryParse(json['opened_at'] as String)
          : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'week_number': weekNumber, 'day_number': dayNumber};
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'week_number': weekNumber,
      'day_number': dayNumber,
      'opened_at': (openedAt ?? DateTime.now()).toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory DayProgressModel.fromDbMap(Map<String, dynamic> map) {
    return DayProgressModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      weekNumber: (map['week_number'] as num?)?.toInt() ?? 1,
      dayNumber: (map['day_number'] as num?)?.toInt() ?? 1,
      openedAt: map['opened_at'] != null
          ? DateTime.tryParse(map['opened_at'] as String)
          : null,
      isCompleted: (map['is_completed'] as num?)?.toInt() == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
