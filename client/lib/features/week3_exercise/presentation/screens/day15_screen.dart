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
import '../view_models/week3_view_model.dart';

class Day15Screen extends StatefulWidget {
  const Day15Screen({super.key});

  @override
  State<Day15Screen> createState() => _Day15ScreenState();
}

class _Day15ScreenState extends State<Day15Screen> {
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
                  dayNumber: 15,
                  dayTitle: 'فکرهای سریع ذهن',
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
                    // D15-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week3ViewModel>().submitExerciseResponse(
                          weekNumber: 3,
                          dayNumber: 15,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D15-02: What is automatic thought?
                    TextEducationPage(
                      title: 'بعضی فکرها خیلی سریع ظاهر می\u200cشوند',
                      bodyText:
                          'وقتی اتفاقی رخ می\u200cدهد، معمولاً جمله، تصویر یا معنایی به\u200cسرعت از ذهن ما عبور می\u200cکند. به این تجربه «فکر خودکار» گفته می\u200cشود.\n\nفکر خودکار ممکن است آن\u200cقدر سریع ظاهر شود که ابتدا فقط هیجان یا واکنش بدنی خود را متوجه شویم.\n\nبرای مثال، پس از دریافت درخواست اصلاح یک کار، ممکن است فکر «من خراب کردم» سریع از ذهن عبور کند و بعد اضطراب، شرم یا تنش بدنی ایجاد شود.',
                      imageWidget: _buildW3Img01(),
                      cards: const [
                        InfoCard(
                          title: 'نکته',
                          text:
                              'فکر خودکار می\u200cتواند یک جمله، تصویر ذهنی، خاطره کوتاه یا پیش\u200cبینی باشد.',
                        ),
                        InfoCard(
                          title: 'مهم',
                          text:
                              'وجود یک فکر به\u200cتنهایی ثابت نمی\u200cکند که آن فکر کاملاً درست است.',
                        ),
                      ],
                      primaryButtonText: 'ادامه',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D15-03: Situation or thought? (4 questions)
                    MultiChoiceQuizPage(
                      title: 'موقعیت را از فکر جدا کنیم',
                      questions: const [
                        QuizQuestion(
                          question:
                              '«مسئول مربوطه درخواست کرد گزارش دوباره بررسی شود.»',
                          options: ['موقعیت', 'فکر'],
                          correctAnswerIndex: 0,
                          feedbackCorrect:
                              'این جمله یک اتفاق قابل مشاهده را توصیف می\u200cکند.',
                        ),
                        QuizQuestion(
                          question: '«حتماً از عملکرد من ناراضی\u200cاند.»',
                          options: ['موقعیت', 'فکر'],
                          correctAnswerIndex: 1,
                        ),
                        QuizQuestion(
                          question: '«جلسه بدون حضور من شروع شد.»',
                          options: ['موقعیت', 'فکر'],
                          correctAnswerIndex: 0,
                        ),
                        QuizQuestion(
                          question:
                              '«احتمالاً من را فرد قابل اعتمادی نمی\u200cدانند.»',
                          options: ['موقعیت', 'فکر'],
                          correctAnswerIndex: 1,
                          feedbackWrong:
                              'آیا دوربین می\u200cتوانست این جمله را ثبت کند، یا این جمله تفسیر ذهن است؟',
                        ),
                      ],
                      endMessage:
                          'این آزمون فقط برای مرور محتواست و نتیجه آن بیانگر وضعیت روان\u200cشناختی شما نیست.',
                      onCompleted: (score) {
                        context.read<Week3ViewModel>().submitExerciseResponse(
                          weekNumber: 3,
                          dayNumber: 15,
                          exerciseType: 'automatic_thought_intro',
                          data: {'score': score, 'total': 4},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D15-04: Day end
                    DayEndPage(
                      title: 'پایان روز پانزدهم',
                      missionText:
                          'فکرهای خودکار معمولاً سریع، کوتاه و باورپذیر به نظر می\u200cرسند. اولین قدم این است که حضور آن\u200cها را متوجه شویم.\n\nامروز فقط یک بار از خود بپرسید:\n«در این لحظه چه جمله یا تصویری از ذهن من گذشت؟»',
                      notificationText:
                          'امروز یک فکر سریع و خودکار را شناسایی کنید.',
                      buttonText: 'پایان روز پانزدهم',
                      onButtonPressed: () {
                        context.read<Week3ViewModel>().completeDay(
                          weekNumber: 3,
                          dayNumber: 15,
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

  Widget _buildW3Img01() {
    return Image.asset(
      'assets/images/week3/w3_img_01.png',
      height: 180,
      errorBuilder: (_, __, ___) => Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            _buildFlowStep('موقعیت'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('فکر خودکار'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('هیجان و بدن'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('رفتار'),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStep(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: PersianFonts.Vazir.copyWith(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
