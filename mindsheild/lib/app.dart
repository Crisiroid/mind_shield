import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'core/constants/app_strings.dart';
import 'core/providers/app_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/responsive_utils.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/view_models/auth_view_model.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/data/datasources/home_remote_datasource.dart';
import 'features/home/data/repositories/home_repository.dart';
import 'features/home/presentation/view_models/home_view_model.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/view_models/onboarding_view_model.dart';
import 'features/onboarding/presentation/screens/welcome_agreement_screen.dart';
import 'features/onboarding/presentation/screens/roadmap_screen.dart';
import 'features/emotion_triangle/data/datasources/emotion_triangle_remote_datasource.dart';
import 'features/emotion_triangle/data/repositories/emotion_triangle_repository.dart';
import 'features/emotion_triangle/presentation/view_models/emotion_triangle_view_model.dart';
import 'features/emotion_triangle/presentation/screens/emotion_triangle_screen.dart';
import 'features/body_tension/data/datasources/body_tension_remote_datasource.dart';
import 'features/body_tension/data/repositories/body_tension_repository.dart';
import 'features/body_tension/presentation/view_models/body_tension_view_model.dart';
import 'features/body_tension/presentation/screens/body_tension_map_screen.dart';
import 'features/stress/data/datasources/stress_remote_datasource.dart';
import 'features/stress/data/repositories/stress_repository.dart';
import 'features/stress/presentation/view_models/stress_view_model.dart';
import 'features/stress/presentation/screens/stress_registration_screen.dart';
import 'features/breathing/data/datasources/breathing_remote_datasource.dart';
import 'features/breathing/data/repositories/breathing_repository.dart';
import 'features/breathing/presentation/view_models/breathing_view_model.dart';
import 'features/breathing/presentation/screens/breathing_screen.dart';
import 'features/breathing/presentation/screens/resilience_education_screen.dart';
import 'features/cognitive_game/data/datasources/cognitive_game_remote_datasource.dart';
import 'features/cognitive_game/data/repositories/cognitive_game_repository.dart';
import 'features/cognitive_game/presentation/view_models/cognitive_game_view_model.dart';
import 'features/cognitive_game/presentation/screens/cognitive_game_screen.dart';
import 'features/mental_must/data/datasources/mental_must_remote_datasource.dart';
import 'features/mental_must/data/repositories/mental_must_repository.dart';
import 'features/mental_must/presentation/view_models/mental_must_view_model.dart';
import 'features/mental_must/presentation/screens/mental_must_screen.dart';
import 'features/negative_thought/data/datasources/negative_thought_remote_datasource.dart';
import 'features/negative_thought/data/repositories/negative_thought_repository.dart';
import 'features/negative_thought/presentation/view_models/negative_thought_view_model.dart';
import 'features/negative_thought/presentation/screens/negative_thought_radar_screen.dart';
import 'features/mind_court/data/datasources/mind_court_remote_datasource.dart';
import 'features/mind_court/data/repositories/mind_court_repository.dart';
import 'features/mind_court/presentation/view_models/mind_court_view_model.dart';
import 'features/mind_court/presentation/screens/mind_court_screen.dart';
import 'features/conflict_exercise/data/datasources/conflict_exercise_remote_datasource.dart';
import 'features/conflict_exercise/data/repositories/conflict_exercise_repository.dart';
import 'features/conflict_exercise/presentation/view_models/conflict_exercise_view_model.dart';
import 'features/conflict_exercise/presentation/screens/conflict_exercise_screen.dart';
import 'features/mood_tracker/data/datasources/mood_tracker_remote_datasource.dart';
import 'features/mood_tracker/data/repositories/mood_tracker_repository.dart';
import 'features/mood_tracker/presentation/view_models/mood_tracker_view_model.dart';
import 'features/mood_tracker/presentation/screens/isolation_cycle_screen.dart';
import 'features/mood_tracker/presentation/screens/micro_activities_screen.dart';
import 'features/mood_tracker/presentation/screens/mood_tracker_screen.dart';
import 'features/role_balance/data/datasources/role_value_remote_datasource.dart';
import 'features/role_balance/data/repositories/role_value_repository.dart';
import 'features/role_balance/presentation/view_models/role_balance_view_model.dart';
import 'features/role_balance/presentation/screens/role_balance_screen.dart';
import 'features/thought_sky/data/datasources/sky_thought_remote_datasource.dart';
import 'features/thought_sky/data/repositories/sky_thought_repository.dart';
import 'features/thought_sky/presentation/view_models/thought_sky_view_model.dart';
import 'features/thought_sky/presentation/screens/thought_sky_screen.dart';
// Offline-first: sync orchestration + per-feature local datasources
import 'core/services/sync_manager.dart';
import 'core/sync/syncable_repository.dart';
import 'features/emotion_triangle/data/datasources/emotion_triangle_local_datasource.dart';
import 'features/body_tension/data/datasources/body_tension_local_datasource.dart';
import 'features/stress/data/datasources/stress_local_datasource.dart';
import 'features/breathing/data/datasources/breathing_local_datasource.dart';
import 'features/cognitive_game/data/datasources/cognitive_game_local_datasource.dart';
import 'features/mental_must/data/datasources/mental_must_local_datasource.dart';
import 'features/negative_thought/data/datasources/negative_thought_local_datasource.dart';
import 'features/mind_court/data/datasources/mind_court_local_datasource.dart';
import 'features/conflict_exercise/data/datasources/conflict_exercise_local_datasource.dart';
import 'features/mood_tracker/data/datasources/mood_tracker_local_datasource.dart';
import 'features/role_balance/data/datasources/role_value_local_datasource.dart';
import 'features/thought_sky/data/datasources/sky_thought_local_datasource.dart';

