import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/multi_choice_quiz_page.dart';
import '../../../week1_exercise/presentation/widgets/week_evaluation_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week7_view_model.dart';

class Day49Screen extends StatefulWidget {
  const Day49Screen({super.key});

  @override
  State<Day49Screen> createState() => _Day49ScreenState();
}

class _Day49ScreenState extends State<Day49Screen> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalSteps = 6;

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
                  dayNumber: 49,
                  dayTitle: 'نتیجه برنامه را بررسی کنیم',
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
                    // D49-01: Week summary
                    Consumer<Week7ViewModel>(
                      builder: (context, vm, _) => _buildWeekSummary(vm),
                    ),
                    // D49-02: Action review
                    _buildActionReview(),
                    // D49-03: Modify or continue plan
                    _buildNextStepForm(),
                    // D49-04: Quiz and evaluation
                    MultiChoiceQuizPage(
                      title: 'آزمون هفته هفتم',
                      questions: const [
                        QuizQuestion(
                          question: 'اولین مرحله حل مسئله چیست؟',
                          options: [
                            'انتخاب سریع یک راه',
                            'تعریف دقیق مشکل',
                            'ارزیابی نتیجه',
                            'درخواست کمک',
                          ],
                          correctAnswerIndex: 1,
                          feedbackCorrect:
                              'صحیح! تعریف دقیق مشکل اولین مرحله است.',
                        ),
                        QuizQuestion(
                          question:
                              'در مرحله تولید راه\u200cحل چه کاری انجام می\u200cدهیم؟',
                          options: [
                            'اولین راه را فوراً اجرا می\u200cکنیم.',
                            'ابتدا چند گزینه ممکن تولید می\u200cکنیم.',
                            'خود را بابت مشکل سرزنش می\u200cکنیم.',
                            'فقط بهترین گزینه را می\u200cنویسیم.',
                          ],
                          correctAnswerIndex: 1,
                          feedbackCorrect:
                              'صحیح! ابتدا چند گزینه ممکن تولید می\u200cکنیم بدون قضاوت.',
                        ),
                        QuizQuestion(
                          question: 'کدام معیار در انتخاب راه\u200cحل مهم است؟',
                          options: [
                            'فقط سرعت',
                            'فقط رضایت دیگران',
                            'فایده، امکان اجرا، ایمنی و سازگاری',
                            'دشواربودن بیشتر',
                          ],
                          correctAnswerIndex: 2,
                          feedbackCorrect:
                              'صحیح! فایده، امکان اجرا، ایمنی و سازگاری همگی مهم\u200cاند.',
                        ),
                        QuizQuestion(
                          question: 'ارتباط قاطعانه چیست؟',
                          options: [
                            'مجبورکردن دیگری به موافقت',
                            'سکوت\u200cکردن برای جلوگیری از تعارض',
                            'بیان روشن و محترمانه درخواست',
                            'بیان خشم بدون محدودیت',
                          ],
                          correctAnswerIndex: 2,
                          feedbackCorrect:
                              'صحیح! بیان روشن و محترمانه درخواست بدون اجبار.',
                        ),
                        QuizQuestion(
                          question:
                              'اگر راه\u200cحل نتیجه کامل نداد، چه کاری مناسب\u200cتر است؟',
                          options: [
                            'نتیجه بگیریم هیچ راهی وجود ندارد.',
                            'فرایند را مرور و برنامه را اصلاح کنیم.',
                            'خود را سرزنش کنیم.',
                            'مسئله را نادیده بگیریم.',
                          ],
                          correctAnswerIndex: 1,
                          feedbackCorrect:
                              'صحیح! مرور فرایند و اصلاح برنامه بخشی طبیعی از حل مسئله است.',
                        ),
                      ],
                      onCompleted: (score) {
                        context.read<Week7ViewModel>().submitExerciseResponse(
                          weekNumber: 7,
                          dayNumber: 49,
                          exerciseType: 'week_7_quiz',
                          data: {'week_7_quiz_score': score},
                        );
                        _goToPage(4);
                      },
                      endMessage:
                          'آزمون برای مرور محتواست و نمره آن وضعیت روان\u200cشناختی شما را نشان نمی\u200cدهد.',
                      buttonText: 'ادامه',
                    ),
                    // D49-04b: Week evaluation
                    WeekEvaluationPage(
                      onSubmit: (data) {
                        context.read<Week7ViewModel>().submitExerciseResponse(
                          weekNumber: 7,
                          dayNumber: 49,
                          exerciseType: 'week_7_evaluation',
                          data: {
                            'week_7_clarity_score': data['clarity_score'],
                            'problem_solving_usability':
                                data['usefulness_score'],
                            'week_7_form_rating': data['duration_rating'],
                            'week_7_significant_distress':
                                data['significant_distress'],
                          },
                        );
                        _goToPage(5);
                      },
                      onHelpNeeded: () {
                        // Navigate to help section
                      },
                      questionTwoText:
                          'مراحل حل مسئله چقدر قابل استفاده بودند؟',
                    ),
                    // D49-05: Week end
                    _buildWeekEnd(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // D49-02 form state
  String? _executionStatus;
  double _goalProgress = 5;
  String? _helpfulFactor;
  final _remainingCtrl = TextEditingController();
  String? _executionBarrier;

  final _executionOptions = [
    'کامل انجام شد.',
    'بخشی انجام شد.',
    'مقدمات آن را انجام دادم.',
    'انجام نشد.',
    'هنوز زمان اجرای آن نرسیده است.',
  ];

  final _helpfulOptions = [
    'تعریف روشن مشکل',
    'کوچک\u200cبودن قدم',
    'زمان\u200cبندی مناسب',
    'دریافت اطلاعات',
    'کمک یا حمایت',
    'استفاده از جمله قاطعانه',
    'انعطاف در برنامه',
    'عامل دیگر',
    'مطمئن نیستم',
  ];

  final _barrierOptions = [
    'وقت کافی نبود.',
    'شرایط تغییر کرد.',
    'قدم بیش از حد بزرگ بود.',
    'اطلاعات یا اجازه لازم وجود نداشت.',
    'فراموش کردم.',
    'نگرانی از واکنش دیگران مانع شد.',
    'مسئله دیگر اولویت نداشت.',
    'مانع دیگر',
    'ترجیح می\u200cدهم پاسخ ندهم.',
  ];

  bool get _canSubmitReview => _executionStatus != null;

  Widget _buildWeekSummary(Week7ViewModel vm) {
    final problem = vm.problemDefinition;
    final plan = vm.actionPlan;
    final solutions = vm.solutions;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'برنامه حل مسئله شما',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          if (problem != null) ...[
            _buildInfoRow(
              'مشکل تعریف\u200cشده',
              problem['problem_description'] ?? '',
            ),
            _buildInfoRow('نتیجه موردنظر', problem['desired_outcome'] ?? ''),
          ],
          if (plan != null) ...[
            _buildInfoRow('راه انتخابی', plan['selected_solution'] ?? ''),
            _buildInfoRow('قدم اول', plan['first_action_step'] ?? ''),
            _buildInfoRow('زمان اجرا', plan['action_time'] ?? ''),
            if (plan['anticipated_barrier'] != null)
              _buildInfoRow('مانع احتمالی', plan['anticipated_barrier'] ?? ''),
          ],
          if (problem == null && plan == null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Text(
                'هنوز برنامه\u200cای ثبت نشده است. می\u200cتوانید امروز یک مسئله کوچک را به\u200cصورت خلاصه مرور کنید.',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.info,
                  height: 1.6,
                ),
              ),
            ),
          SizedBox(height: AppSizes.lg),
          _buildStatCard(
            icon: Icons.check_circle_outline,
            iconColor: AppColors.success,
            label: 'روزهای تکمیل\u200cشده',
            value: '${vm.completedDaysCount} از ۷',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.lightbulb_outline,
            iconColor: AppColors.warning,
            label: 'راه\u200cحل\u200cهای ثبت\u200cشده',
            value: '${solutions.length}',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.assignment,
            iconColor: AppColors.info,
            label: 'برنامه اقدام ثبت\u200cشده',
            value: plan != null ? 'بله' : 'خیر',
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _goToPage(1),
              child: const Text('نتیجه را بررسی کنم'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSizes.sm),
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionReview() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرور اجرای قدم',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'آیا قدم انتخابی را اجرا کردید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._executionOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _executionStatus,
              (v) => setState(() => _executionStatus = v),
            ),
          ),
          if (_executionStatus != null &&
              _executionStatus != 'انجام نشد.' &&
              _executionStatus != 'هنوز زمان اجرای آن نرسیده است.') ...[
            SizedBox(height: AppSizes.lg),
            Text(
              'نتیجه تا چه اندازه به هدف موردنظر نزدیک بود؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.divider,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.1),
                trackHeight: 6,
              ),
              child: Slider(
                value: _goalProgress,
                min: 0,
                max: 10,
                divisions: 10,
                label: _goalProgress.toInt().toString(),
                onChanged: (v) => setState(() => _goalProgress = v),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '۰',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _goalProgress.toInt().toString(),
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '۱۰',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              'چه چیزی کمک کرد؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            ..._helpfulOptions.map(
              (opt) => _buildRadioTile(
                opt,
                _helpfulFactor,
                (v) => setState(() => _helpfulFactor = v),
              ),
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              'چه چیزی هنوز نیاز به تغییر دارد؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              'متن اختیاری، حداکثر ۱۵۰ کاراکتر',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                color: AppColors.textHint,
              ),
            ),
            SizedBox(height: AppSizes.xs),
            TextField(
              controller: _remainingCtrl,
              maxLength: 150,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'موارد باقی\u200cمانده...',
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
          ],
          if (_executionStatus == 'انجام نشد.') ...[
            SizedBox(height: AppSizes.lg),
            Text(
              'مهم\u200cترین مانع چه بود؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            ..._barrierOptions.map(
              (opt) => _buildRadioTile(
                opt,
                _executionBarrier,
                (v) => setState(() => _executionBarrier = v),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitReview ? _submitReview : null,
              child: const Text('ثبت و ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  // D49-03 form state
  String? _nextStrategy;
  final _nextActionCtrl = TextEditingController();
  String? _nextActionTime;

  final _strategyOptions = [
    'همین راه\u200cحل را ادامه می\u200cدهم.',
    'قدم را کوچک\u200cتر می\u200cکنم.',
    'زمان اجرا را تغییر می\u200cدهم.',
    'اطلاعات بیشتری جمع می\u200cکنم.',
    'از فرد یا منبع مناسبی کمک می\u200cگیرم.',
    'راه\u200cحل دیگری را امتحان می\u200cکنم.',
    'فعلاً اقدامی لازم نیست.',
    'موضوع خارج از کنترل من است.',
    'نیاز به کمک تخصصی یا مسیر رسمی دارم.',
  ];

  final _nextTimeOptions = [
    'امروز',
    'فردا',
    'هفته آینده',
    'زمان دیگری',
    'فعلاً زمان مشخصی ندارم.',
  ];

  bool get _canSubmitNextStep => _nextStrategy != null;

  Widget _buildNextStepForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'قدم بعدی چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'حل مسئله معمولاً یک فرایند رفت\u200cو\u200cبرگشتی است. ممکن است لازم باشد راه\u200cحل ادامه پیدا کند، کوچک\u200cتر شود، تغییر کند یا اطلاعات بیشتری جمع\u200cآوری شود.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'قدم بعدی مناسب\u200cتر کدام است؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._strategyOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _nextStrategy,
              (v) => setState(() => _nextStrategy = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'قدم بعدی را کوتاه بنویسید.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'حداکثر ۱۵۰ کاراکتر، اختیاری',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: _nextActionCtrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'قدم بعدی...',
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
          Text(
            'چه زمانی آن را انجام می\u200cدهید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._nextTimeOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _nextActionTime,
              (v) => setState(() => _nextActionTime = v),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitNextStep ? _submitNextStep : null,
              child: const Text('ثبت قدم بعدی'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildWeekEnd() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هفته هفتم به پایان رسید',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'در این هفته یاد گرفتید یک مشکل را دقیق تعریف کنید، چند راه ممکن ایجاد کنید، گزینه\u200cها را از نظر فایده و امکان اجرا بررسی کنید و یک قدم روشن برای اقدام تعیین کنید.\n\nهمچنین تمرین کردید نیاز یا درخواست خود را به\u200cصورت روشن، محترمانه و هماهنگ با شرایط بیان کنید.\n\nحل مسئله همیشه در اولین تلاش به نتیجه کامل نمی\u200cرسد. مرور نتیجه و اصلاح برنامه، بخشی طبیعی از فرایند است.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.8,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'یادآوری',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  'بعضی مسائل قابل حل\u200cاند، بعضی فقط تا حدی قابل تأثیرند و برخی نیازمند پذیرش محدودیت یا کمک تخصصی\u200cاند.',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    height: 1.7,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<Week7ViewModel>().completeDay(
                  weekNumber: 7,
                  dayNumber: 49,
                );
                Navigator.of(context).pop();
              },
              child: const Text('پایان هفته هفتم'),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _goToPage(0),
              child: Text(
                'مرور دوباره برنامه',
                style: PersianFonts.Vazir.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildRadioTile(
    String value,
    String? groupValue,
    ValueChanged<String?> onChanged,
  ) {
    final isSelected = groupValue == value;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSizes.xs),
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
              vertical: AppSizes.xs,
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

  void _submitReview() {
    context.read<Week7ViewModel>().submitExerciseResponse(
      weekNumber: 7,
      dayNumber: 49,
      exerciseType: 'action_review',
      data: {
        'action_execution_status': _executionStatus,
        'goal_progress_rating': _goalProgress.toInt(),
        'helpful_factor': _helpfulFactor,
        'remaining_issue': _remainingCtrl.text.trim().isNotEmpty
            ? _remainingCtrl.text.trim()
            : null,
        'execution_barrier': _executionBarrier,
      },
    );
    _goToPage(2);
  }

  void _submitNextStep() {
    context.read<Week7ViewModel>().submitExerciseResponse(
      weekNumber: 7,
      dayNumber: 49,
      exerciseType: 'next_step_plan',
      data: {
        'next_strategy': _nextStrategy,
        'next_action': _nextActionCtrl.text.trim().isNotEmpty
            ? _nextActionCtrl.text.trim()
            : null,
        'next_action_time': _nextActionTime,
      },
    );
    // Now go to evaluation (quiz page)
    _goToPage(3);
  }
}
