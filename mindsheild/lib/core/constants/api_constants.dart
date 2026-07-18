/// Centralized API endpoints and network constants.
///
/// All API URLs, timeouts, and HTTP-related constants live here
/// to enforce the Single Responsibility Principle — change config
/// in one place without touching business logic.
class ApiConstants {
  ApiConstants._(); // Prevent instantiation

  // ─── Base URL ───────────────────────────────────────────────
  static const String baseUrl =
      'http://192.168.1.102:8080'; // Android emulator → localhost
  // static const String baseUrl = 'http://YOUR_SERVER_IP:8080'; // Physical device

  // ─── Timeouts (milliseconds) ────────────────────────────────
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 10000;

  // ─── API Paths ──────────────────────────────────────────────
  static const String apiPrefix = '/api/v1';

  // Auth
  static const String login = '$apiPrefix/auth/user/login';
  static const String register = '$apiPrefix/auth/user/register';
  static const String refreshToken = '$apiPrefix/auth/user/refresh';
  static const String logout = '$apiPrefix/auth/user/logout';

  // User
  static const String users = '$apiPrefix/users';
  static const String profile = '$apiPrefix/users/profile';
  static const String acceptAgreement = '$apiPrefix/users/me/agreement';

  // Emotion Triangle
  static const String emotionTriangle = '$apiPrefix/emotion-interactions';

  // Breathing
  static const String breathing = '$apiPrefix/breathing';

  // Cognitive Game
  static const String cognitiveGame = '$apiPrefix/cognitive-games';

  // Mood Tracker
  static const String moodTracker = '$apiPrefix/mood-tracker';

  // Daily Calendar
  static const String dailyCalendar = '$apiPrefix/daily-calendar';

  // Mind Court
  static const String mindCourt = '$apiPrefix/mind-court-evidence';

  // Conflict Exercise
  static const String conflictExercise = '$apiPrefix/conflict-exercises';

  // Mental Musts
  static const String mentalMusts = '$apiPrefix/mental-musts';

  // Negative Thought
  static const String negativeThought = '$apiPrefix/negative-thoughts';

  // Sky Thought
  static const String skyThought = '$apiPrefix/sky-thoughts';

  // Role Value
  static const String roleValue = '$apiPrefix/roles-values';

  // Mindful Timer
  static const String mindfulTimer = '$apiPrefix/mindful-timer';

  // Reports
  static const String reports = '$apiPrefix/reports';

  // Weekly Media
  static const String weeklyMedia = '$apiPrefix/media/weekly';
}
