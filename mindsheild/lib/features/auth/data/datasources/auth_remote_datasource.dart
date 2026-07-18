import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';

/// Contract for remote auth operations.
///
/// Interface Segregation Principle — the repository depends only
/// on the methods it needs, not the full HTTP implementation.
abstract class AuthRemoteDataSource {
  Future<AuthTokenData> login({
    required String phoneNumber,
    required String password,
  });

  Future<AuthTokenData> register({
    required String phoneNumber,
    required String password,
  });

  Future<AuthTokenData> refreshToken({required String refreshToken});

  Future<void> logout();

  /// Accept the digital therapy agreement on the server.
  Future<void> acceptAgreement();

  /// Send device/app version info to the server.
  Future<void> updateLoginInfo({
    required String androidVersion,
    required String appVersion,
  });
}

/// Implementation using Dio HTTP client.
///
/// Handles all remote auth API calls and response parsing.
/// Throws [AppException] (mapped by the interceptor) on failures.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl() : _dio = DioClient.instance;

  @override
  Future<AuthTokenData> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'phone_number': phoneNumber, 'password': password},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
    return AuthTokenData.fromJson(apiResponse.data!);
  }

  @override
  Future<AuthTokenData> register({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {'phone_number': phoneNumber, 'password': password},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
    return AuthTokenData.fromJson(apiResponse.data!);
  }

  @override
  Future<AuthTokenData> refreshToken({required String refreshToken}) async {
    final response = await _dio.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final apiResponse = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
    final data = apiResponse.data!;

    return AuthTokenData(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      expiresIn: data['expires_in'] as int? ?? 3600,
      tokenType: data['token_type'] as String? ?? 'Bearer',
      user: const UserModel(id: '', phoneNumber: ''),
    );
  }

  @override
  Future<void> logout() async {
    await _dio.post(ApiConstants.logout);
  }

  @override
  Future<void> acceptAgreement() async {
    await _dio.post(ApiConstants.acceptAgreement);
  }

  @override
  Future<void> updateLoginInfo({
    required String androidVersion,
    required String appVersion,
  }) async {
    await _dio.post(
      ApiConstants.updateLoginInfo,
      data: {'android_version': androidVersion, 'app_version': appVersion},
    );
  }
}
