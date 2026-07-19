class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.1.100:8080';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 10000;

  static const String apiPrefix = '/api/v1';

  static const String login = '$apiPrefix/auth/user/login';
  static const String register = '$apiPrefix/auth/user/register';
  static const String refreshToken = '$apiPrefix/auth/user/refresh';
  static const String logout = '$apiPrefix/auth/user/logout';

  static const String users = '$apiPrefix/users';
  static const String profile = '$apiPrefix/users/me';
  static const String updateLoginInfo = '$apiPrefix/users/update-login-info';
  static const String changePassword = '$apiPrefix/auth/user/change-password';
  static const String acceptAgreement = '$apiPrefix/users/me/agreement';

  static const String emotionTriangle = '$apiPrefix/emotion-interactions';

  static const String breathing = '$apiPrefix/breathing';

  static const String cognitiveGame = '$apiPrefix/cognitive-games';

  static const String moodTracker = '$apiPrefix/mood-tracker';

  static const String dailyCalendar = '$apiPrefix/daily-calendar';

  static const String mindCourt = '$apiPrefix/mind-court-evidence';

  static const String conflictExercise = '$apiPrefix/conflict-exercises';

  static const String mentalMusts = '$apiPrefix/mental-musts';

  static const String negativeThought = '$apiPrefix/negative-thoughts';

  static const String skyThought = '$apiPrefix/sky-thoughts';

  static const String roleValue = '$apiPrefix/roles-values';

  static const String mindfulTimer = '$apiPrefix/mindful-timer';

  static const String reports = '$apiPrefix/reports';

  static const String weeklyMedia = '$apiPrefix/media/weekly';
}
