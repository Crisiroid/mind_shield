import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/mental_must_model.dart';

/// Contract for mental must remote operations.
abstract class MentalMustRemoteDataSource {
  /// Create a new mental must entry.
  Future<WriteResult<MentalMustModel>> createMentalMust({
    required MentalMustModel must,
  });

  /// List mental must entries for the current user.
  Future<List<MentalMustModel>> listMentalMusts({
    int page = 1,
    int pageSize = 50,
  });

  /// Update a mental must entry (e.g., release it).
  Future<WriteResult<MentalMustModel>> updateMentalMust({
    required String id,
    required Map<String, dynamic> data,
  });
}

/// Implementation using Dio HTTP client.
class MentalMustRemoteDataSourceImpl implements MentalMustRemoteDataSource {
  final Dio _dio;

  MentalMustRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<WriteResult<MentalMustModel>> createMentalMust({
    required MentalMustModel must,
  }) async {
    final response = await _dio.post(
      ApiConstants.mentalMusts,
      data: must.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      MentalMustModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<List<MentalMustModel>> listMentalMusts({
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get(
      ApiConstants.mentalMusts,
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
        .map((item) => MentalMustModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<WriteResult<MentalMustModel>> updateMentalMust({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.put(
      '${ApiConstants.mentalMusts}/$id',
      data: data,
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      MentalMustModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }
}
