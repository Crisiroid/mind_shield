import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/cognitive_game_model.dart';

abstract class CognitiveGameRemoteDataSource {
  Future<WriteResult<CognitiveGameModel>> createCognitiveGame({
    required CognitiveGameModel game,
  });

  Future<List<CognitiveGameModel>> listCognitiveGames({
    int page = 1,
    int pageSize = 20,
  });
}

class CognitiveGameRemoteDataSourceImpl
    implements CognitiveGameRemoteDataSource {
  final Dio _dio;

  CognitiveGameRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<WriteResult<CognitiveGameModel>> createCognitiveGame({
    required CognitiveGameModel game,
  }) async {
    final response = await _dio.post(
      ApiConstants.cognitiveGame,
      data: game.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      CognitiveGameModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
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
