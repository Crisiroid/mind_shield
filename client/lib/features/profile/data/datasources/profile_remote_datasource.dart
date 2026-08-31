import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/auth_response_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();

  Future<UserModel> updateProfile(Map<String, dynamic> data);

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<UserModel> getProfile() async {
    final response = await _dio.get(ApiConstants.profile);

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (apiResponse.data == null) {
      throw Exception('پروفایل کاربر یافت نشد');
    }

    return UserModel.fromJson(apiResponse.data!);
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.profile, data: data);

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (apiResponse.data == null) {
      throw Exception('بروزرسانی پروفایل ناموفق بود');
    }

    return UserModel.fromJson(apiResponse.data!);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dio.post(
      ApiConstants.changePassword,
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }
}
