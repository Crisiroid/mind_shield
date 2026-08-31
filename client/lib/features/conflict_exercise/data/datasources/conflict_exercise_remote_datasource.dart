import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/conflict_exercise_model.dart';

abstract class ConflictExerciseRemoteDataSource {
  Future<WriteResult<ConflictExerciseModel>> createConflictExercise({
    required ConflictExerciseModel exercise,
  });

  Future<List<ConflictExerciseModel>> listConflictExercises({
    int page = 1,
    int pageSize = 20,
  });
}

class ConflictExerciseRemoteDataSourceImpl
    implements ConflictExerciseRemoteDataSource {
  final Dio _dio;

  ConflictExerciseRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<WriteResult<ConflictExerciseModel>> createConflictExercise({
    required ConflictExerciseModel exercise,
  }) async {
    final response = await _dio.post(
      ApiConstants.conflictExercise,
      data: exercise.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      ConflictExerciseModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<List<ConflictExerciseModel>> listConflictExercises({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.conflictExercise,
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
              ConflictExerciseModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
