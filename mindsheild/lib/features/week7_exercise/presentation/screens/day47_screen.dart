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

class Day47Screen extends StatefulWidget {
  const Day47Screen({super.key});

  @override
  State<Day47Screen> createState() => _Day47ScreenState();
}

class _Day47ScreenState extends State<Day47Screen> {
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
                  dayNumber: 47,
                  dayTitle: 'اولین قدم را مشخص کنیم',
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
                    // D47-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week7ViewModel>().submitExerciseResponse(
                          weekNumber: 7,
                          dayNumber: 47,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D47-02: Features of a clear plan
                    TextEducationPage(
                      title: 'تصمیم کلی را به قدم عملی تبدیل می\u200cکنیم',
                      bodyText:
                          'انتخاب یک راه\u200cحل زمانی مفید است که قدم اول آن روشن باشد. برنامه اقدام مشخص می\u200cکند چه کاری، چه زمانی، با استفاده از چه منابعی و با چه برنامه جایگزینی انجام می\u200cشود.',
                      cards: const [
                        InfoCard(
                          title: 'مثال کلی',
                          text: 'راه\u200cحل: اطلاعات بیشتری بگیرم.',
                        ),
                        InfoCard(
                          title: 'قدم روشن',
                          text:
                              'فردا پیش از ساعت مشخص، سه سؤال اصلی را بنویسم و از مسیر مناسب برای دریافت اطلاعات اقدام کنم.',
                        ),
                      ],
                      noteText: null,
                      primaryButtonText: 'برنامه خود را تنظیم کنم',
                      onPrimaryButton: () => _goToPage(2),
                      imageWidget: _buildFeaturesCard(),
                    ),
                    // D47-03: Action plan form
                    _buildActionPlanForm(),
                    // D47-04: Day end
                    _buildDayEnd(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ویژگی\u200cهای قدم اول',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          ...[
            'کوچک و روشن',
            'قابل مشاهده',
            'دارای زمان تقریبی',
            'هماهنگ با شرایط و مقررات',
            'قابل اصلاح در صورت ایجاد مانع',
          ].map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.xs),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppColors.success),
                  SizedBox(width: AppSizes.xs),
                  Text(
                    item,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // D47-03 form state
  String? _selectedSolution;
  final _firstStepCtrl = TextEditingController();
  String? _actionTime;
  String? _requiredResource;
  String? _anticipatedBarrier;
  final _backupPlanCtrl = TextEditingController();
  double _actionConfidence = 5;
  bool _showLowConfidenceMessage = false;

  final _solutionOptions = [
    'راه\u200cحل اول',
    'راه\u200cحل دوم',
    'راه\u200cحل سوم',
    'ترکیب چند راه',
    'راه\u200cحل جدید',
  ];

  final _timeOptions = [
    'امروز',
    'فردا',
    'هنگام آغاز کار',
    'هنگام استراحت',
    'پس از پایان کار',
    'زمان دیگر',
  ];

  final _resourceOptions = [
    'اطلاعات',
    'زمان',
    'کمک یا همراهی',
    'اجازه یا هماهنگی',
    'ابزار یا امکانات',
    'استراحت',
    'منبع دیگری',
    'منبع خاصی نیاز ندارم',
  ];

  final _barrierOptions = [
    'کمبود وقت',
    'خستگی',
    'فراموشی',
    'نگرانی از واکنش دیگران',
    'نامشخص\u200cبودن قدم',
    'دسترسی\u200cنداشتن به منبع',
    'تغییر برنامه',
    'مانع دیگر',
    'مانع مشخصی پیش\u200cبینی نمی\u200cکنم',
  ];

  bool get _canSubmitPlan =>
      _selectedSolution != null &&
      _firstStepCtrl.text.trim().isNotEmpty &&
      _actionTime != null &&
      _requiredResource != null &&
      _anticipatedBarrier != null;

  Widget _buildActionPlanForm() {
    final vm = context.read<Week7ViewModel>();
    final solutions = vm.solutions;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'برنامه اقدام',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Q1: Select solution
          Text(
            'کدام راه\u200cحل را انتخاب می\u200cکنید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          if (solutions.isNotEmpty) ...[
            SizedBox(height: AppSizes.xs),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(
                    solutions.length,
                    (i) => Text(
                      'راه\u200cحل ${i + 1}: ${solutions[i]}',
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontXs,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSizes.sm),
          ..._solutionOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _selectedSolution,
              (v) => setState(() => _selectedSolution = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2: First step
          Text(
            'اولین قدم دقیق چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'حداکثر ۱۵۰ کاراکتر',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: _firstStepCtrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'قدم اول...',
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
          // Q3: When
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
          ..._timeOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _actionTime,
              (v) => setState(() => _actionTime = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4: Resources
          Text(
            'چه منبع یا کمکی نیاز دارید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._resourceOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _requiredResource,
              (v) => setState(() => _requiredResource = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q5: Barrier
          Text(
            'مانع احتمالی چیست؟',
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
              _anticipatedBarrier,
              (v) => setState(() => _anticipatedBarrier = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q6: Backup plan
          Text(
            'اگر مانع ایجاد شد، برنامه جایگزین چیست؟',
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
            controller: _backupPlanCtrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'برنامه جایگزین...',
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
          // Q7: Confidence slider
          Text(
            'احتمال اجرای این قدم از صفر تا ده چقدر است؟',
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
              value: _actionConfidence,
              min: 0,
              max: 10,
              divisions: 10,
              label: _actionConfidence.toInt().toString(),
              onChanged: (v) {
                setState(() {
                  _actionConfidence = v;
                  _showLowConfidenceMessage = v <= 4;
                });
              },
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
                _actionConfidence.toInt().toString(),
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
          if (_showLowConfidenceMessage) ...[
            SizedBox(height: AppSizes.md),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ممکن است قدم هنوز بزرگ یا مبهم باشد. آیا می\u200cخواهید آن را کوچک\u200cتر کنید؟',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      height: 1.7,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // Go back to edit step
                          _firstStepCtrl.clear();
                          _goToPage(2);
                        },
                        child: Text(
                          'ویرایش قدم',
                          style: PersianFonts.Vazir.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.sm),
                      TextButton(
                        onPressed: () =>
                            setState(() => _showLowConfidenceMessage = false),
                        child: Text(
                          'همین برنامه را ثبت می\u200cکنم',
                          style: PersianFonts.Vazir.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitPlan ? _submitPlan : null,
              child: const Text('ثبت برنامه اقدام'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildDayEnd() {
    final vm = context.read<Week7ViewModel>();
    final plan = vm.actionPlan;
    return DayEndPage(
      title: 'پایان روز چهل\u200cوهفتم',
      feedbackText: plan != null
          ? 'راه انتخابی: ${plan['selected_solution']}\nقدم اول: ${plan['first_action_step']}\nزمان: ${plan['action_time']}\n\nلازم نیست تمام مسئله را یک\u200cباره حل کنید. فعلاً فقط قدم اول برنامه اهمیت دارد.'
          : 'لازم نیست تمام مسئله را یک\u200cباره حل کنید. فعلاً فقط قدم اول برنامه اهمیت دارد.',
      missionText:
          'قدم مشخص\u200cشده را در زمان انتخابی اجرا کنید یا حداقل مقدمات آن را فراهم کنید.',
      notificationText:
          'امروز راه\u200cحل انتخابی را به یک قدم روشن و زمان\u200cدار تبدیل کنید.',
      buttonText: 'پایان روز چهل\u200cوهفتم',
      onButtonPressed: () {
        vm.completeDay(weekNumber: 7, dayNumber: 47);
        Navigator.of(context).pop();
      },
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

  void _submitPlan() {
    context.read<Week7ViewModel>().submitExerciseResponse(
      weekNumber: 7,
      dayNumber: 47,
      exerciseType: 'action_plan',
      data: {
        'selected_solution': _selectedSolution,
        'first_action_step': _firstStepCtrl.text.trim(),
        'action_time': _actionTime,
        'required_resource': _requiredResource,
        'anticipated_barrier': _anticipatedBarrier,
        'backup_plan': _backupPlanCtrl.text.trim().isNotEmpty
            ? _backupPlanCtrl.text.trim()
            : null,
        'action_confidence': _actionConfidence.toInt(),
      },
    );
    _goToPage(3);
  }
}
