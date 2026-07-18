import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/emotion_interaction_model.dart';

/// Contract for emotion triangle remote operations.
///
/// Interface Segregation Principle — the repository depends only
/// on the methods it needs, not the full HTTP implementation.
abstract class EmotionTriangleRemoteDataSource {
  /// Create a new emotion triangle interaction.
  Future<WriteResult<EmotionInteractionModel>> createInteraction({
    required EmotionInteractionModel interaction,
  });

  /// List emotion triangle interactions for the current user.
  Future<List<EmotionInteractionModel>> listInteractions({
    int page = 1,
    int pageSize = 20,
  });
}

/// Implementation using Dio HTTP client.
///
/// Handles all emotion triangle API calls and response parsing.
class EmotionTriangleRemoteDataSourceImpl
    implements EmotionTriangleRemoteDataSource {
  final Dio _dio;

  EmotionTriangleRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<WriteResult<EmotionInteractionModel>> createInteraction({
    required EmotionInteractionModel interaction,
  }) async {
    final response = await _dio.post(
      ApiConstants.emotionTriangle,
      data: interaction.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      EmotionInteractionModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<List<EmotionInteractionModel>> listInteractions({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.emotionTriangle,
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
        .map(
          (item) =>
              EmotionInteractionModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