/// Root application widget.
///
/// Configures providers, theme, and RTL directionality.
/// The entire app is Persian-only with forced RTL layout.
class MindShieldApp extends StatelessWidget {
  const MindShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive scaling
    ResponsiveUtils.init(context);

    // Create auth dependencies
    final authDataSource = AuthRemoteDataSourceImpl();
    final authRepository = AuthRepository(authDataSource);

    // Create home dependencies
    final homeDataSource = HomeRemoteDataSourceImpl();
    final homeRepository = HomeRepository(homeDataSource);

    // Create emotion triangle dependencies
    final emotionDataSource = EmotionTriangleRemoteDataSourceImpl();
    final emotionRepository = EmotionTriangleRepository(
      emotionDataSource,
      EmotionTriangleLocalDataSource(),
    );

    // Create body tension dependencies
    final bodyTensionDataSource = BodyTensionRemoteDataSourceImpl();
    final bodyTensionRepository = BodyTensionRepository(
      bodyTensionDataSource,
      BodyTensionLocalDataSource(),
    );

    // Create stress dependencies
    final stressDataSource = StressRemoteDataSourceImpl();
    final stressRepository = StressRepository(
      stressDataSource,
      StressLocalDataSource(),
    );

    // Create breathing dependencies
    final breathingDataSource = BreathingRemoteDataSourceImpl();
    final breathingRepository = BreathingRepository(
      breathingDataSource,
      BreathingLocalDataSource(),
    );

    // Create cognitive game dependencies
    final cognitiveGameDataSource = CognitiveGameRemoteDataSourceImpl();
    final cognitiveGameRepository = CognitiveGameRepository(
      cognitiveGameDataSource,
      CognitiveGameLocalDataSource(),
    );

    // Create mental must dependencies
    final mentalMustDataSource = MentalMustRemoteDataSourceImpl();
    final mentalMustRepository = MentalMustRepository(
      mentalMustDataSource,
      MentalMustLocalDataSource(),
    );

    // Create negative thought dependencies
    final negativeThoughtDataSource = NegativeThoughtRemoteDataSourceImpl();
    final negativeThoughtRepository = NegativeThoughtRepository(
      negativeThoughtDataSource,
      NegativeThoughtLocalDataSource(),
    );

    // Create mind court dependencies (Week 5)
    final mindCourtDataSource = MindCourtRemoteDataSourceImpl();
    final mindCourtRepository = MindCourtRepository(
      mindCourtDataSource,
      MindCourtLocalDataSource(),
    );

    // Create conflict exercise dependencies (Week 6)
    final conflictExerciseDataSource = ConflictExerciseRemoteDataSourceImpl();
    final conflictExerciseRepository = ConflictExerciseRepository(
      conflictExerciseDataSource,
      ConflictExerciseLocalDataSource(),
    );

    // Create mood tracker dependencies (Week 7)
    final moodTrackerDataSource = MoodTrackerRemoteDataSourceImpl();
    final moodTrackerRepository = MoodTrackerRepository(
      moodTrackerDataSource,
      MoodTrackerLocalDataSource(),
    );

    // Create role balance dependencies (Week 8)
    final roleValueDataSource = RoleValueRemoteDataSourceImpl();
    final roleValueRepository = RoleValueRepository(
      roleValueDataSource,
      RoleValueLocalDataSource(),
    );

