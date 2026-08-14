import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/multi_choice_quiz_page.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week4_view_model.dart';

class Day26Screen extends StatefulWidget {
  const Day26Screen({super.key});

  @override
  State<Day26Screen> createState() => _Day26ScreenState();
}

class _Day26ScreenState extends State<Day26Screen> {
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
                  dayNumber: 26,
                  dayTitle: 'تمرین بررسی شواهد',
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
                    // D26-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week4ViewModel>().submitExerciseResponse(
                          weekNumber: 4,
                          dayNumber: 26,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D26-02: Educational scenario
                    TextEducationPage(
                      title: 'یک مثال را با هم بررسی می\u200cکنیم',
                      bodyText:
                          'موقعیت: فردی گزارشی را تحویل داده و از او خواسته شده است دو بخش آن را اصلاح کند.\n\nفکر خودکار: «من هیچ کاری را درست انجام نمی\u200cدهم.»\n\nهیجان: اضطراب و ناامیدی\n\nباور به فکر: ۸ از ۱۰',
                      cards: const [
                        InfoCard(
                          title: 'نکته',
                          text:
                              'در این تمرین، با یک مثال آماده مهارت بررسی شواهد را تمرین می\u200cکنید. نیازی به ثبت شخصی نیست.',
                        ),
                      ],
                      primaryButtonText: 'بررسی شواهد',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D26-03: 4-question quiz
                    MultiChoiceQuizPage(
                      title: 'سؤال\u200cهای بررسی شواهد',
                      questions: const [
                        QuizQuestion(
                          question: 'کدام مورد یک شاهد موافق واقعی است؟',
                          options: [
                            'من احساس می\u200cکنم بی\u200cکفایتم.',
                            'دو بخش گزارش برای اصلاح بازگردانده شده است.',
                            'من هیچ کاری را درست انجام نمی\u200cدهم.',
                            'احتمالاً همه از من ناراضی\u200cاند.',
                          ],
                          correctAnswerIndex: 1,
                        ),
                        QuizQuestion(
                          question: 'کدام مورد اطلاعات مخالف یا تکمیلی است؟',
                          options: [
                            'بخش\u200cهای دیگر گزارش پذیرفته شده\u200cاند.',
                            'من ناامید شده\u200cام.',
                            'اصلاح گزارش ناخوشایند است.',
                            'احتمالاً این اتفاق همیشه تکرار می\u200cشود.',
                          ],
                          correctAnswerIndex: 0,
                        ),
                        QuizQuestion(
                          question: 'کدام توضیح جایگزین ممکن است؟',
                          options: [
                            'درخواست اصلاح حتماً به معنای بی\u200cکفایتی کامل است.',
                            'ممکن است استاندارد یا اطلاعات مورد انتظار از ابتدا کاملاً روشن نبوده باشد.',
                            'هیچ توضیح دیگری وجود ندارد.',
                            'چون مضطربم، فکر من حتماً درست است.',
                          ],
                          correctAnswerIndex: 1,
                        ),
                        QuizQuestion(
                          question: 'کدام فکر متعادل\u200cتر است؟',
                          options: [
                            'من در همه کارها عالی هستم.',
                            'این گزارش هیچ مشکلی نداشته است.',
                            'دو بخش نیاز به اصلاح دارند، اما بخش\u200cهای دیگر پذیرفته شده\u200cاند و می\u200cتوانم موارد مشخص را اصلاح کنم.',
                            'من همیشه همه\u200cچیز را خراب می\u200cکنم.',
                          ],
                          correctAnswerIndex: 2,
                        ),
                      ],
                      endMessage:
                          'فکر متعادل هم مشکل واقعی را می\u200cپذیرد و هم اطلاعاتی را که فکر اولیه نادیده گرفته بود در نظر می\u200cگیرد.',
                      onCompleted: (score) {
                        context.read<Week4ViewModel>().submitExerciseResponse(
                          weekNumber: 4,
                          dayNumber: 26,
                          exerciseType: 'guided_restructuring_quiz',
                          data: {'score': score, 'total': 4},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D26-04: Day end
                    DayEndPage(
                      title: 'پایان روز بیست\u200cوششم',
                      missionText:
                          'بازسازی شناختی یک مهارت است و با تکرار آسان\u200cتر می\u200cشود. هدف، پیدا کردن پاسخ کاملاً مثبت نیست؛ هدف، بررسی کامل\u200cتر اطلاعات است.\n\nمأموریت: امروز یک بار از خود بپرسید: «آیا اطلاعات دیگری نیز وجود دارد که ذهن من اکنون نادیده گرفته است؟»',
                      notificationText:
                          'امروز مهارت بررسی شواهد را با یک مثال کوتاه تمرین کنید.',
                      buttonText: 'پایان روز بیست\u200cوششم',
                      onButtonPressed: () {
                        context.read<Week4ViewModel>().completeDay(
                          weekNumber: 4,
                          dayNumber: 26,
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
