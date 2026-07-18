// Authentication response models matching the backend API contract.
//
// Parses the JSON response from login/register endpoints:
// `{success, message, data: {access_token, refresh_token, expires_in, token_type, user}}`
//
// Follows the Single Responsibility Principle — each model
// is responsible only for its own JSON parsing.

/// Top-level API response wrapper.
class ApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

/// Authentication token data returned after login/register.
class AuthTokenData {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final UserModel user;

  const AuthTokenData({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    required this.user,
  });

  factory AuthTokenData.fromJson(Map<String, dynamic> json) {
    return AuthTokenData(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int? ?? 3600,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// User model matching the backend UserResponse schema.
class UserModel {
  final String id;
  final String phoneNumber;
  final DateTime? registrationDate;
  final DateTime? lastLogin;
  final int loginCount;
  final bool agreementAccepted;
  final DateTime? agreementAcceptedAt;
  final bool cloudSyncEnabled;
  final bool doNotDisturbEnabled;
  final DateTime? dndStartTime;
  final DateTime? dndEndTime;
  final String? androidVersion;
  final String? appVersion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.registrationDate,
    this.lastLogin,
    this.loginCount = 0,
    this.agreementAccepted = false,
    this.agreementAcceptedAt,
    this.cloudSyncEnabled = false,
    this.doNotDisturbEnabled = false,
    this.dndStartTime,
    this.dndEndTime,
    this.androidVersion,
    this.appVersion,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String? ?? '',
      registrationDate: json['registration_date'] != null
          ? DateTime.tryParse(json['registration_date'] as String)
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'] as String)
          : null,
      loginCount: json['login_count'] as int? ?? 0,
      agreementAccepted: json['agreement_accepted'] as bool? ?? false,
      agreementAcceptedAt: json['agreement_accepted_at'] != null
          ? DateTime.tryParse(json['agreement_accepted_at'] as String)
          : null,
      cloudSyncEnabled: json['cloud_sync_enabled'] as bool? ?? false,
      doNotDisturbEnabled: json['do_not_disturb_enabled'] as bool? ?? false,
      dndStartTime: json['dnd_start_time'] != null
          ? DateTime.tryParse(json['dnd_start_time'] as String)
          : null,
      dndEndTime: json['dnd_end_time'] != null
          ? DateTime.tryParse(json['dnd_end_time'] as String)
          : null,
      androidVersion: json['android_version'] as String?,
      appVersion: json['app_version'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}
