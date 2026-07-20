import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/media_progress_model.dart';

/// Talks to the per-user media progress API
/// (`GET /media/progress`, `PUT /media/progress/:media_id`).
abstract class MediaProgressRemoteDataSource {
  Future<List<MediaProgressModel>> getMyProgress();

  Future<WriteResult<MediaProgressModel>> upsertProgress(
    MediaProgressModel progress,
  );
}

class MediaProgressRemoteDataSourceImpl
    implements MediaProgressRemoteDataSource {
  final Dio _dio;

  MediaProgressRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<List<MediaProgressModel>> getMyProgress() async {
    final response = await _dio.get(ApiConstants.mediaProgress);

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (apiResponse.data == null) return [];

    final data = apiResponse.data!;
    final items =
        data['items'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];

    return items
        .map(
          (item) => MediaProgressModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<WriteResult<MediaProgressModel>> upsertProgress(
    MediaProgressModel progress,
  ) async {
    final response = await _dio.put(
      '${ApiConstants.mediaProgress}/${progress.mediaContentId}',
      data: progress.toUpsertJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    // Preserve the caller's media id so the local business key stays intact
    // even if the server omits it from the response envelope.
    final saved = MediaProgressModel.fromJson(apiResponse.data!);
    final merged = saved.mediaContentId.isEmpty
        ? saved.copyWith(mediaContentId: progress.mediaContentId)
        : saved;

    return WriteResult(merged, apiResponse.message);
  }
}
