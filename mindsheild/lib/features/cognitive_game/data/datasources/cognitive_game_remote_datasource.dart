import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/cognitive_game_model.dart';

/// Contract for cognitive game remote operations.
abstract class CognitiveGameRemoteDataSource {
  /// Create a new cognitive game result.
  Future<CognitiveGameModel> createCognitiveGame({
    required CognitiveGameModel game,
  });

  /// List cognitive game results for the current user.
  Future<List<CognitiveGameModel>> listCognitiveGames({
    int page = 1,
    int pageSize = 20,
  });
}

/// Implementation using Dio HTTP client.
class CognitiveGameRemoteDataSourceImpl
    implements CognitiveGameRemoteDataSource {
  final Dio _dio;

  CognitiveGameRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<CognitiveGameModel> createCognitiveGame({
    required CognitiveGameModel game,
  }) async {
    final response = await _dio.post(
      ApiConstants.cognitiveGame,
      data: game.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return CognitiveGameModel.fromJson(apiResponse.data!);
  }

  @override
  Future<List<CognitiveGameModel>> listCognitiveGames({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.cognitiveGame,
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
          (item) => CognitiveGameModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
