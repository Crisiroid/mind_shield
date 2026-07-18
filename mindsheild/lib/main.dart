import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/services/dialog_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/token_service.dart';
import 'core/network/dio_client.dart';
import 'core/network/api_interceptor.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize core services
  await StorageService.init();
  await TokenService.init();

  // Initialize Dio HTTP client with interceptors
  final interceptors = <dynamic>[
    ApiInterceptor(),
    if (AppConfig.isDebug) LoggingInterceptor(),
  ];
  DioClient.init(interceptors: interceptors.cast());

  // Setup navigator key for DialogService
  final navigatorKey = GlobalKey<NavigatorState>();
  DialogService.init(navigatorKey);

  runApp(const MindShieldApp());
}
