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
import '../widgets/five_part_form_page.dart';
import '../widgets/exit_exercise_dialog.dart';

class Day3Screen extends StatefulWidget {
  const Day3Screen({super.key});

  @override
  State<Day3Screen> createState() => _Day3ScreenState();
}

class _Day3ScreenState extends State<Day3Screen> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalSteps = 5;

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
                  dayNumber: 3,
                  dayTitle: 'موقعیت، فکر، هیجان، بدن و رفتار',
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
                    // D3-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week1ViewModel>().submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 3,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D3-02: Five-part model education
                    TextEducationPage(
                      title: 'واکنش ما از چند بخش تشکیل می\u200cشود',
                      bodyText:
                          'هنگامی که اتفاقی رخ می\u200cدهد، معمولاً فقط یک واکنش ایجاد نمی\u200cشود. افکار، هیجانات، بدن و رفتار بر یکدیگر اثر می\u200cگذارند.\n\nبرای شناخت بهتر تجربه، می\u200cتوان آن را به پنج بخش تقسیم کرد.',
                      imageWidget: Image.asset(
                        'assets/images/week1/w1_img_03.png',
                        height: 380,
                        errorBuilder: (_, __, ___) => Container(
                          height: 380,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                          child: Icon(
                            Icons.model_training,
                            size: 48,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      cards: const [
                        InfoCard(title: 'موقعیت', text: 'چه اتفاقی افتاد؟'),
                        InfoCard(
                          title: 'فکر',
                          text: 'چه جمله، تصویر یا معنایی از ذهن گذشت؟',
                        ),
                        InfoCard(title: 'هیجان', text: 'چه احساسی تجربه شد؟'),
                        InfoCard(
                          title: 'بدن',
                          text: 'چه تغییر یا احساسی در بدن ایجاد شد؟',
                        ),
                        InfoCard(
                          title: 'رفتار',
                          text: 'چه کاری انجام شد یا از چه کاری اجتناب شد؟',
                        ),
                      ],
                      bottomText:
                          'هدف از این تقسیم\u200cبندی، سرزنش\u200cکردن خود نیست. هدف این است که اجزای واکنش را واضح\u200cتر ببینیم.',
                      primaryButtonText: 'دیدن مثال',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D3-03: Educational example
                    TextEducationPage(
                      title: 'یک مثال',
                      cards: const [
                        InfoCard(
                          title: 'موقعیت',
                          text:
                              'از فرد خواسته شده است گزارشی را در زمان کوتاهی اصلاح کند.',
                        ),
                        InfoCard(
                          title: 'فکر',
                          text: '«عملکرد من حتماً بسیار ضعیف بوده است.»',
                        ),
                        InfoCard(title: 'هیجان', text: 'اضطراب و شرمندگی'),
                        InfoCard(
                          title: 'بدن',
                          text: 'افزایش ضربان قلب و انقباض شانه\u200cها',
                        ),
                        InfoCard(
                          title: 'رفتار',
                          text:
                              'به\u200cتعویق\u200cانداختن شروع کار یا بررسی مکرر گزارش',
                        ),
                      ],
                      bottomText:
                          'ممکن است افراد در یک موقعیت مشابه، افکار و واکنش\u200cهای متفاوتی داشته باشند.',
                      primaryButtonText: 'تمرین کنیم',
                      onPrimaryButton: () => _goToPage(3),
                    ),
                    // D3-04: Five-part quiz (5 questions)
                    MultiChoiceQuizPage(
                      title: 'آزمون آموزشی',
                      questions: const [
                        QuizQuestion(
                          question:
                              '«جلسه سی دقیقه دیرتر شروع شد» مربوط به کدام بخش است؟',
                          options: ['موقعیت', 'فکر', 'هیجان', 'بدن', 'رفتار'],
                          correctAnswerIndex: 0,
                          feedbackCorrect:
                              'این جمله یک اتفاق قابل مشاهده را توصیف می\u200cکند.',
                          feedbackWrong:
                              'دوباره بررسی کنید: این جمله یک اتفاق، فکر، احساس، نشانه بدنی یا عمل را توصیف می\u200cکند؟',
                        ),
                        QuizQuestion(
                          question:
                              '«حتماً من را جدی نمی\u200cگیرند» مربوط به کدام بخش است؟',
                          options: ['موقعیت', 'فکر', 'هیجان', 'بدن', 'رفتار'],
                          correctAnswerIndex: 1,
                          feedbackCorrect:
                              'این جمله یک تفسیر ذهنی درباره موقعیت است.',
                          feedbackWrong:
                              'دوباره بررسی کنید: این جمله یک اتفاق، فکر، احساس، نشانه بدنی یا عمل را توصیف می\u200cکند؟',
                        ),
                        QuizQuestion(
                          question: '«احساس خشم کردم» مربوط به کدام بخش است؟',
                          options: ['موقعیت', 'فکر', 'هیجان', 'بدن', 'رفتار'],
                          correctAnswerIndex: 2,
                          feedbackWrong:
                              'دوباره بررسی کنید: این جمله یک اتفاق، فکر، احساس، نشانه بدنی یا عمل را توصیف می\u200cکند؟',
                        ),
                        QuizQuestion(
                          question:
                              '«شانه\u200cهایم منقبض شد» مربوط به کدام بخش است؟',
                          options: ['موقعیت', 'فکر', 'هیجان', 'بدن', 'رفتار'],
                          correctAnswerIndex: 3,
                          feedbackWrong:
                              'دوباره بررسی کنید: این جمله یک اتفاق، فکر، احساس، نشانه بدنی یا عمل را توصیف می\u200cکند؟',
                        ),
                        QuizQuestion(
                          question:
                              '«از صحبت\u200cکردن خودداری کردم» مربوط به کدام بخش است؟',
                          options: ['موقعیت', 'فکر', 'هیجان', 'بدن', 'رفتار'],
                          correctAnswerIndex: 4,
                          feedbackWrong:
                              'دوباره بررسی کنید: این جمله یک اتفاق، فکر، احساس، نشانه بدنی یا عمل را توصیف می\u200cکند؟',
                        ),
                      ],
                      endMessage:
                          'هدف این تمرین، یادگیری مدل است؛ کسب نمره کامل ضروری نیست.',
                      onCompleted: (score) {
                        context.read<Week1ViewModel>().submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 3,
                          exerciseType: 'five_part_quiz',
                          data: {'score': score, 'total': 5},
                        );
                        _goToPage(4);
                      },
                    ),
                    // D3-05: Five-part form
                    FivePartFormPage(
                      title: 'یک تجربه ساده را ثبت کنید',
                      guideText:
                          'یک موقعیت خفیف یا متوسط و غیرمحرمانه را انتخاب کنید.',
                      onSubmit: (data) {
                        context.read<Week1ViewModel>().submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 3,
                          exerciseType: 'five_part_record',
                          data: data,
                        );
                        // Show completion message then go back
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusLg,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                  size: 48,
                                ),
                                SizedBox(height: AppSizes.md),
                                Text(
                                  'شما یک تجربه را به بخش\u200cهای قابل مشاهده تقسیم کردید. همین تفکیک، اولین مرحله شناخت الگوی استرس است.',
                                  style: PersianFonts.Vazir.copyWith(
                                    fontSize: AppSizes.fontMd,
                                    height: 1.8,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: AppSizes.lg),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      context
                                          .read<Week1ViewModel>()
                                          .completeDay(
                                            weekNumber: 1,
                                            dayNumber: 3,
                                          );
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('پایان روز سوم'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      skipText: 'بعداً انجام می\u200cدهم',
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
