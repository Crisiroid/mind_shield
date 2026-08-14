import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week7_view_model.dart';

class Day45Screen extends StatefulWidget {
  const Day45Screen({super.key});

  @override
  State<Day45Screen> createState() => _Day45ScreenState();
}

class _Day45ScreenState extends State<Day45Screen> {
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
                  dayNumber: 45,
                  dayTitle: 'چند راه ممکن',
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
                    // D45-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week7ViewModel>().submitExerciseResponse(
                          weekNumber: 7,
                          dayNumber: 45,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D45-02: Rules for generating solutions
                    TextEducationPage(
                      title: 'در مرحله اول، فقط گزینه تولید می\u200cکنیم',
                      bodyText:
                          'وقتی ذهن فقط روی یک راه\u200cحل یا بن\u200cبست تمرکز می\u200cکند، احتمال دیدن گزینه\u200cهای دیگر کاهش می\u200cیابد. در مرحله تولید راه\u200cحل، ابتدا چند امکان نوشته می\u200cشود و ارزیابی آن\u200cها به روز بعد موکول می\u200cشود.',
                      cards: const [
                        InfoCard(
                          title: 'قواعد بارش فکری',
                          text:
                              '۱. در ابتدا راه\u200cها را قضاوت نکنید.\n۲. راه\u200cحل\u200cهای کوچک را نیز ثبت کنید.\n۳. می\u200cتوانید از ترکیب دو راه استفاده کنید.\n۴. راه\u200cحل\u200cها باید قانونی، ایمن و هماهنگ با مقررات باشند.\n۵. مجبور نیستید حتماً راه\u200cحل کاملی پیدا کنید.',
                        ),
                        InfoCard(
                          title: 'مثال',
                          text:
                              'مشکل: اطلاعات کافی برای انجام یک کار وجود ندارد.\nراه\u200cهای ممکن:\n• پرسیدن سؤال روشن از فرد مسئول\n• بررسی منبع یا دستورالعمل موجود\n• درخواست کمک از همکار مجاز\n• انجام بخش\u200cهایی که اطلاعات آن\u200cها موجود است\n• مشخص\u200cکردن محدودیت و درخواست زمان بیشتر',
                        ),
                      ],
                      primaryButtonText: 'راه\u200cهای ممکن را بنویسم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D45-03: Register solutions
                    _buildSolutionForm(),
                    // D45-04: Day end
                    DayEndPage(
                      title: 'پایان روز چهل\u200cوپنجم',
                      feedbackText:
                          'امروز لازم نبود بهترین راه\u200cحل را انتخاب کنید. هدف، خارج\u200cشدن از حالت «فقط یک راه یا هیچ راه» بود.',
                      missionText:
                          'تا فردا فقط اجازه دهید گزینه\u200cهای دیگری نیز به ذهن برسند؛ بدون اینکه مجبور باشید آن\u200cها را اجرا کنید.',
                      notificationText:
                          'امروز بدون قضاوت اولیه، چند راه ممکن برای مشکل خود بنویسید.',
                      buttonText: 'پایان روز چهل\u200cوپنجم',
                      onButtonPressed: () {
                        context.read<Week7ViewModel>().completeDay(
                          weekNumber: 7,
                          dayNumber: 45,
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

  // D45-03 form state
  final _solution1Ctrl = TextEditingController();
  final _solution2Ctrl = TextEditingController();
  final _solution3Ctrl = TextEditingController();
  bool _safetyAcknowledged = false;
  bool _showHelperQuestions = false;

  final _helperQuestions = [
    'از چه کسی می\u200cتوانم اطلاعات یا کمک بخواهم؟',
    'آیا می\u200cتوانم مسئله را به بخش کوچک\u200cتر تقسیم کنم؟',
    'چه منبعی در اختیار دارم؟',
    'آیا زمان یا ترتیب کار قابل تغییر است؟',
    'اگر فرد دیگری بود، چه گزینه\u200cای پیشنهاد می\u200cدادم؟',
  ];

  bool get _canSubmitSolutions =>
      _solution1Ctrl.text.trim().isNotEmpty &&
      _solution2Ctrl.text.trim().isNotEmpty &&
      _safetyAcknowledged;

  Widget _buildSolutionForm() {
    final vm = context.read<Week7ViewModel>();
    final problem = vm.problemDefinition;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ثبت راه\u200cحل\u200cها',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Display problem if available
          if (problem != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مشکل شما:',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontXs,
                      color: AppColors.textHint,
                    ),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    problem['problem_description'] ?? '',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.lg),
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Text(
                'مشکل را کوتاه بنویسید.',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.info,
                ),
              ),
            ),
            SizedBox(height: AppSizes.lg),
          ],
          // Solution 1
          Text(
            'راه\u200cحل اول',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'اولین راه ممکن چیست؟ حداکثر ۱۵۰ کاراکتر.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: _solution1Ctrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'راه\u200cحل اول...',
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
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
          // Solution 2
          Text(
            'راه\u200cحل دوم',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'راه دیگری چه می\u200cتواند باشد؟ حداکثر ۱۵۰ کاراکتر.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: _solution2Ctrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'راه\u200cحل دوم...',
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
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
          // Solution 3 (optional)
          Text(
            'راه\u200cحل سوم (اختیاری)',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'گزینه سوم یا ترکیبی از دو راه چیست؟ حداکثر ۱۵۰ کاراکتر.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: _solution3Ctrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'راه\u200cحل سوم...',
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
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
          // Helper questions toggle
          InkWell(
            onTap: () =>
                setState(() => _showHelperQuestions = !_showHelperQuestions),
            child: Row(
              children: [
                Icon(
                  _showHelperQuestions ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSizes.xs),
                Text(
                  'سؤال\u200cهای راهنما',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (_showHelperQuestions) ...[
            SizedBox(height: AppSizes.sm),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'در صورت دشواری، کدام سؤال ممکن است کمک کند؟',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontXs,
                      color: AppColors.textHint,
                    ),
                  ),
                  SizedBox(height: AppSizes.xs),
                  ..._helperQuestions.map(
                    (q) => Padding(
                      padding: EdgeInsets.only(bottom: AppSizes.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: AppSizes.xs),
                          Expanded(
                            child: Text(
                              q,
                              style: PersianFonts.Vazir.copyWith(
                                fontSize: AppSizes.fontXs,
                                height: 1.6,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSizes.lg),
          // Safety checkbox
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: AppSizes.xs),
            child: Material(
              color: _safetyAcknowledged
                  ? AppColors.success.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: InkWell(
                onTap: () =>
                    setState(() => _safetyAcknowledged = !_safetyAcknowledged),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Container(
                  padding: EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: _safetyAcknowledged
                          ? AppColors.success
                          : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _safetyAcknowledged,
                          onChanged: (v) =>
                              setState(() => _safetyAcknowledged = v ?? false),
                          activeColor: AppColors.success,
                        ),
                      ),
                      SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          'راه\u200cحل\u200cها با ایمنی و مقررات مربوط هماهنگ\u200cاند.',
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
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitSolutions ? _submitSolutions : null,
              child: const Text('ثبت راه\u200cحل\u200cها'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _submitSolutions() {
    context.read<Week7ViewModel>().submitExerciseResponse(
      weekNumber: 7,
      dayNumber: 45,
      exerciseType: 'solution_generation',
      data: {
        'solution_1': _solution1Ctrl.text.trim(),
        'solution_2': _solution2Ctrl.text.trim(),
        'solution_3': _solution3Ctrl.text.trim().isNotEmpty
            ? _solution3Ctrl.text.trim()
            : null,
        'solutions_safety_acknowledged': _safetyAcknowledged,
      },
    );
    _goToPage(3);
  }
}
