import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/weekly_media_model.dart';

/// Contract for home screen remote operations.
///
/// Interface Segregation Principle — the repository depends only
/// on the methods it needs, not the full HTTP implementation.
abstract class HomeRemoteDataSource {
  /// Fetch weekly media content for a specific week.
  Future<List<WeeklyMediaModel>> getMediaByWeek({
    required int weekNumber,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetch all active weekly media content.
  Future<List<WeeklyMediaModel>> getAllMedia({int page = 1, int pageSize = 20});
}

/// Implementation using Dio HTTP client.
///
/// Handles all remote home screen API calls and response parsing.
/// Throws [AppException] (mapped by the interceptor) on failures.
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio _dio;

  HomeRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<List<WeeklyMediaModel>> getMediaByWeek({
    required int weekNumber,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.weeklyMedia}/by-week/$weekNumber',
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (apiResponse.data == null) return [];

    final data = apiResponse.data!;
    final items =
        data['items'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];

    return items
        .map((item) => WeeklyMediaModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WeeklyMediaModel>> getAllMedia({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.weeklyMedia,
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (apiResponse.data == null) return [];

    final data = apiResponse.data!;
    final items =
        data['items'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];

    return items
        .map((item) => WeeklyMediaModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
