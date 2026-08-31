class RoleValueModel {
  final String id;
  final String userId;
  final String entryType;
  final String entryText;
  final int? dayNumber;
  final DateTime? createdAt;

  const RoleValueModel({
    required this.id,
    required this.userId,
    required this.entryType,
    required this.entryText,
    this.dayNumber,
    this.createdAt,
  });

  bool get isRole => entryType == 'role';
  bool get isValue => entryType == 'value';

  factory RoleValueModel.fromJson(Map<String, dynamic> json) {
    return RoleValueModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      entryType: json['entry_type'] as String? ?? 'role',
      entryText: json['entry_text'] as String? ?? '',
      dayNumber: json['day_number'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entry_type': entryType,
      'entry_text': entryText,
      if (dayNumber != null) 'day_number': dayNumber,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'entry_type': entryType,
      'entry_text': entryText,
      'day_number': dayNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory RoleValueModel.fromDbMap(Map<String, dynamic> map) {
    return RoleValueModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      entryType: map['entry_type'] as String? ?? 'role',
      entryText: map['entry_text'] as String? ?? '',
      dayNumber: (map['day_number'] as num?)?.toInt(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
