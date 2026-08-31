import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/sky_thought_model.dart';

abstract class SkyThoughtRemoteDataSource {
  Future<WriteResult<SkyThoughtModel>> createSkyThought({
    required SkyThoughtModel thought,
  });

  Future<WriteResult<SkyThoughtModel>> updateSkyThought({
    required String id,
    required bool cloudSwiped,
  });

  Future<List<SkyThoughtModel>> listSkyThoughts({
    int page = 1,
    int pageSize = 50,
  });
}

class SkyThoughtRemoteDataSourceImpl implements SkyThoughtRemoteDataSource {
  final Dio _dio;

  SkyThoughtRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<WriteResult<SkyThoughtModel>> createSkyThought({
    required SkyThoughtModel thought,
  }) async {
    final response = await _dio.post(
      ApiConstants.skyThought,
      data: thought.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      SkyThoughtModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<WriteResult<SkyThoughtModel>> updateSkyThought({
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

    return WriteResult(
      SkyThoughtModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
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
