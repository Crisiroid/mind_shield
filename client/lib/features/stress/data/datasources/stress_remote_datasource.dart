import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/stress_event_model.dart';

abstract class StressRemoteDataSource {
  Future<WriteResult<StressEventModel>> createStressEvent({
    required StressEventModel stressEvent,
  });

  Future<List<StressEventModel>> listStressEvents({
    int page = 1,
    int pageSize = 20,
  });
}

class StressRemoteDataSourceImpl implements StressRemoteDataSource {
  final Dio _dio;

  StressRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<WriteResult<StressEventModel>> createStressEvent({
    required StressEventModel stressEvent,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/stress-events',
      data: stressEvent.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      StressEventModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<List<StressEventModel>> listStressEvents({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/stress-events',
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
        .map((item) => StressEventModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
