import '../../../../core/constants/api_constants.dart';

class WeeklyMediaModel {
  final String id;
  final int weekNumber;
  final String fileType;
  final String? description;
  final String? fileUrlPath;
  final String? fileName;
  final String? originalName;
  final String? contentType;
  final int fileSize;
  final bool isActive;
  final int downloadCount;
  final DateTime? createdAt;

  const WeeklyMediaModel({
    required this.id,
    required this.weekNumber,
    required this.fileType,
    this.description,
    this.fileUrlPath,
    this.fileName,
    this.originalName,
    this.contentType,
    this.fileSize = 0,
    this.isActive = true,
    this.downloadCount = 0,
    this.createdAt,
  });

  factory WeeklyMediaModel.fromJson(Map<String, dynamic> json) {
    return WeeklyMediaModel(
      id: json['id'] as String,
      weekNumber: json['week_number'] as int? ?? 0,
      fileType: json['file_type'] as String? ?? '',
      description: json['description'] as String?,
      fileUrlPath: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      originalName: json['original_name'] as String?,
      contentType: json['content_type'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      downloadCount: json['download_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Serializes back to the API/JSON shape so the model can be persisted in the
  /// local content cache and rebuilt with [WeeklyMediaModel.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week_number': weekNumber,
      'file_type': fileType,
      'description': description,
      'file_url': fileUrlPath,
      'file_name': fileName,
      'original_name': originalName,
      'content_type': contentType,
      'file_size': fileSize,
      'is_active': isActive,
      'download_count': downloadCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Absolute URL to the publicly-served media file. The backend returns a
  /// relative path like `/api/v1/media/weekly/files/<name>`, so it is prefixed
  /// with the API base URL to produce a directly-streamable URL.
  String? get fileUrl {
    final path = fileUrlPath;
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '${ApiConstants.baseUrl}$path';
  }
}
