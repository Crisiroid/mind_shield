import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/audio_player_page.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week2_view_model.dart';

class Day12Screen extends StatefulWidget {
  const Day12Screen({super.key});

  @override
  State<Day12Screen> createState() => _Day12ScreenState();
}

class _Day12ScreenState extends State<Day12Screen> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && _currentPage > 0) {
          final shouldExit = await ExitExerciseDialog.show(context);
          if (shouldExit && context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: AppSizes.paddingScreen,
                child: Week1Header(
                  dayNumber: 12,
                  dayTitle: 'سه دقیقه مکث و تنفس',
                  currentStep: _currentPage,
                  totalSteps: _totalSteps,
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    // D12-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 12,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D12-02: 3-minute audio + question
                    AudioPlayerPage(
                      title: 'سه دقیقه مکث و تنفس',
                      instruction:
                          'امروز محتوای آموزشی جدیدی ارائه نمی\u200cشود. تمرین روزهای قبل را کمی طولانی\u200cتر تکرار می\u200cکنید.',
                      audioAssetPath: 'assets/audio/week2/w2_aud_04.mp3',
                      safetyText:
                          'در وضعیت امن انجام دهید. لازم نیست تنفس را عمیق یا کنترل کنید.',
                      questionText: 'چه مقدار از تمرین را انجام دادید؟',
                      statusOptions: const ['کامل', 'بخشی', 'انجام ندادم'],
                      skipText: 'عبور از تمرین',
                      onSkip: () {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 12,
                          exerciseType: 'three_minute_breathing',
                          data: {'status': 'skipped'},
                        );
                        _goToPage(2);
                      },
                      onSubmit: (status) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 12,
                          exerciseType: 'three_minute_breathing',
                          data: {'status': status},
                        );
                        _goToPage(2);
                      },
                    ),
                    // D12-03: Day end
                    DayEndPage(
                      title: 'پایان روز دوازدهم',
                      missionText:
                          'تمرین کوتاه و منظم معمولاً از تمرین طولانی و پراکنده قابل اجرا\u200cتر است.\n\nامروز در صورت امکان، پیش از یک فعالیت عادی مانند شروع کار یا استراحت، یک دم و بازدم طبیعی را آگاهانه مشاهده کنید.',
                      notificationText:
                          'تمرین سه\u200cدقیقه\u200cای تنفس آماده است.',
                      buttonText: 'پایان روز دوازدهم',
                      onButtonPressed: () {
                        context.read<Week2ViewModel>().completeDay(
                          weekNumber: 2,
                          dayNumber: 12,
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
