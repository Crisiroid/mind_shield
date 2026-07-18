import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/breathing_session_model.dart';

/// Contract for breathing session remote operations.
abstract class BreathingRemoteDataSource {
  /// Create a new breathing session.
  Future<BreathingSessionModel> createSession({
    required BreathingSessionModel session,
  });

  /// Update an existing breathing session.
  Future<BreathingSessionModel> updateSession({
    required String id,
    required Map<String, dynamic> data,
  });

  /// List breathing sessions for the current user.
  Future<List<BreathingSessionModel>> listSessions({
    int page = 1,
    int pageSize = 20,
  });
}

/// Implementation using Dio HTTP client.
class BreathingRemoteDataSourceImpl implements BreathingRemoteDataSource {
  final Dio _dio;

  BreathingRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<BreathingSessionModel> createSession({
    required BreathingSessionModel session,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/breathing-sessions',
      data: session.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return BreathingSessionModel.fromJson(apiResponse.data!);
  }

  @override
  Future<BreathingSessionModel> updateSession({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.put(
      '${ApiConstants.apiPrefix}/breathing-sessions/$id',
      data: data,
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return BreathingSessionModel.fromJson(apiResponse.data!);
  }

  @override
  Future<List<BreathingSessionModel>> listSessions({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/breathing-sessions',
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
              BreathingSessionModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
