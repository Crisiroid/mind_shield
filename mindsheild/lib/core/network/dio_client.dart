import 'package:dio/dio.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  DioClient._();

  static late Dio _instance;

  static Dio get instance => _instance;

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
