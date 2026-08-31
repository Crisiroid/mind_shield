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
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/profile/presentation/view_models/profile_view_model.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/help_screen.dart';
import 'features/weekly_content/data/datasources/weekly_content_remote_datasource.dart';
import 'features/weekly_content/data/datasources/media_progress_remote_datasource.dart';
import 'features/weekly_content/data/datasources/media_progress_local_datasource.dart';
import 'features/weekly_content/data/repositories/weekly_content_repository.dart';
import 'features/weekly_content/data/repositories/media_progress_repository.dart';
import 'features/weekly_content/presentation/view_models/weekly_content_view_model.dart';
import 'features/weekly_content/presentation/screens/content_library_screen.dart';
import 'features/weekly_content/presentation/screens/video_player_screen.dart';
import 'features/weekly_content/presentation/screens/audio_player_screen.dart';
import 'core/services/dialog_service.dart';
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
import 'features/week1_exercise/data/datasources/week1_remote_datasource.dart';
import 'features/week1_exercise/data/datasources/week1_local_datasource.dart';
import 'features/week1_exercise/data/repositories/week1_repositories.dart';
import 'features/week1_exercise/presentation/view_models/week1_view_model.dart';
import 'features/week1_exercise/presentation/screens/week1_home_screen.dart';
import 'features/week2_exercise/presentation/view_models/week2_view_model.dart';
import 'features/week2_exercise/presentation/screens/week2_home_screen.dart';
import 'features/week3_exercise/presentation/view_models/week3_view_model.dart';
import 'features/week3_exercise/presentation/screens/week3_home_screen.dart';
import 'features/week4_exercise/presentation/view_models/week4_view_model.dart';
import 'features/week4_exercise/presentation/screens/week4_home_screen.dart';
import 'features/week5_exercise/presentation/view_models/week5_view_model.dart';
import 'features/week5_exercise/presentation/screens/week5_home_screen.dart';
import 'features/week6_exercise/presentation/view_models/week6_view_model.dart';
import 'features/week6_exercise/presentation/screens/week6_home_screen.dart';
import 'features/week7_exercise/presentation/view_models/week7_view_model.dart';
import 'features/week7_exercise/presentation/screens/week7_home_screen.dart';
import 'features/week8_exercise/presentation/view_models/week8_view_model.dart';
import 'features/week8_exercise/presentation/screens/week8_home_screen.dart';

class MindShieldApp extends StatefulWidget {
  const MindShieldApp({super.key});

  @override
  State<MindShieldApp> createState() => _MindShieldAppState();
}

