class WeeklyMediaModel {
  final String id;
  final int weekNumber;
  final String fileType;
  final String? description;
  final String? storagePath;
  final String? originalName;
  final bool isActive;
  final int downloadCount;
  final DateTime? createdAt;

  const WeeklyMediaModel({
    required this.id,
    required this.weekNumber,
    required this.fileType,
    this.description,
    this.storagePath,
    this.originalName,
    this.isActive = true,
    this.downloadCount = 0,
    this.createdAt,
  });

  factory WeeklyMediaModel.fromJson(Map<String, dynamic> json) {
    return WeeklyMediaModel(
      id: json['id'] as String,
      weekNumber: json['week_number'] as int,
      fileType: json['file_type'] as String? ?? '',
      description: json['description'] as String?,
      storagePath: json['storage_path'] as String?,
      originalName: json['original_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      downloadCount: json['download_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  String? get fileUrl =>
      storagePath != null ? 'http://10.0.2.2:8080/uploads/$storagePath' : null;
}
