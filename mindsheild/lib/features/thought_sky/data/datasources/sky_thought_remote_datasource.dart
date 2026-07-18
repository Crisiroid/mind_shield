import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/sky_thought_model.dart';

/// Contract for sky thought remote operations.
abstract class SkyThoughtRemoteDataSource {
  /// Create a new sky thought (a negative thought turned into a cloud).
  Future<SkyThoughtModel> createSkyThought({required SkyThoughtModel thought});

  /// Update a sky thought (e.g., mark its cloud as swiped away).
  Future<SkyThoughtModel> updateSkyThought({
    required String id,
    required bool cloudSwiped,
  });

  /// List sky thoughts for the current user.
  Future<List<SkyThoughtModel>> listSkyThoughts({
    int page = 1,
    int pageSize = 50,
  });
}

/// Implementation using Dio HTTP client.
class SkyThoughtRemoteDataSourceImpl implements SkyThoughtRemoteDataSource {
  final Dio _dio;

  SkyThoughtRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<SkyThoughtModel> createSkyThought({
    required SkyThoughtModel thought,
  }) async {
    final response = await _dio.post(
      ApiConstants.skyThought,
      data: thought.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return SkyThoughtModel.fromJson(apiResponse.data!);
  }

  @override
  Future<SkyThoughtModel> updateSkyThought({
    required String id,
    required bool cloudSwiped,
  }) async {
    final response = await _dio.put(
      '${ApiConstants.skyThought}/$id',
      data: {'cloud_swiped': cloudSwiped},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return SkyThoughtModel.fromJson(apiResponse.data!);
  }

  @override
  Future<List<SkyThoughtModel>> listSkyThoughts({
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get(
      ApiConstants.skyThought,
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
        .map((item) => SkyThoughtModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
