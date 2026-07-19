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

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await StorageService.init();
  await TokenService.init();

  final interceptors = <dynamic>[
    ApiInterceptor(),
    if (AppConfig.isDebug) LoggingInterceptor(),
  ];
  DioClient.init(interceptors: interceptors.cast());

  final navigatorKey = GlobalKey<NavigatorState>();
  DialogService.init(navigatorKey);

  runApp(const MindShieldApp());
}