class _MindShieldAppState extends State<MindShieldApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    DialogService.init(_navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);

    final authDataSource = AuthRemoteDataSourceImpl();
    final authRepository = AuthRepository(authDataSource);

    final homeDataSource = HomeRemoteDataSourceImpl();
    final homeRepository = HomeRepository(homeDataSource);

    final emotionDataSource = EmotionTriangleRemoteDataSourceImpl();
    final emotionRepository = EmotionTriangleRepository(
      emotionDataSource,
      EmotionTriangleLocalDataSource(),
    );

    final bodyTensionDataSource = BodyTensionRemoteDataSourceImpl();
    final bodyTensionRepository = BodyTensionRepository(
      bodyTensionDataSource,
      BodyTensionLocalDataSource(),
    );

    final stressDataSource = StressRemoteDataSourceImpl();
    final stressRepository = StressRepository(
      stressDataSource,
      StressLocalDataSource(),
    );

    final breathingDataSource = BreathingRemoteDataSourceImpl();
    final breathingRepository = BreathingRepository(
      breathingDataSource,
      BreathingLocalDataSource(),
    );

    final cognitiveGameDataSource = CognitiveGameRemoteDataSourceImpl();
    final cognitiveGameRepository = CognitiveGameRepository(
      cognitiveGameDataSource,
      CognitiveGameLocalDataSource(),
    );

    final mentalMustDataSource = MentalMustRemoteDataSourceImpl();
    final mentalMustRepository = MentalMustRepository(
      mentalMustDataSource,
      MentalMustLocalDataSource(),
    );

    final negativeThoughtDataSource = NegativeThoughtRemoteDataSourceImpl();
    final negativeThoughtRepository = NegativeThoughtRepository(
      negativeThoughtDataSource,
      NegativeThoughtLocalDataSource(),
    );

    final mindCourtDataSource = MindCourtRemoteDataSourceImpl();
    final mindCourtRepository = MindCourtRepository(
      mindCourtDataSource,
      MindCourtLocalDataSource(),
    );

    final conflictExerciseDataSource = ConflictExerciseRemoteDataSourceImpl();
    final conflictExerciseRepository = ConflictExerciseRepository(
      conflictExerciseDataSource,
      ConflictExerciseLocalDataSource(),
    );

    final moodTrackerDataSource = MoodTrackerRemoteDataSourceImpl();
    final moodTrackerRepository = MoodTrackerRepository(
      moodTrackerDataSource,
      MoodTrackerLocalDataSource(),
    );

    final roleValueDataSource = RoleValueRemoteDataSourceImpl();
    final roleValueRepository = RoleValueRepository(
      roleValueDataSource,
      RoleValueLocalDataSource(),
    );

    final skyThoughtDataSource = SkyThoughtRemoteDataSourceImpl();
    final skyThoughtRepository = SkyThoughtRepository(
      skyThoughtDataSource,
      SkyThoughtLocalDataSource(),
    );

    final week1ExerciseRepo = Week1ExerciseRepository(
      Week1RemoteDataSourceImpl(),
      WeeklyExerciseLocalDataSource(),
    );
    final dayProgressRepo = DayProgressRepository(
      Week1RemoteDataSourceImpl(),
      DayProgressLocalDataSource(),
    );

    final week2ExerciseRepo = Week1ExerciseRepository(
      Week1RemoteDataSourceImpl(),
      WeeklyExerciseLocalDataSource(),
    );
    final week2DayProgressRepo = DayProgressRepository(
      Week1RemoteDataSourceImpl(),
      DayProgressLocalDataSource(),
    );

    final week3ExerciseRepo = Week1ExerciseRepository(
      Week1RemoteDataSourceImpl(),
      WeeklyExerciseLocalDataSource(),
    );
    final week3DayProgressRepo = DayProgressRepository(
      Week1RemoteDataSourceImpl(),
      DayProgressLocalDataSource(),
    );

    final week4ExerciseRepo = Week1ExerciseRepository(
      Week1RemoteDataSourceImpl(),
      WeeklyExerciseLocalDataSource(),
    );
    final week4DayProgressRepo = DayProgressRepository(
      Week1RemoteDataSourceImpl(),
      DayProgressLocalDataSource(),
    );

    final week5ExerciseRepo = Week1ExerciseRepository(
      Week1RemoteDataSourceImpl(),
      WeeklyExerciseLocalDataSource(),
    );
    final week5DayProgressRepo = DayProgressRepository(
      Week1RemoteDataSourceImpl(),
      DayProgressLocalDataSource(),
    );

    final week6ExerciseRepo = Week1ExerciseRepository(
      Week1RemoteDataSourceImpl(),
      WeeklyExerciseLocalDataSource(),
    );
    final week6DayProgressRepo = DayProgressRepository(
      Week1RemoteDataSourceImpl(),
      DayProgressLocalDataSource(),
    );

    final week7ExerciseRepo = Week1ExerciseRepository(
      Week1RemoteDataSourceImpl(),
      WeeklyExerciseLocalDataSource(),
    );
    final week7DayProgressRepo = DayProgressRepository(
      Week1RemoteDataSourceImpl(),
      DayProgressLocalDataSource(),
    );

    final week8ExerciseRepo = Week1ExerciseRepository(
      Week1RemoteDataSourceImpl(),
      WeeklyExerciseLocalDataSource(),
    );
    final week8DayProgressRepo = DayProgressRepository(
      Week1RemoteDataSourceImpl(),
      DayProgressLocalDataSource(),
    );

    final profileDataSource = ProfileRemoteDataSourceImpl();
    final profileRepository = ProfileRepository(profileDataSource);

    final weeklyContentRepository = WeeklyContentRepository(
      WeeklyContentRemoteDataSourceImpl(),
    );
    final mediaProgressRepository = MediaProgressRepository(
      MediaProgressRemoteDataSourceImpl(),
      MediaProgressLocalDataSource(),
    );

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
      mediaProgressRepository,
      week1ExerciseRepo,
      dayProgressRepo,
      week2ExerciseRepo,
      week2DayProgressRepo,
      week3ExerciseRepo,
      week3DayProgressRepo,
      week4ExerciseRepo,
      week4DayProgressRepo,
      week5ExerciseRepo,
      week5DayProgressRepo,
      week6ExerciseRepo,
      week6DayProgressRepo,
      week7ExerciseRepo,
      week7DayProgressRepo,
      week8ExerciseRepo,
      week8DayProgressRepo,
    ];
    final syncManager = SyncManager(syncableRepositories);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider(InternetConnection(), syncManager),
        ),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(homeRepository, dayProgressRepo),
        ),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(
          create: (_) => EmotionTriangleViewModel(emotionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BodyTensionViewModel(bodyTensionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => StressViewModel(stressRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BreathingViewModel(breathingRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CognitiveGameViewModel(cognitiveGameRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MentalMustViewModel(mentalMustRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => NegativeThoughtViewModel(negativeThoughtRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MindCourtViewModel(
            mindCourtRepository,
            negativeThoughtRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ConflictExerciseViewModel(conflictExerciseRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MoodTrackerViewModel(moodTrackerRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => RoleBalanceViewModel(roleValueRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ThoughtSkyViewModel(skyThoughtRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(profileRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => WeeklyContentViewModel(
            weeklyContentRepository,
            mediaProgressRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => Week1ViewModel(week1ExerciseRepo, dayProgressRepo),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              Week2ViewModel(week2ExerciseRepo, week2DayProgressRepo),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              Week3ViewModel(week3ExerciseRepo, week3DayProgressRepo),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              Week4ViewModel(week4ExerciseRepo, week4DayProgressRepo),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              Week5ViewModel(week5ExerciseRepo, week5DayProgressRepo),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              Week6ViewModel(week6ExerciseRepo, week6DayProgressRepo),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              Week7ViewModel(week7ExerciseRepo, week7DayProgressRepo),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              Week8ViewModel(week8ExerciseRepo, week8DayProgressRepo),
        ),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,

        locale: const Locale('fa'),
        supportedLocales: const [Locale('fa')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],

        theme: AppTheme.lightTheme,

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
          '/profile': (context) => const ProfileScreen(),
          '/help': (context) => const HelpScreen(),
          '/content-library': (context) => const ContentLibraryScreen(),
          '/content-video': (context) => const VideoPlayerScreen(),
          '/content-audio': (context) => const AudioPlayerScreen(),
          '/week1': (context) => const Week1HomeScreen(),
          '/week2': (context) => const Week2HomeScreen(),
          '/week3': (context) => const Week3HomeScreen(),
          '/week4': (context) => const Week4HomeScreen(),
          '/week5': (context) => const Week5HomeScreen(),
          '/week6': (context) => const Week6HomeScreen(),
          '/week7': (context) => const Week7HomeScreen(),
          '/week8': (context) => const Week8HomeScreen(),
        },
      ),
    );
  }
}
