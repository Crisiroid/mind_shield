import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../view_models/week1_view_model.dart';
import '../widgets/week1_header.dart';
import '../widgets/text_education_page.dart';
import '../widgets/multi_choice_quiz_page.dart';
import '../widgets/week_summary_page.dart';
import '../widgets/week_evaluation_page.dart';
import '../widgets/week_end_page.dart';
import '../widgets/exit_exercise_dialog.dart';

class Day7Screen extends StatefulWidget {
  const Day7Screen({super.key});

  @override
  State<Day7Screen> createState() => _Day7ScreenState();
}

class _Day7ScreenState extends State<Day7Screen> {
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
                  dayNumber: 7,
                  dayTitle: 'مرور هفته اول',
                  currentStep: _currentPage,
                  totalSteps: _totalSteps,
                ),
              ),
              Expanded(
                child: Consumer<Week1ViewModel>(
                  builder: (context, vm, _) {
                    return PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) =>
                          setState(() => _currentPage = page),
                      children: [
                        // D7-01: Week summary
                        WeekSummaryPage(
                          daysCompleted: vm.completedDaysCount,
                          exercisesSubmitted: vm.exerciseCount,
                          averageStress: vm.averageStressScore,
                          onContinue: () => _goToPage(1),
                        ),
                        // D7-02: Personal review (3 questions)
                        _D7PersonalReview(
                          onSubmit: (data) {
                            vm.submitExerciseResponse(
                              weekNumber: 1,
                              dayNumber: 7,
                              exerciseType: 'weekly_review',
                              data: data,
                            );
                            _goToPage(2);
                          },
                        ),
                        // D7-03: Quiz (4 questions)
                        MultiChoiceQuizPage(
                          title: 'آزمون آموزشی',
                          questions: const [
                            QuizQuestion(
                              question:
                                  'در مدل فشارها و منابع، استرس چه زمانی بیشتر می\u200cشود؟',
                              options: [
                                'وقتی منابع بیشتر از فشارها هستند.',
                                'وقتی فشارها بیشتر از منابع ادراک\u200cشده هستند.',
                                'فقط وقتی خطر جسمانی وجود دارد.',
                                'فقط وقتی فرد مهارت کافی ندارد.',
                              ],
                              correctAnswerIndex: 1,
                            ),
                            QuizQuestion(
                              question:
                                  '«حتماً من را جدی نمی\u200cگیرند» کدام بخش است؟',
                              options: ['موقعیت', 'فکر', 'هیجان', 'رفتار'],
                              correctAnswerIndex: 1,
                            ),
                            QuizQuestion(
                              question:
                                  '«شانه\u200cهایم منقبض شد» کدام بخش است؟',
                              options: ['فکر', 'هیجان', 'بدن', 'رفتار'],
                              correctAnswerIndex: 2,
                            ),
                            QuizQuestion(
                              question: 'هدف اصلی هفته اول چه بود؟',
                              options: [
                                'حذف کامل استرس',
                                'تغییر فوری تمام افکار',
                                'مشاهده و ثبت الگوی واکنش',
                                'جلوگیری از همه هیجان\u200cهای ناخوشایند',
                              ],
                              correctAnswerIndex: 2,
                            ),
                          ],
                          endMessage:
                              'هدف آزمون، مرور مفاهیم است؛ نمره شما بیانگر توانایی یا وضعیت روان\u200cشناختی شما نیست.',
                          onCompleted: (score) {
                            vm.submitExerciseResponse(
                              weekNumber: 1,
                              dayNumber: 7,
                              exerciseType: 'weekly_quiz',
                              data: {'score': score, 'total': 4},
                            );
                            _goToPage(3);
                          },
                        ),
                        // D7-04: Week evaluation
                        WeekEvaluationPage(
                          onSubmit: (data) {
                            vm.submitExerciseResponse(
                              weekNumber: 1,
                              dayNumber: 7,
                              exerciseType: 'weekly_evaluation',
                              data: data,
                            );
                            _goToPage(4);
                          },
                          onHelpNeeded: () {
                            // Navigate to help section
                          },
                        ),
                        // D7-05: Week end
                        WeekEndPage(
                          onFinish: () {
                            vm.completeDay(weekNumber: 1, dayNumber: 7);
                            Navigator.of(context).pop();
                          },
                          onReviewSummary: () => _goToPage(0),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// D7-02: Personal review form with 3 questions
class _D7PersonalReview extends StatefulWidget {
  final ValueChanged<Map<String, String>> onSubmit;
  const _D7PersonalReview({required this.onSubmit});

  @override
  State<_D7PersonalReview> createState() => _D7PersonalReviewState();
}

class _D7PersonalReviewState extends State<_D7PersonalReview> {
  final _learningCtrl = TextEditingController();
  String? _firstWarningSign;
  String? _mostUsefulExercise;

  final _warningSigns = [
    'یک فکر یا نگرانی',
    'یک هیجان',
    'یک نشانه بدنی',
    'یک تغییر رفتاری',
    'هنوز مطمئن نیستم',
  ];

  final _usefulExercises = [
    'فشارها و منابع',
    'مدل پنج\u200cبخشی',
    'واقعیت، فکر و هیجان',
    'نشانه\u200cهای بدن و رفتار',
    'ثبت رخداد واقعی',
    'هیچ\u200cکدام',
    'مطمئن نیستم',
  ];

  @override
  void dispose() {
    _learningCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _learningCtrl.text.isNotEmpty &&
      _firstWarningSign != null &&
      _mostUsefulExercise != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرور شخصی',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q1
          Text(
            'مهم\u200cترین چیزی که این هفته درباره استرس خود آموختید چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          TextField(
            controller: _learningCtrl,
            maxLength: 200,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'پاسخ خود را بنویسید...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2
          Text(
            'اولین نشانه\u200cای که هنگام استرس متوجه می\u200cشوید چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._warningSigns.map(
            (opt) => _buildRadio(
              opt,
              _firstWarningSign,
              (v) => setState(() => _firstWarningSign = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3
          Text(
            'کدام تمرین این هفته برای شما مفیدتر بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._usefulExercises.map(
            (opt) => _buildRadio(
              opt,
              _mostUsefulExercise,
              (v) => setState(() => _mostUsefulExercise = v),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit
                  ? () => widget.onSubmit({
                      'weekly_learning': _learningCtrl.text,
                      'first_warning_sign': _firstWarningSign ?? '',
                      'most_useful_exercise': _mostUsefulExercise ?? '',
                    })
                  : null,
              child: const Text('ثبت مرور'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildRadio(
    String value,
    String? groupValue,
    ValueChanged<String?> onChanged,
  ) {
    final isSelected = groupValue == value;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSizes.sm),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: value,
                  groupValue: groupValue,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    value,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
