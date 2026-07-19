import 'dart:convert';

class EmotionInteractionModel {
  final String id;
  final String userId;
  final DateTime interactionDate;
  final String sideClicked;
  final List<String> thoughtAccountsViewed;
  final bool vibrationTriggered;
  final int? dayNumber;
  final DateTime? createdAt;

  const EmotionInteractionModel({
    required this.id,
    required this.userId,
    required this.interactionDate,
    required this.sideClicked,
    this.thoughtAccountsViewed = const [],
    this.vibrationTriggered = false,
    this.dayNumber,
    this.createdAt,
  });

  factory EmotionInteractionModel.fromJson(Map<String, dynamic> json) {
    return EmotionInteractionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      interactionDate: DateTime.parse(json['interaction_date'] as String),
      sideClicked: json['side_clicked'] as String,
      thoughtAccountsViewed:
          (json['thought_accounts_viewed'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      vibrationTriggered: json['vibration_triggered'] as bool? ?? false,
      dayNumber: json['day_number'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'side_clicked': sideClicked,
      'thought_accounts_viewed': thoughtAccountsViewed,
      'vibration_triggered': vibrationTriggered,
      if (dayNumber != null) 'day_number': dayNumber,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'interaction_date': interactionDate.toIso8601String(),
      'side_clicked': sideClicked,
      'thought_accounts_viewed': jsonEncode(thoughtAccountsViewed),
      'vibration_triggered': vibrationTriggered ? 1 : 0,
      'day_number': dayNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory EmotionInteractionModel.fromDbMap(Map<String, dynamic> map) {
    return EmotionInteractionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      interactionDate: DateTime.parse(map['interaction_date'] as String),
      sideClicked: map['side_clicked'] as String,
      thoughtAccountsViewed:
          (jsonDecode(map['thought_accounts_viewed'] as String? ?? '[]')
                  as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      vibrationTriggered: (map['vibration_triggered'] as int? ?? 0) == 1,
      dayNumber: map['day_number'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
