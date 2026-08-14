import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week2_view_model.dart';

class Day13Screen extends StatefulWidget {
  const Day13Screen({super.key});

  @override
  State<Day13Screen> createState() => _Day13ScreenState();
}

class _Day13ScreenState extends State<Day13Screen> {
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
                  dayNumber: 13,
                  dayTitle: 'تنفس در یک موقعیت واقعی',
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
                    // D13-01: Choose context
                    _D13ContextSelection(
                      onSubmit: (context_) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 13,
                          exerciseType: 'breathing_context',
                          data: {'context': context_},
                        );
                        _goToPage(1);
                      },
                    ),
                    // D13-02: Tension before
                    _D13TensionSlider(
                      title: 'تنش پیش از تمرین',
                      submitText: 'ثبت و شروع تمرین',
                      onSubmit: (value) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 13,
                          exerciseType: 'tension_before',
                          data: {'tension_before': value},
                        );
                        _goToPage(2);
                      },
                    ),
                    // D13-03: Short practice (reuses W2-AUD-03)
                    _D13Practice(
                      onSubmit: (status) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 13,
                          exerciseType: 'real_context_breathing',
                          data: {'status': status},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D13-04: Tension after + end
                    _D13TensionAfter(
                      onSubmit: (value) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 13,
                          exerciseType: 'tension_after',
                          data: {'tension_after': value},
                        );
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
                                Text(
                                  'ممکن است تنش کاهش پیدا کند، ثابت بماند یا موقتاً بیشتر احساس شود. هدف اصلی تمرین، افزایش توجه و ایجاد یک مکث کوتاه است؛ نه تضمین آرامش فوری.',
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
                                          .read<Week2ViewModel>()
                                          .completeDay(
                                            weekNumber: 2,
                                            dayNumber: 13,
                                          );
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('پایان روز سیزدهم'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
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

// D13-01: Context selection
class _D13ContextSelection extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  const _D13ContextSelection({required this.onSubmit});

  @override
  State<_D13ContextSelection> createState() => _D13ContextSelectionState();
}

class _D13ContextSelectionState extends State<_D13ContextSelection> {
  String? _selectedContext;

  final _options = [
    'پیش از شروع کار',
    'هنگام استراحت',
    'پس از پایان کار',
    'پس از یک گفت\u200cوگوی دشوار',
    'پیش از خواب',
    'زمان دیگری',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تمرین را کجا انجام می\u200cدهید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'یک موقعیت عادی و نسبتاً امن را انتخاب کنید. انجام تمرین در موقعیت بحرانی یا هنگام فعالیتی که به توجه کامل نیاز دارد مناسب نیست.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          ..._options.map((opt) {
            final isSelected = _selectedContext == opt;
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.sm),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: () => setState(() => _selectedContext = opt),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: opt,
                          groupValue: _selectedContext,
                          onChanged: (v) =>
                              setState(() => _selectedContext = v),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            opt,
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
          }),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedContext != null
                  ? () => widget.onSubmit(_selectedContext!)
                  : null,
              child: const Text('ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

// D13-02: Tension slider
class _D13TensionSlider extends StatefulWidget {
  final String title;
  final String submitText;
  final ValueChanged<int> onSubmit;
  const _D13TensionSlider({
    required this.title,
    required this.submitText,
    required this.onSubmit,
  });

  @override
  State<_D13TensionSlider> createState() => _D13TensionSliderState();
}

class _D13TensionSliderState extends State<_D13TensionSlider> {
  double _value = 5;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'تنش شما اکنون از صفر تا ده چقدر است؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'این نمره فقط برای مقایسه شخصی پیش و پس از تمرین است و تفسیر تشخیصی ندارد.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              height: 1.5,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              trackHeight: 6,
            ),
            child: Slider(
              value: _value,
              min: 0,
              max: 10,
              divisions: 10,
              label: _value.toInt().toString(),
              onChanged: (v) => setState(() => _value = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'بدون تنش',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _value.toInt().toString(),
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'بیشترین تنش اکنون',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSubmit(_value.toInt()),
              child: Text(widget.submitText),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

// D13-03: Practice (reuse W2-AUD-03)
class _D13Practice extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  const _D13Practice({required this.onSubmit});

  @override
  State<_D13Practice> createState() => _D13PracticeState();
}

class _D13PracticeState extends State<_D13Practice> {
  bool _isPlaying = false;
  String? _status;

  final _statusOptions = ['کامل', 'بخشی', 'انجام ندادم'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مشاهده تنفس در موقعیت روزمره',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'تمرین تنفس روز یازدهم را دوباره انجام دهید.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.xl),
          // Audio player controls
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      30,
                      (i) => Container(
                        width: 3,
                        height: 10 + (i % 5) * 8.0,
                        margin: EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(
                            alpha: _isPlaying ? 0.6 : 0.3,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isPlaying = true),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: const Icon(
                              Icons.replay,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'شروع مجدد',
                            style: PersianFonts.Vazir.copyWith(
                              fontSize: AppSizes.fontXs,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSizes.lg),
                    GestureDetector(
                      onTap: () => setState(() => _isPlaying = !_isPlaying),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppColors.textOnPrimary,
                          size: 32,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.lg),
                    GestureDetector(
                      onTap: () => setState(() => _isPlaying = false),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: const Icon(
                              Icons.stop,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'توقف',
                            style: PersianFonts.Vazir.copyWith(
                              fontSize: AppSizes.fontXs,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => widget.onSubmit('skipped'),
              child: Text(
                'عبور از تمرین',
                style: PersianFonts.Vazir.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'وضعیت تمرین:',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._statusOptions.map((option) {
            final isSelected = _status == option;
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.sm),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: () => setState(() => _status = option),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: option,
                          groupValue: _status,
                          onChanged: (v) => setState(() => _status = v),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            option,
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
          }),
          SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _status != null
                  ? () => widget.onSubmit(_status!)
                  : null,
              child: const Text('ثبت و ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

// D13-04: Tension after slider
class _D13TensionAfter extends StatefulWidget {
  final ValueChanged<int> onSubmit;
  const _D13TensionAfter({required this.onSubmit});

  @override
  State<_D13TensionAfter> createState() => _D13TensionAfterState();
}

class _D13TensionAfterState extends State<_D13TensionAfter> {
  double _value = 5;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تنش پس از تمرین',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'تنش شما اکنون از صفر تا ده چقدر است؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              trackHeight: 6,
            ),
            child: Slider(
              value: _value,
              min: 0,
              max: 10,
              divisions: 10,
              label: _value.toInt().toString(),
              onChanged: (v) => setState(() => _value = v),
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
                _value.toInt().toString(),
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXl,
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
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSubmit(_value.toInt()),
              child: const Text('ثبت و ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}
