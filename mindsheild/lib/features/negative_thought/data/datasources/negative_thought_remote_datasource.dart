import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/negative_thought_model.dart';

/// Contract for negative thought remote operations.
abstract class NegativeThoughtRemoteDataSource {
  /// Create a new negative thought entry.
  Future<WriteResult<NegativeThoughtModel>> createNegativeThought({
    required NegativeThoughtModel thought,
  });

  /// List negative thought entries for the current user.
  Future<List<NegativeThoughtModel>> listNegativeThoughts({
    int page = 1,
    int pageSize = 20,
  });
}

/// Implementation using Dio HTTP client.
class NegativeThoughtRemoteDataSourceImpl
    implements NegativeThoughtRemoteDataSource {
  final Dio _dio;

  NegativeThoughtRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<WriteResult<NegativeThoughtModel>> createNegativeThought({
    required NegativeThoughtModel thought,
  }) async {
    final response = await _dio.post(
      ApiConstants.negativeThought,
      data: thought.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      NegativeThoughtModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<List<NegativeThoughtModel>> listNegativeThoughts({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.negativeThought,
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
          (item) => NegativeThoughtModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
