import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/sync/write_result.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/role_value_model.dart';

abstract class RoleValueRemoteDataSource {
  Future<WriteResult<RoleValueModel>> createRoleValue({
    required RoleValueModel entry,
  });

  Future<List<RoleValueModel>> listRolesValues({
    int page = 1,
    int pageSize = 50,
  });
}

class RoleValueRemoteDataSourceImpl implements RoleValueRemoteDataSource {
  final Dio _dio;

  RoleValueRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<WriteResult<RoleValueModel>> createRoleValue({
    required RoleValueModel entry,
  }) async {
    final response = await _dio.post(
      ApiConstants.roleValue,
      data: entry.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    return WriteResult(
      RoleValueModel.fromJson(apiResponse.data!),
      apiResponse.message,
    );
  }

  @override
  Future<List<RoleValueModel>> listRolesValues({
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get(
      ApiConstants.roleValue,
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
        .map((item) => RoleValueModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
