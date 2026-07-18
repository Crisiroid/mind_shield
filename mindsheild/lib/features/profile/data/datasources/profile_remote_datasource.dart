import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/auth_response_model.dart';

/// Contract for profile remote operations.
///
/// Interface Segregation Principle — the repository depends only
/// on the methods it needs, not the full HTTP implementation.
abstract class ProfileRemoteDataSource {
  /// Fetch the current user's profile.
  Future<UserModel> getProfile();

  /// Update the current user's profile settings.
  Future<UserModel> updateProfile(Map<String, dynamic> data);

  /// Change the current user's password.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

/// Implementation using Dio HTTP client.
///
/// Handles all remote profile API calls and response parsing.
/// Throws [AppException] (mapped by the interceptor) on failures.
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
