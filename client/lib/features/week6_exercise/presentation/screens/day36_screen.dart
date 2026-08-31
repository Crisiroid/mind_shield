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
import '../view_models/week6_view_model.dart';

class Day36Screen extends StatefulWidget {
  const Day36Screen({super.key});

  @override
  State<Day36Screen> createState() => _Day36ScreenState();
}

class _Day36ScreenState extends State<Day36Screen> {
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
                  dayNumber: 36,
                  dayTitle: 'فکر، واقعیت قطعی نیست',
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
                    // D36-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week6ViewModel>().submitExerciseResponse(
                          weekNumber: 6,
                          dayNumber: 36,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D36-02: Thoughts as mental events - education
                    TextEducationPage(
                      title: 'فکرها رویدادهای ذهنی\u200cاند',
                      bodyText:
                          'ذهن به\u200cطور طبیعی فکر، تصویر، خاطره و پیش\u200cبینی تولید می\u200cکند. بعضی افکار مفیدند و بعضی ممکن است تکراری، ناراحت\u200cکننده یا نامطمئن باشند.\n\nظاهرشدن یک فکر به معنای درست\u200cبودن، مهم\u200cبودن یا الزام به عمل\u200cکردن بر اساس آن نیست.\n\nدر این هفته تلاش نمی\u200cکنیم با فکر مبارزه کنیم یا آن را به فکر دیگری تبدیل کنیم. تمرین می\u200cکنیم که ابتدا حضور آن را متوجه شویم.',
                      imageWidget: _buildW6Img01(),
                      cards: const [
                        InfoCard(
                          title: 'مثال',
                          text:
                              'فکر: «ممکن است نتوانم این کار را انجام دهم.»\nمشاهده: «متوجه می\u200cشوم که ذهن من این فکر را تولید کرده است.»',
                        ),
                      ],
                      noteText:
                          'مشاهده فکر با بی\u200cتفاوتی نسبت به واقعیت تفاوت دارد. در صورت نیاز، پس از مکث می\u200cتوانید اطلاعات را بررسی یا اقدام مناسب انجام دهید.',
                      primaryButtonText: 'ادامه',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D36-03: Thought or reality quiz
                    MultiChoiceQuizPage(
                      title: 'فکر یا واقعیت؟',
                      questions: const [
                        QuizQuestion(
                          question: '«جلسه ساعت ده آغاز شد.»',
                          options: ['واقعیت قابل مشاهده', 'فکر یا تفسیر'],
                          correctAnswerIndex: 0,
                          feedbackCorrect:
                              'صحیح! این یک واقعیت قابل مشاهده است.',
                          feedbackWrong:
                              'این جمله یک واقعیت قابل مشاهده است، نه فکر یا تفسیر.',
                        ),
                        QuizQuestion(
                          question:
                              '«حتماً حضور من برای دیگران بی\u200cاهمیت است.»',
                          options: ['واقعیت قابل مشاهده', 'فکر یا تفسیر'],
                          correctAnswerIndex: 1,
                          feedbackCorrect: 'صحیح! این یک فکر یا تفسیر است.',
                          feedbackWrong:
                              'این جمله بیان یک فکر یا تفسیر است، نه واقعیت قابل مشاهده.',
                        ),
                        QuizQuestion(
                          question:
                              'کدام جمله به مشاهده فکر نزدیک\u200cتر است؟',
                          options: [
                            'این فکر حتماً درست است.',
                            'نباید چنین فکری داشته باشم.',
                            'متوجه می\u200cشوم که این فکر اکنون در ذهن من وجود دارد.',
                            'باید فوراً فکر را حذف کنم.',
                          ],
                          correctAnswerIndex: 2,
                          feedbackCorrect:
                              'صحیح! مشاهده فکر یعنی متوجه\u200cشدن حضور فکر بدون قضاوت.',
                        ),
                        QuizQuestion(
                          question: 'وجود یک فکر چه چیزی را ثابت می\u200cکند؟',
                          options: [
                            'فکر حتماً درست است.',
                            'باید بر اساس آن عمل کرد.',
                            'فقط نشان می\u200cدهد ذهن این فکر را تولید کرده است.',
                            'فرد توانایی کنترل ذهن را ندارد.',
                          ],
                          correctAnswerIndex: 2,
                          feedbackCorrect:
                              'صحیح! وجود فکر فقط نشان\u200cدهنده تولید فکر توسط ذهن است.',
                        ),
                      ],
                      onCompleted: (score) {
                        context.read<Week6ViewModel>().submitExerciseResponse(
                          weekNumber: 6,
                          dayNumber: 36,
                          exerciseType: 'thought_as_mental_event',
                          data: {'thought_as_event_quiz_score': score},
                        );
                        _goToPage(3);
                      },
                      endMessage:
                          'آزمون برای مرور محتواست و نمره آن وضعیت روان\u200cشناختی شما را نشان نمی\u200cدهد.',
                      buttonText: 'ادامه',
                    ),
                    // D36-04: Day end
                    DayEndPage(
                      title: 'پایان روز سی\u200cوششم',
                      feedbackText:
                          'لازم نیست افکار را متوقف کنید. مهارت امروز فقط متوجه\u200cشدن حضور فکر بود.',
                      missionText:
                          'امروز یک بار، هنگام ظاهرشدن یک فکر، در ذهن خود بگویید:\n«این یک فکر است.»',
                      notificationText:
                          'امروز یک فکر را فقط به\u200cعنوان یک رویداد ذهنی مشاهده کنید.',
                      buttonText: 'پایان روز سی\u200cوششم',
                      onButtonPressed: () {
                        context.read<Week6ViewModel>().completeDay(
                          weekNumber: 6,
                          dayNumber: 36,
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

  Widget _buildW6Img01() {
    return Image.asset(
      'assets/images/week6/w6_img_01.png',
      height: 180,
      errorBuilder: (_, __, ___) => Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFlowStep('یک فکر ظاهر می\u200cشود'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('متوجه فکر می\u200cشوم'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('لازم نیست فوراً آن را باور یا اجرا کنم'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('توجه را به لحظه حال بازمی\u200cگردانم'),
            SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'فکر می\u200cتواند ظاهر شود، مدتی باقی بماند و تغییر کند.',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ),
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
