import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week8_view_model.dart';

class Day53Screen extends StatefulWidget {
  const Day53Screen({super.key});

  @override
  State<Day53Screen> createState() => _Day53ScreenState();
}

class _Day53ScreenState extends State<Day53Screen> {
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
                  dayNumber: 53,
                  dayTitle: 'برنامه\u200cای که امکان ادامه دارد',
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
                    // D53-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week8ViewModel>().submitExerciseResponse(
                          weekNumber: 8,
                          dayNumber: 53,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D53-02: Sustainable plan
                    TextEducationPage(
                      title:
                          'برنامه کوتاه و قابل اجرا بهتر از برنامه کامل و دشوار است',
                      bodyText:
                          'پس از پایان دوره لازم نیست هر روز تمام مهارت\u200cها را انجام دهید. برنامه ادامه باید ساده، مشخص و هماهنگ با شرایط واقعی زندگی شما باشد.',
                      cards: const [
                        InfoCard(
                          title: 'تمرین منظم',
                          text:
                              'مهارتی که در روزهای عادی نیز انجام می\u200cشود.',
                        ),
                        InfoCard(
                          title: 'اقدام هنگام علامت هشدار',
                          text:
                              'مهارتی که پس از مشاهده علائم شخصی استفاده می\u200cشود.',
                        ),
                        InfoCard(
                          title: 'مثال',
                          text:
                              'تمرین منظم: هفته\u200cای سه بار تنفس سه\u200cدقیقه\u200cای\nهنگام فکر تکراری: ثبت فکر یا بررسی شواهد\nهنگام مشکل مشخص: حل مسئله',
                        ),
                      ],
                      primaryButtonText: 'برنامه خود را تنظیم کنم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D53-03: Continuation plan form
                    _buildContinuationForm(),
                    // D53-04: Day end
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

  // D53-03 form state
  String? _regularPractice;
  String? _weeklyFrequency;
  String? _preferredTime;
  final _minVersionCtrl = TextEditingController();
  String? _barrier;
  String? _barrierSolution;

  final _practiceOptions = [
    'توقف کوتاه بدن',
    'اسکن بدن',
    'تنفس آگاهانه',
    'ثبت فکر',
    'بررسی شواهد',
    'فعالیت کوچک',
    'مشاهده افکار',
    'پذیرش هیجان',
    'مکث و انتخاب پاسخ',
    'حل مسئله',
    'تمرین دیگر',
  ];

  final _frequencyOptions = [
    'یک بار',
    'دو بار',
    'سه بار',
    'چهار بار یا بیشتر',
    'فقط هنگام نیاز',
    'هنوز مطمئن نیستم',
  ];

  final _timeOptions = [
    'آغاز روز',
    'زمان استراحت',
    'پس از پایان کار',
    'عصر',
    'پیش از خواب',
    'پس از مشاهده علامت هشدار',
    'زمان دیگر',
  ];

  final _barrierOptions = [
    'کمبود وقت',
    'خستگی',
    'فراموشی',
    'تغییر برنامه',
    'احساس بی\u200cنیازی پس از بهترشدن',
    'ناامیدی پس از یک روز دشوار',
    'نامشخص\u200cبودن زمان',
    'مانع دیگر',
    'مانع مشخصی پیش\u200cبینی نمی\u200cکنم',
  ];

  final _solutionOptions = [
    'کوتاه\u200cکردن تمرین',
    'تغییر زمان',
    'استفاده از یادآوری',
    'انتخاب مهارت ساده\u200cتر',
    'شروع دوباره در روز بعد',
    'درخواست حمایت',
    'راه دیگر',
  ];

  bool get _canSubmitPlan =>
      _regularPractice != null &&
      _weeklyFrequency != null &&
      _preferredTime != null &&
      _barrier != null &&
      _barrierSolution != null;

  Widget _buildContinuationForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'برنامه ادامه',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Q1
          Text(
            'کدام تمرین را می\u200cخواهید به\u200cصورت منظم ادامه دهید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._practiceOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _regularPractice,
              (v) => setState(() => _regularPractice = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2
          Text(
            'چند بار در هفته؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._frequencyOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _weeklyFrequency,
              (v) => setState(() => _weeklyFrequency = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3
          Text(
            'چه زمانی انجام آن آسان\u200cتر است؟',
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
              _preferredTime,
              (v) => setState(() => _preferredTime = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4
          Text(
            'کوتاه\u200cترین نسخه قابل انجام این تمرین چیست؟',
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
            controller: _minVersionCtrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText:
                  'مثال: اگر وقت نداشتم، فقط یک دقیقه توجه به تنفس انجام می\u200cدهم.',
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
          // Q5
          Text(
            'مهم\u200cترین مانع ادامه تمرین چیست؟',
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
              _barrier,
              (v) => setState(() => _barrier = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q6
          Text(
            'برای این مانع چه کاری انجام می\u200cدهید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._solutionOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _barrierSolution,
              (v) => setState(() => _barrierSolution = v),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitPlan ? _submitPlan : null,
              child: const Text('ثبت برنامه ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildDayEnd() {
    final vm = context.read<Week8ViewModel>();
    final plan = vm.maintenancePlan;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'پایان روز پنجاه\u200cوسوم',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          if (plan != null) ...[
            _buildPlanCard(plan),
            SizedBox(height: AppSizes.md),
          ],
          if (plan != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Text(
                'برنامه ادامه قابل تغییر است. اگر شرایط زندگی تغییر کرد، می\u200cتوانید زمان یا اندازه تمرین را تنظیم کنید.',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<Week8ViewModel>().completeDay(
                  weekNumber: 8,
                  dayNumber: 53,
                );
                Navigator.of(context).pop();
              },
              child: const Text('پایان روز پنجاه\u200cوسوم'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
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
            'کارت برنامه',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          _buildInfoLine(
            'تمرین منظم',
            plan['regular_practice']?.toString() ?? 'هنوز مشخص نشده',
          ),
          _buildInfoLine(
            'تعداد',
            plan['weekly_frequency']?.toString() ?? 'هنوز مشخص نشده',
          ),
          _buildInfoLine(
            'زمان',
            plan['preferred_practice_time']?.toString() ?? 'هنوز مشخص نشده',
          ),
          _buildInfoLine(
            'نسخه کوتاه',
            plan['minimum_practice_version']?.toString() ?? 'هنوز مشخص نشده',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
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

  void _submitPlan() {
    context.read<Week8ViewModel>().submitExerciseResponse(
      weekNumber: 8,
      dayNumber: 53,
      exerciseType: 'maintenance_plan',
      data: {
        'regular_practice': _regularPractice,
        'weekly_frequency': _weeklyFrequency,
        'preferred_practice_time': _preferredTime,
        'minimum_practice_version': _minVersionCtrl.text.trim().isNotEmpty
            ? _minVersionCtrl.text.trim()
            : null,
        'maintenance_barrier': _barrier,
        'maintenance_solution': _barrierSolution,
      },
    );
    _goToPage(3);
  }
}
