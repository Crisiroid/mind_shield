import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/multi_choice_quiz_page.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week3_view_model.dart';

class Day16Screen extends StatefulWidget {
  const Day16Screen({super.key});

  @override
  State<Day16Screen> createState() => _Day16ScreenState();
}

class _Day16ScreenState extends State<Day16Screen> {
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
                  dayNumber: 16,
                  dayTitle: 'فکر چه اثری دارد؟',
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
                    // D16-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week3ViewModel>().submitExerciseResponse(
                          weekNumber: 3,
                          dayNumber: 16,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D16-02: Thought and emotion
                    TextEducationPage(
                      title: 'یک موقعیت، فکرهای متفاوت',
                      bodyText:
                          'خود موقعیت تنها عامل تعیین\u200cکننده هیجان نیست. تفسیری که از موقعیت داریم نیز بر احساس و رفتار ما اثر می\u200cگذارد.\n\nدو نفر ممکن است در یک موقعیت مشابه، فکرهای متفاوت و در نتیجه هیجان\u200cهای متفاوتی تجربه کنند.',
                      cards: const [
                        InfoCard(
                          title: 'موقعیت',
                          text:
                              'مدیر از فرد می\u200cخواهد پس از جلسه با او صحبت کند.',
                        ),
                        InfoCard(
                          title: 'فکر اول',
                          text:
                              '«حتماً اشتباه بزرگی کرده\u200cام.»\nهیجان احتمالی: اضطراب',
                        ),
                        InfoCard(
                          title: 'فکر دوم',
                          text:
                              '«ممکن است فقط درباره ادامه کار سؤال داشته باشد.»\nهیجان احتمالی: کنجکاوی یا نگرانی کمتر',
                        ),
                      ],
                      noteText:
                          'هدف این مثال اثبات درست\u200cبودن فکر دوم نیست؛ فقط نشان می\u200cدهد چند تفسیر ممکن است وجود داشته باشد.',
                      primaryButtonText: 'ادامه',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D16-03: Belief level quiz (3 questions)
                    MultiChoiceQuizPage(
                      title: 'چقدر این فکر را باور دارم؟',
                      questions: const [
                        QuizQuestion(
                          question:
                              'فرد فکر می\u200cکند: «حتماً همه متوجه اشتباه من شده\u200cاند.»\nاگر این فکر برای او بسیار واقعی به نظر برسد، کدام نمره مناسب\u200cتر است؟',
                          options: ['۱', '۳', '۸', 'هیچ\u200cکدام'],
                          correctAnswerIndex: 2,
                        ),
                        QuizQuestion(
                          question:
                              'میزان باور به فکر چه چیزی را نشان می\u200cدهد؟',
                          options: [
                            'درست یا غلط\u200cبودن قطعی فکر',
                            'میزان واقعی\u200cبه\u200cنظررسیدن فکر برای فرد',
                            'شدت بیماری',
                            'توانایی فرد',
                          ],
                          correctAnswerIndex: 1,
                        ),
                        QuizQuestion(
                          question:
                              'اگر باور به فکر ۹ باشد، آیا فکر حتماً درست است؟',
                          options: ['بله', 'خیر'],
                          correctAnswerIndex: 1,
                        ),
                      ],
                      endMessage:
                          'این آزمون فقط برای مرور محتواست و نتیجه آن بیانگر وضعیت روان\u200cشناختی شما نیست.',
                      onCompleted: (score) {
                        context.read<Week3ViewModel>().submitExerciseResponse(
                          weekNumber: 3,
                          dayNumber: 16,
                          exerciseType: 'thought_belief',
                          data: {'score': score, 'total': 3},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D16-04: Day end
                    DayEndPage(
                      title: 'پایان روز شانزدهم',
                      missionText:
                          'شدت باور به یک فکر ممکن است زیاد باشد، اما میزان باور با حقیقت قطعی یکسان نیست.\n\nاگر امروز فکر ناراحت\u200cکننده\u200cای متوجه شدید، فقط بررسی کنید:\n«از صفر تا ده چقدر آن را باور دارم؟»',
                      notificationText:
                          'امروز میزان باور خود به یک فکر را بررسی کنید.',
                      buttonText: 'پایان روز شانزدهم',
                      onButtonPressed: () {
                        context.read<Week3ViewModel>().completeDay(
                          weekNumber: 3,
                          dayNumber: 16,
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
