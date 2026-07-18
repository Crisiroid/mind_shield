import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/stress_event_model.dart';

/// Contract for stress event remote operations.
abstract class StressRemoteDataSource {
  /// Create a new stress event.
  Future<StressEventModel> createStressEvent({
    required StressEventModel stressEvent,
  });

  /// List stress events for the current user.
  Future<List<StressEventModel>> listStressEvents({
    int page = 1,
    int pageSize = 20,
  });
}

/// Implementation using Dio HTTP client.
class StressRemoteDataSourceImpl implements StressRemoteDataSource {
  final Dio _dio;

  StressRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<StressEventModel> createStressEvent({
    required StressEventModel stressEvent,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/stress-events',
      data: stressEvent.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return StressEventModel.fromJson(apiResponse.data!);
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
