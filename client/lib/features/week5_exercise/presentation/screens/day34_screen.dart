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
import '../view_models/week5_view_model.dart';

class Day34Screen extends StatefulWidget {
  const Day34Screen({super.key});

  @override
  State<Day34Screen> createState() => _Day34ScreenState();
}

class _Day34ScreenState extends State<Day34Screen> {
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
                  dayNumber: 34,
                  dayTitle: 'وقتی فعالیت انجام نمی\u200cشود',
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
                    // D34-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week5ViewModel>().submitExerciseResponse(
                          weekNumber: 5,
                          dayNumber: 34,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D34-02: Barrier, not failure education
                    TextEducationPage(
                      title: 'انجام\u200cنشدن فعالیت چه اطلاعاتی می\u200cدهد؟',
                      bodyText:
                          'وقتی فعالیت برنامه\u200cریزی\u200cشده انجام نمی\u200cشود، واکنش رایج ممکن است سرزنش خود یا کنارگذاشتن برنامه باشد.\n\nدر فعال\u200cسازی رفتاری، انجام\u200cنشدن فعالیت به\u200cعنوان اطلاعات بررسی می\u200cشود: آیا فعالیت بزرگ بود؟ زمان مناسب نبود؟ انرژی کم بود؟ محیط تغییر کرد؟ یا قدم اول واضح نبود؟',
                      cards: const [
                        InfoCard(
                          title: 'مثال',
                          text:
                              'برنامه اولیه: سی دقیقه ورزش\nمانع: انرژی و زمان کافی وجود نداشت.\nقدم کوچک\u200cتر: سه دقیقه حرکت کششی سبک',
                        ),
                        InfoCard(
                          title: 'مثال دوم',
                          text:
                              'برنامه اولیه: مرتب\u200cکردن تمام اتاق\nقدم کوچک\u200cتر: مرتب\u200cکردن فقط یک سطح کوچک',
                        ),
                      ],
                      noteText:
                          'کوچک\u200cکردن فعالیت به معنای تسلیم\u200cشدن نیست؛ روشی برای افزایش احتمال شروع است.',
                      primaryButtonText: 'مانع خود را بررسی کنم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D34-03: Barrier & small step form
                    _buildBarrierForm(),
                    // D34-04: Day end
                    DayEndPage(
                      title: 'پایان روز سی\u200cوچهارم',
                      feedbackText:
                          'برنامه مؤثر، برنامه\u200cای نیست که روی کاغذ کامل باشد؛ برنامه\u200cای است که در شرایط واقعی امکان شروع آن وجود داشته باشد.',
                      missionText:
                          'فقط قدم کوچک تعیین\u200cشده را امتحان کنید. ادامه\u200cدادن پس از آن اختیاری است.',
                      notificationText:
                          'اگر فعالیت دشوار است، امروز فقط قدم اول آن را کوچک\u200cتر کنید.',
                      buttonText: 'پایان روز سی\u200cوچهارم',
                      onButtonPressed: () {
                        context.read<Week5ViewModel>().completeDay(
                          weekNumber: 5,
                          dayNumber: 34,
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

  // D34-03 form state
  String? _barrier;
  String? _solution;
  final _smallStepCtrl = TextEditingController();
  String? _stepTime;

  final _barrierOptions = [
    'وقت کافی نداشتم.',
    'انرژی کم بود.',
    'فراموش کردم.',
    'فعالیت بیش از حد بزرگ بود.',
    'زمان مناسبی انتخاب نکرده بودم.',
    'محیط یا برنامه تغییر کرد.',
    'نمی\u200cدانستم از کجا شروع کنم.',
    'از نتیجه نگران بودم.',
    'مانع دیگر',
    'فعالیت انجام شد و مانع مهمی نبود.',
  ];

  final _solutionOptions = [
    'کوتاه\u200cکردن مدت',
    'تغییر زمان',
    'تغییر مکان',
    'آماده\u200cکردن وسایل از قبل',
    'درخواست کمک یا همراهی',
    'انتخاب فعالیت ساده\u200cتر',
    'تقسیم کار به چند قدم',
    'تغییر دیگر',
  ];

  final _timeOptions = [
    'امروز',
    'فردا',
    'زمان دیگری',
    'فعلاً برنامه\u200cای ندارم.',
  ];

  bool get _canSubmitBarrier =>
      _barrier != null &&
      _solution != null &&
      _smallStepCtrl.text.isNotEmpty &&
      _stepTime != null;

  Widget _buildBarrierForm() {
    final vm = context.read<Week5ViewModel>();
    final plan = vm.plannedActivity;
    final lastActivity = plan?['planned_activity']?.toString();

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'فرم مانع و قدم کوچک',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q1: What was the activity?
          _buildLabel('فعالیتی که می\u200cخواستید انجام دهید چه بود؟'),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              lastActivity ?? 'فعالیت اخیر ثبت نشده است.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: lastActivity != null
                    ? AppColors.textPrimary
                    : AppColors.textHint,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2: Main barrier
          _buildLabel('مهم\u200cترین مانع چه بود؟'),
          ..._barrierOptions.map(
            (opt) => _buildRadioOption(
              opt,
              _barrier,
              (v) => setState(() => _barrier = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3: What change would help?
          _buildLabel('کدام تغییر انجام فعالیت را آسان\u200cتر می\u200cکند؟'),
          ..._solutionOptions.map(
            (opt) => _buildRadioOption(
              opt,
              _solution,
              (v) => setState(() => _solution = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4: Smallest step
          _buildLabel('کوچک\u200cترین قدمی که می\u200cتوانید انجام دهید چیست؟'),
          TextField(
            controller: _smallStepCtrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText:
                  'مثال: فقط فایل را باز می\u200cکنم، دو دقیقه قدم می\u200cزنم یا یک پیام کوتاه می\u200cفرستم.',
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
          // Q5: When?
          _buildLabel('چه زمانی این قدم را امتحان می\u200cکنید؟'),
          ..._timeOptions.map(
            (opt) => _buildRadioOption(
              opt,
              _stepTime,
              (v) => setState(() => _stepTime = v),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitBarrier ? _submitBarrier : null,
              child: const Text('ثبت قدم کوچک'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _submitBarrier() {
    context.read<Week5ViewModel>().submitExerciseResponse(
      weekNumber: 5,
      dayNumber: 34,
      exerciseType: 'activity_barriers',
      data: {
        'activity_barrier': _barrier,
        'barrier_solution': _solution,
        'graded_task_step': _smallStepCtrl.text,
        'graded_task_time': _stepTime,
      },
    );
    _goToPage(3);
  }

  // --- Helpers ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.xs),
      child: Text(
        text,
        style: PersianFonts.Vazir.copyWith(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildRadioOption(
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
}
