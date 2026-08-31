import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/mood_tracker_model.dart';

abstract class MoodTrackerRemoteDataSource {
  Future<WriteResult<MoodTrackerModel>> createMoodTracker({
    required MoodTrackerModel mood,
  });

  Future<List<MoodTrackerModel>> listMoodTrackers({
    int page = 1,
    int pageSize = 20,
  });
}

class MoodTrackerRemoteDataSourceImpl implements MoodTrackerRemoteDataSource {
  final Dio _dio;

  MoodTrackerRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<WriteResult<MoodTrackerModel>> createMoodTracker({
    required MoodTrackerModel mood,
  }) async {
    final response = await _dio.post(
      ApiConstants.moodTracker,
      data: mood.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      MoodTrackerModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<List<MoodTrackerModel>> listMoodTrackers({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.moodTracker,
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
        .map((item) => MoodTrackerModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
