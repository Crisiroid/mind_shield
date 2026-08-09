import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/weekly_exercise_model.dart';
import '../models/day_progress_model.dart';

abstract class Week1RemoteDataSource {
  // Weekly exercises
  Future<WriteResult<WeeklyExerciseModel>> createExerciseResponse({
    required WeeklyExerciseModel entry,
  });

  Future<WriteResult<WeeklyExerciseModel>> updateExerciseResponse({
    required String id,
    required Map<String, dynamic> data,
  });

  Future<List<WeeklyExerciseModel>> listExerciseResponses({
    int? weekNumber,
    int? dayNumber,
  });

  Future<List<WeeklyExerciseModel>> getExercisesByWeek({
    required int weekNumber,
  });

  // Day progress
  Future<WriteResult<DayProgressModel>> createDayProgress({
    required DayProgressModel entry,
  });

  Future<DayProgressModel> markDayCompleted({
    required int weekNumber,
    required int dayNumber,
  });

  Future<List<DayProgressModel>> getDayProgressByWeek({
    required int weekNumber,
  });

  Future<List<DayProgressModel>> getDayProgressSummary({
    required int weekNumber,
  });
}

class Week1RemoteDataSourceImpl implements Week1RemoteDataSource {
  final Dio _dio;

  Week1RemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<WriteResult<WeeklyExerciseModel>> createExerciseResponse({
    required WeeklyExerciseModel entry,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/weekly-exercises',
      data: entry.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      WeeklyExerciseModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<WriteResult<WeeklyExerciseModel>> updateExerciseResponse({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.put(
      '${ApiConstants.apiPrefix}/weekly-exercises/$id',
      data: data,
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      WeeklyExerciseModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<List<WeeklyExerciseModel>> listExerciseResponses({
    int? weekNumber,
    int? dayNumber,
  }) async {
    final params = <String, dynamic>{};
    if (weekNumber != null) params['week_number'] = weekNumber;
    if (dayNumber != null) params['day_number'] = dayNumber;
    params['page_size'] = 200;

    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/weekly-exercises',
      queryParameters: params,
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
          (item) => WeeklyExerciseModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<WeeklyExerciseModel>> getExercisesByWeek({
    required int weekNumber,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/weekly-exercises/user/week/$weekNumber',
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (apiResponse.data == null) return [];

    final items = apiResponse.data as List<dynamic>;
    return items
        .map(
          (item) => WeeklyExerciseModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<WriteResult<DayProgressModel>> createDayProgress({
    required DayProgressModel entry,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/day-progress',
      data: entry.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      DayProgressModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<DayProgressModel> markDayCompleted({
    required int weekNumber,
    required int dayNumber,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/day-progress/complete',
      data: {'week_number': weekNumber, 'day_number': dayNumber},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return DayProgressModel.fromJson(apiResponse.data!);
  }

  @override
  Future<List<DayProgressModel>> getDayProgressByWeek({
    required int weekNumber,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/day-progress',
      queryParameters: {'week_number': weekNumber, 'page_size': 200},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (apiResponse.data == null) return [];

    final data = apiResponse.data!;
    final items =
        data['items'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];

    return items
        .map((item) => DayProgressModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DayProgressModel>> getDayProgressSummary({
    required int weekNumber,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/day-progress/summary',
      queryParameters: {'week_number': weekNumber},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (apiResponse.data == null) return [];

    final data = apiResponse.data!;
    final days = data['days'] as List<dynamic>? ?? [];

    return days.map((item) {
      return DayProgressModel(
        id: '',
        userId: '',
        weekNumber: weekNumber,
        dayNumber: (item as Map<String, dynamic>)['day_number'] as int,
        isCompleted: item['is_completed'] as bool? ?? false,
        completedAt: item['completed_at'] != null
            ? DateTime.tryParse(item['completed_at'] as String)
            : null,
        openedAt: item['opened_at'] != null
            ? DateTime.tryParse(item['opened_at'] as String)
            : null,
      );
    }).toList();
  }
}
