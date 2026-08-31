import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';
import 'core/services/storage_service.dart';
import 'core/services/token_service.dart';
import 'core/services/notification_service.dart';
import 'core/network/dio_client.dart';
import 'core/network/api_interceptor.dart';
import 'core/network/token_refresh_interceptor.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler for release mode debugging
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  try {
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

    // Initialize storage and token service
    await StorageService.init();
    await TokenService.init();

    // Request notification permission (required for Android 13+)
    try {
      if (Platform.isAndroid) {
        final notificationStatus = await Permission.notification.request();
        if (notificationStatus.isGranted) {
          await NotificationService.init();
          await NotificationService.scheduleDailyNotifications();
        } else {
          // Initialize anyway, but user won't receive notifications until permission is granted
          await NotificationService.init();
        }
      } else {
        await NotificationService.init();
        await NotificationService.scheduleDailyNotifications();
      }
    } catch (e) {
      debugPrint('Notification initialization error: $e');
      // Continue without notifications
    }

    final interceptors = <dynamic>[
      TokenRefreshInterceptor(),
      ApiInterceptor(),
      if (AppConfig.isDebug) LoggingInterceptor(),
    ];
    DioClient.init(interceptors: interceptors.cast());

    runApp(const MindShieldApp());
  } catch (e, stackTrace) {
    debugPrint('Critical initialization error: $e');
    debugPrint('Stack trace: $stackTrace');

    // Run app anyway so user can see error
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'خطا در راه‌اندازی برنامه:\n\n$e',
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
