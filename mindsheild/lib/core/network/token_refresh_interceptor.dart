import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../services/token_service.dart';

/// Transparently refreshes an expired access token when the backend answers a
/// protected request with `401 Unauthorized`, then replays the original
/// request so the user is never bounced back to the login screen while a valid
/// refresh token is still available.
///
/// It runs *before* [ApiInterceptor] so it can inspect the raw `401` response
/// (Dio's `validateStatus` lets statuses < 500 through as a response rather than
/// an error). A single-flight [Completer] guarantees that concurrent `401`s
/// trigger only one refresh call; the remaining requests await its result.
class TokenRefreshInterceptor extends QueuedInterceptor {
  TokenRefreshInterceptor();

  /// Bare Dio client with no interceptors: used exclusively to hit the refresh
  /// endpoint so it can never recurse back into this interceptor.
  final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
    ),
  );

  Completer<String?>? _refreshCompleter;

  bool _isAuthEndpoint(String path) {
    return path.contains(ApiConstants.login) ||
        path.contains(ApiConstants.register) ||
        path.contains(ApiConstants.refreshToken) ||
        path.contains(ApiConstants.logout);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final path = response.requestOptions.path;
    if (response.statusCode != 401 || _isAuthEndpoint(path)) {
      handler.next(response);
      return;
    }

    final newToken = await _refreshAccessToken();
    if (newToken == null) {
      // Refresh genuinely failed (no refresh token or the server rejected it):
      // clear the session and let the original 401 flow through so the app can
      // route back to login.
      await TokenService.clearTokens();
      handler.next(response);
      return;
    }

    try {
      final retryResponse = await _retry(response.requestOptions, newToken);
      handler.resolve(retryResponse);
    } catch (_) {
      handler.next(response);
    }
  }

  /// Refreshes the access token, ensuring only one network refresh runs at a
  /// time. Returns the new access token, or `null` when refresh is impossible.
  Future<String?> _refreshAccessToken() {
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    _performRefresh()
        .then((token) {
          completer.complete(token);
        })
        .catchError((_) {
          completer.complete(null);
        })
        .whenComplete(() {
          _refreshCompleter = null;
        });

    return completer.future;
  }

  Future<String?> _performRefresh() async {
    final refreshToken = TokenService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final response = await _refreshDio.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) return null;
    final data = body['data'];
    if (data is! Map<String, dynamic>) return null;

    final accessToken = data['access_token'] as String?;
    final newRefreshToken = data['refresh_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) return null;

    await TokenService.updateTokens(
      accessToken: accessToken,
      refreshToken: (newRefreshToken != null && newRefreshToken.isNotEmpty)
          ? newRefreshToken
          : refreshToken,
    );
    return accessToken;
  }

  Future<Response<dynamic>> _retry(
    RequestOptions requestOptions,
    String newAccessToken,
  ) {
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers['Authorization'] = 'Bearer $newAccessToken';

    return _refreshDio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        extra: requestOptions.extra,
      ),
    );
  }
}
