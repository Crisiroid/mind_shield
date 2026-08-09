import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../view_models/week1_view_model.dart';
import '../widgets/week1_header.dart';
import '../widgets/text_education_page.dart';
import '../widgets/stress_slider_page.dart';
import '../widgets/multi_choice_quiz_page.dart';
import '../widgets/day_end_page.dart';
import '../widgets/exit_exercise_dialog.dart';

class Day4Screen extends StatefulWidget {
  const Day4Screen({super.key});

  @override
  State<Day4Screen> createState() => _Day4ScreenState();
}

class _Day4ScreenState extends State<Day4Screen> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalSteps = 4;

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
                  dayNumber: 4,
                  dayTitle: 'واقعیت، فکر یا هیجان؟',
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
                    // D4-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week1ViewModel>().submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 4,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D4-02: Three-part education
                    TextEducationPage(
                      title: 'واقعیت، فکر و هیجان را جدا کنیم',
                      cards: const [
                        InfoCard(
                          title: 'موقعیت',
                          text:
                              'اتفاقی که دوربین نیز می\u200cتواند آن را ثبت کند.\nمثال: جلسه دیرتر شروع شد.',
                        ),
                        InfoCard(
                          title: 'فکر',
                          text:
                              'جمله، تفسیر، قضاوت، پیش\u200cبینی یا تصویر ذهنی.\nمثال: من را جدی نمی\u200cگیرند.',
                        ),
                        InfoCard(
                          title: 'هیجان',
                          text:
                              'حالتی مانند اضطراب، خشم، ناراحتی، ترس یا شرم.\nمثال: عصبانی شدم.',
                        ),
                      ],
                      noteText:
                          'تفکیک فکر از واقعیت به معنای نادرست\u200cبودن فکر نیست. فعلاً فقط آن\u200cها را از هم تشخیص می\u200cدهیم.',
                      primaryButtonText: 'تمرین کنیم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D4-03: Quiz (6 questions, 3 options each)
                    MultiChoiceQuizPage(
                      title: 'آزمون آموزشی',
                      questions: const [
                        QuizQuestion(
                          question: '«درخواست شد کار دوباره بررسی شود.»',
                          options: ['موقعیت', 'فکر', 'هیجان'],
                          correctAnswerIndex: 0,
                          feedbackWrong:
                              'آیا این جمله یک اتفاق قابل مشاهده، یک تفسیر ذهنی یا یک حالت عاطفی است؟',
                        ),
                        QuizQuestion(
                          question: '«من همیشه خراب می\u200cکنم.»',
                          options: ['موقعیت', 'فکر', 'هیجان'],
                          correctAnswerIndex: 1,
                          feedbackWrong:
                              'آیا این جمله یک اتفاق قابل مشاهده، یک تفسیر ذهنی یا یک حالت عاطفی است؟',
                        ),
                        QuizQuestion(
                          question: '«احساس ناامیدی داشتم.»',
                          options: ['موقعیت', 'فکر', 'هیجان'],
                          correctAnswerIndex: 2,
                          feedbackWrong:
                              'آیا این جمله یک اتفاق قابل مشاهده، یک تفسیر ذهنی یا یک حالت عاطفی است؟',
                        ),
                        QuizQuestion(
                          question: '«پاسخی برای پیام من ارسال نشد.»',
                          options: ['موقعیت', 'فکر', 'هیجان'],
                          correctAnswerIndex: 0,
                          feedbackWrong:
                              'آیا این جمله یک اتفاق قابل مشاهده، یک تفسیر ذهنی یا یک حالت عاطفی است؟',
                        ),
                        QuizQuestion(
                          question: '«حتماً اتفاق بدی افتاده است.»',
                          options: ['موقعیت', 'فکر', 'هیجان'],
                          correctAnswerIndex: 1,
                          feedbackWrong:
                              'آیا این جمله یک اتفاق قابل مشاهده، یک تفسیر ذهنی یا یک حالت عاطفی است؟',
                        ),
                        QuizQuestion(
                          question: '«نگران شدم.»',
                          options: ['موقعیت', 'فکر', 'هیجان'],
                          correctAnswerIndex: 2,
                          feedbackWrong:
                              'آیا این جمله یک اتفاق قابل مشاهده، یک تفسیر ذهنی یا یک حالت عاطفی است؟',
                        ),
                      ],
                      endMessage:
                          'هدف تمرین، مرور مفهوم است. می\u200cتوانید پاسخ\u200cها را دوباره ببینید.',
                      onCompleted: (score) {
                        context.read<Week1ViewModel>().submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 4,
                          exerciseType: 'situation_thought_emotion_quiz',
                          data: {'score': score, 'total': 6},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D4-04: Day end
                    DayEndPage(
                      title: 'جمع\u200cبندی روز چهارم',
                      missionText:
                          'افکار ممکن است بسیار سریع و واقعی به نظر برسند. جداکردن آن\u200cها از موقعیت کمک می\u200cکند در هفته\u200cهای بعد بتوانیم آن\u200cها را دقیق\u200cتر بررسی کنیم.\n\nامروز یک بار از خود بپرسید:\n«این یک واقعیت قابل مشاهده است یا تفسیر من؟»',
                      notificationText:
                          'امروز تفاوت واقعیت، فکر و هیجان را تمرین کنید.',
                      buttonText: 'پایان روز چهارم',
                      onButtonPressed: () {
                        context.read<Week1ViewModel>().completeDay(
                          weekNumber: 1,
                          dayNumber: 4,
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