    // Create thought sky dependencies (Week 8)
    final skyThoughtDataSource = SkyThoughtRemoteDataSourceImpl();
    final skyThoughtRepository = SkyThoughtRepository(
      skyThoughtDataSource,
      SkyThoughtLocalDataSource(),
    );

    // Offline-first sync orchestration: every offline-capable repository
    // registers itself as a [SyncableRepository]. Adding a feature just
    // appends here (OCP). SyncManager drives pull-on-login + push-on-reconnect.
    final List<SyncableRepository> syncableRepositories = <SyncableRepository>[
      emotionRepository,
      bodyTensionRepository,
      stressRepository,
      breathingRepository,
      cognitiveGameRepository,
      mentalMustRepository,
      negativeThoughtRepository,
      mindCourtRepository,
      conflictExerciseRepository,
      moodTrackerRepository,
      roleValueRepository,
      skyThoughtRepository,
    ];
    final syncManager = SyncManager(syncableRepositories);

    return MultiProvider(
      providers: [
        // Global app provider (connectivity + sync)
        ChangeNotifierProvider(
          create: (_) => AppProvider(InternetConnection(), syncManager),
        ),
        // Auth provider with injected repository
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),
        // Home provider with injected repository
        ChangeNotifierProvider(create: (_) => HomeViewModel(homeRepository)),
        // Onboarding provider (agreement + roadmap state)
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        // Emotion triangle provider
        ChangeNotifierProvider(
          create: (_) => EmotionTriangleViewModel(emotionRepository),
        ),
        // Body tension provider
        ChangeNotifierProvider(
          create: (_) => BodyTensionViewModel(bodyTensionRepository),
        ),
        // Stress provider
        ChangeNotifierProvider(
          create: (_) => StressViewModel(stressRepository),
        ),
        // Breathing provider
        ChangeNotifierProvider(
          create: (_) => BreathingViewModel(breathingRepository),
        ),
        // Cognitive game provider
        ChangeNotifierProvider(
          create: (_) => CognitiveGameViewModel(cognitiveGameRepository),
        ),
        // Mental must provider
        ChangeNotifierProvider(
          create: (_) => MentalMustViewModel(mentalMustRepository),
        ),
        // Negative thought provider
        ChangeNotifierProvider(
          create: (_) => NegativeThoughtViewModel(negativeThoughtRepository),
        ),
        // Mind court provider (Week 5) — reuses negative thought repository
        ChangeNotifierProvider(
          create: (_) => MindCourtViewModel(
            mindCourtRepository,
            negativeThoughtRepository,
          ),
        ),
        // Conflict exercise provider (Week 6)
        ChangeNotifierProvider(
          create: (_) => ConflictExerciseViewModel(conflictExerciseRepository),
        ),
        // Mood tracker provider (Week 7)
        ChangeNotifierProvider(
          create: (_) => MoodTrackerViewModel(moodTrackerRepository),
        ),
        // Role balance provider (Week 8)
        ChangeNotifierProvider(
          create: (_) => RoleBalanceViewModel(roleValueRepository),
        ),
        // Thought sky provider (Week 8)
        ChangeNotifierProvider(
          create: (_) => ThoughtSkyViewModel(skyThoughtRepository),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,

        // Force Persian RTL directionality — no language switching
        locale: const Locale('fa'),
        supportedLocales: const [Locale('fa')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],

        // Theme
        theme: AppTheme.lightTheme,

        // Routes
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/welcome-agreement': (context) => const WelcomeAgreementScreen(),
          '/roadmap': (context) => const RoadmapScreen(),
          '/home': (context) => const HomeScreen(),
          '/emotion-triangle': (context) => const EmotionTriangleScreen(),
          '/body-tension-map': (context) => const BodyTensionMapScreen(),
          '/stress-registration': (context) => const StressRegistrationScreen(),
          '/breathing': (context) => const BreathingScreen(),
          '/resilience-education': (context) =>
              const ResilienceEducationScreen(),
          '/cognitive-game': (context) => const CognitiveGameScreen(),
          '/mental-musts': (context) => const MentalMustScreen(),
          '/negative-thought-radar': (context) =>
              const NegativeThoughtRadarScreen(),
          '/mind-court': (context) => const MindCourtScreen(),
          '/conflict-exercise': (context) => const ConflictExerciseScreen(),
          '/isolation-cycle': (context) => const IsolationCycleScreen(),
          '/micro-activities': (context) => const MicroActivitiesScreen(),
          '/mood-tracker': (context) => const MoodTrackerScreen(),
          '/role-balance': (context) => const RoleBalanceScreen(),
          '/thought-sky': (context) => const ThoughtSkyScreen(),
        },
      ),
    );
  }
}
