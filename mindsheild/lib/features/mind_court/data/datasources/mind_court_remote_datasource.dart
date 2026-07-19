import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/mind_court_model.dart';

abstract class MindCourtRemoteDataSource {
  Future<WriteResult<MindCourtModel>> createMindCourt({
    required MindCourtModel evidence,
  });

  Future<List<MindCourtModel>> listMindCourt({int page = 1, int pageSize = 20});
}

class MindCourtRemoteDataSourceImpl implements MindCourtRemoteDataSource {
  final Dio _dio;

  MindCourtRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<WriteResult<MindCourtModel>> createMindCourt({
    required MindCourtModel evidence,
  }) async {
    final response = await _dio.post(
      ApiConstants.mindCourt,
      data: evidence.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      MindCourtModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<List<MindCourtModel>> listMindCourt({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.mindCourt,
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
        .map((item) => MindCourtModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
