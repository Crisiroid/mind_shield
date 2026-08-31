import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/body_tension_model.dart';

abstract class BodyTensionRemoteDataSource {
  Future<WriteResult<BodyTensionModel>> createBodyTension({
    required BodyTensionModel bodyTension,
  });

  Future<List<BodyTensionModel>> listBodyTensions({
    int page = 1,
    int pageSize = 20,
  });
}

class BodyTensionRemoteDataSourceImpl implements BodyTensionRemoteDataSource {
  final Dio _dio;

  BodyTensionRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<WriteResult<BodyTensionModel>> createBodyTension({
    required BodyTensionModel bodyTension,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/body-tension-maps',
      data: bodyTension.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      BodyTensionModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<List<BodyTensionModel>> listBodyTensions({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/body-tension-maps',
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
        .map((item) => BodyTensionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
