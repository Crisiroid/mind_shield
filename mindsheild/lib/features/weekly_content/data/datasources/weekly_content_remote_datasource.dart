import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../../../home/data/models/weekly_media_model.dart';

/// Reads the user-facing media library
/// (`GET /media/library`, `GET /media/library/week/:week_number`). The backend
/// forces `is_active = true` for the `user` role, so only published content is
/// ever returned here.
abstract class WeeklyContentRemoteDataSource {
  Future<List<WeeklyMediaModel>> getAllContent();

  Future<List<WeeklyMediaModel>> getByWeek(int weekNumber);
}

class WeeklyContentRemoteDataSourceImpl
    implements WeeklyContentRemoteDataSource {
  final Dio _dio;

  WeeklyContentRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<List<WeeklyMediaModel>> getAllContent() async {
    final response = await _dio.get(
      ApiConstants.mediaLibrary,
      queryParameters: {'page': 1, 'page_size': 500},
    );
    return _parseList(response);
  }

  @override
  Future<List<WeeklyMediaModel>> getByWeek(int weekNumber) async {
    final response = await _dio.get(
      '${ApiConstants.mediaLibrary}/week/$weekNumber',
      queryParameters: {'page': 1, 'page_size': 500},
    );
    return _parseList(response);
  }

  List<WeeklyMediaModel> _parseList(Response response) {
    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (apiResponse.data == null) return [];

    final data = apiResponse.data!;
    final items =
        data['items'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];

    return items
        .map((item) => WeeklyMediaModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
