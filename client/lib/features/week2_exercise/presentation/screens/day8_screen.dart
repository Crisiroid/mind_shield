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
import '../view_models/week2_view_model.dart';

class Day8Screen extends StatefulWidget {
  const Day8Screen({super.key});

  @override
  State<Day8Screen> createState() => _Day8ScreenState();
}

class _Day8ScreenState extends State<Day8Screen> {
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
                  dayNumber: 8,
                  dayTitle: 'توجه به لحظه حال',
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
                    // D8-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 8,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D8-02: What is mindfulness?
                    TextEducationPage(
                      title: 'توجه به آنچه اکنون وجود دارد',
                      bodyText:
                          'بخش زیادی از زمان، توجه ما میان کارهای مختلف، نگرانی\u200cهای آینده و اتفاق\u200cهای گذشته حرکت می\u200cکند.\n\nذهن\u200cآگاهی یعنی توجه\u200cکردن آگاهانه به تجربه لحظه حال؛ مانند احساسات بدن، جریان تنفس، صداهای محیط یا فعالیتی که در حال انجام آن هستیم.\n\nدر این نوع توجه، هدف آن نیست که تجربه را فوراً خوب، بد، درست یا اشتباه ارزیابی کنیم. ابتدا فقط آنچه وجود دارد مشاهده می\u200cشود.',
                      imageWidget: Image.asset(
                        'assets/images/week2/w2_img_01.png',
                        height: 180,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                          child: Icon(
                            Icons.visibility_outlined,
                            size: 48,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      cards: const [
                        InfoCard(
                          title: 'قصد',
                          text: 'آگاهانه تصمیم می\u200cگیرم توجه کنم.',
                        ),
                        InfoCard(
                          title: 'توجه',
                          text: 'به تجربه همین لحظه برمی\u200cگردم.',
                        ),
                        InfoCard(
                          title: 'نگرش',
                          text:
                              'با کنجکاوی و بدون قضاوت فوری مشاهده می\u200cکنم.',
                        ),
                      ],
                      noteText:
                          'ذهن\u200cآگاهی به معنای خالی\u200cکردن ذهن یا حذف همه افکار نیست.',
                      primaryButtonText: 'ادامه',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D8-03: Observe or change? (3 questions)
                    MultiChoiceQuizPage(
                      title: 'هدف تمرین این هفته چیست؟',
                      questions: const [
                        QuizQuestion(
                          question:
                              'هنگام توجه به تنش شانه\u200cها، کدام پاسخ به مشاهده ذهن\u200cآگاهانه نزدیک\u200cتر است؟',
                          options: [
                            'باید فوراً این تنش را از بین ببرم.',
                            'فقط متوجه می\u200cشوم که در شانه\u200cها تنش وجود دارد.',
                            'این تنش نشان می\u200cدهد مشکلی جدی دارم.',
                            'نباید هیچ تنشی داشته باشم.',
                          ],
                          correctAnswerIndex: 1,
                          feedbackCorrect:
                              'در مرحله مشاهده، فقط حضور احساس را تشخیص می\u200cدهیم؛ تغییر آن اجباری نیست.',
                        ),
                        QuizQuestion(
                          question:
                              'اگر هنگام تمرین حواس شما پرت شود، چه کاری انجام می\u200cدهید؟',
                          options: [
                            'تمرین را شکست\u200cخورده می\u200cدانم.',
                            'خودم را سرزنش می\u200cکنم.',
                            'متوجه حواس\u200cپرتی می\u200cشوم و توجه را بازمی\u200cگردانم.',
                            'تلاش می\u200cکنم هیچ فکری وارد ذهن نشود.',
                          ],
                          correctAnswerIndex: 2,
                        ),
                        QuizQuestion(
                          question: 'ذهن\u200cآگاهی به چه معناست؟',
                          options: [
                            'حذف همه فکرها',
                            'آرام\u200cشدن فوری',
                            'توجه هدفمند و غیرقضاوتی به لحظه حال',
                            'نادیده\u200cگرفتن مشکلات',
                          ],
                          correctAnswerIndex: 2,
                        ),
                      ],
                      endMessage:
                          'این آزمون فقط برای مرور محتواست و نتیجه آن بیانگر وضعیت روان‌شناختی شما نیست.',
                      onCompleted: (score) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 8,
                          exerciseType: 'mindfulness_intro_quiz',
                          data: {'score': score, 'total': 3},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D8-04: Day end
                    DayEndPage(
                      title: 'پایان روز هشتم',
                      missionText:
                          'ذهن\u200cآگاهی مهارتی برای مشاهده تجربه است؛ نه آزمونی برای سنجش تمرکز و نه روشی برای وادارکردن خود به آرامش.\n\nامروز در یک لحظه کوتاه، فقط به تماس پاها با زمین، وضعیت شانه\u200cها یا صداهای محیط توجه کنید.',
                      notificationText:
                          'تمرین امروز: چند لحظه به تجربه همین لحظه توجه کنید.',
                      buttonText: 'پایان روز هشتم',
                      onButtonPressed: () {
                        context.read<Week2ViewModel>().completeDay(
                          weekNumber: 2,
                          dayNumber: 8,
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
