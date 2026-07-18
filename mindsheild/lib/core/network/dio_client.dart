import 'package:dio/dio.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// Dio HTTP client configuration and singleton instance.
///
/// Centralizes all HTTP setup (timeouts, interceptors, base options)
/// so feature repositories only inject and use this single client.
class DioClient {
  DioClient._();

  static late Dio _instance;

  static Dio get instance => _instance;

  /// Initialize Dio with interceptors and base config.
  /// Must be called once at app startup.
  static void init({required List<Interceptor> interceptors}) {
    _instance = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _instance.interceptors.addAll(interceptors);
  }
}

/// Checks internet connectivity before network operations.
///
/// Used by repositories to decide between remote and local data sources,
/// following the Interface Segregation Principle — only exposes what's needed.
class NetworkInfo {
  final InternetConnection _connection;

  NetworkInfo(this._connection);

  Future<bool> get isConnected async {
    try {
      return await _connection.hasInternetAccess;
    } catch (_) {
      return false;
    }
  }
}
