import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week4_view_model.dart';

class Day27Screen extends StatefulWidget {
  const Day27Screen({super.key});

  @override
  State<Day27Screen> createState() => _Day27ScreenState();
}

class _Day27ScreenState extends State<Day27Screen> {
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
                  dayNumber: 27,
                  dayTitle: 'بازسازی یک فکر واقعی',
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
                    // D27-01: Guide for selecting situation
                    _buildGuidePage(),
                    // D27-02: Thought and evidence form
                    _buildThoughtEvidenceForm(),
                    // D27-03: Balanced thought + re-evaluation
                    _buildBalancedReEvaluation(),
                    // D27-04: Day end
                    DayEndPage(
                      title: 'پایان روز بیست\u200cوهفتم',
                      missionText:
                          'شما فرایند کامل بررسی فکر را انجام دادید: فکر اولیه، شواهد، اطلاعات تکمیلی و فکر متعادل.\n\nمأموریت: در صورت بازگشت فکر اولیه، جمله متعادل خود را مرور کنید؛ بدون اینکه خود را مجبور کنید فوراً آن را کاملاً باور کنید.',
                      notificationText:
                          'امروز یک فکر واقعی را با استفاده از شواهد بررسی کنید.',
                      buttonText: 'پایان روز بیست\u200cوهفتم',
                      onButtonPressed: () {
                        context.read<Week4ViewModel>().completeDay(
                          weekNumber: 4,
                          dayNumber: 27,
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

  // D27-02 form state
  final _situationCtrl = TextEditingController();
  final _thoughtCtrl = TextEditingController();
  double _emotionInitial = 5;
  double _beliefInitial = 5;
  final _evidenceForCtrl = TextEditingController();
  final _evidenceAgainstCtrl = TextEditingController();

  // D27-03 form state
  final _alternativeViewCtrl = TextEditingController();
  final _balancedThoughtCtrl = TextEditingController();
  double _beliefAfter = 5;
  double _emotionAfter = 5;

  // --- D27-01: Guide page ---
  Widget _buildGuidePage() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'یک فکر واقعی را بررسی کنید',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'یک موقعیت خفیف یا متوسط از امروز یا روزهای اخیر انتخاب کنید. بهتر است این فکر با فکر بررسی\u200cشده در روزهای قبل متفاوت باشد تا مهارت را دوباره تمرین کنید.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Safety and privacy box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اطلاعات سازمانی یا هویتی ثبت نکنید. اگر تمرین باعث ناراحتی قابل توجه شد، می\u200cتوانید آن را متوقف کنید.',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    height: 1.7,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _goToPage(1),
              child: const Text('شروع تمرین'),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                context.read<Week4ViewModel>().completeDay(
                  weekNumber: 4,
                  dayNumber: 27,
                );
                Navigator.of(context).pop();
              },
              child: Text(
                'امروز انجام نمی\u200cدهم',
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

  // --- D27-02: Thought and evidence form ---
  bool get _canSubmitPart1 =>
      _situationCtrl.text.isNotEmpty &&
      _thoughtCtrl.text.isNotEmpty &&
      _evidenceForCtrl.text.isNotEmpty &&
      _evidenceAgainstCtrl.text.isNotEmpty;

  Widget _buildThoughtEvidenceForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'فکر و شواهد',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Field 1: Situation
          _buildLabel('موقعیت چه بود؟'),
          TextField(
            controller: _situationCtrl,
            maxLength: 200,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'فقط اتفاق قابل مشاهده را بنویسید.',
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
          SizedBox(height: AppSizes.md),
          // Field 2: Automatic thought
          _buildLabel('فکر خودکار چه بود؟'),
          TextField(
            controller: _thoughtCtrl,
            maxLength: 200,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'فکر را کوتاه و با همان کلمات ذهن خود بنویسید.',
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
          SizedBox(height: AppSizes.md),
          // Field 3: Emotion intensity slider
          _buildLabel('شدت هیجان چقدر بود؟'),
          _buildSlider(
            value: _emotionInitial,
            onChanged: (v) => setState(() => _emotionInitial = v),
          ),
          SizedBox(height: AppSizes.md),
          // Field 4: Belief slider
          _buildLabel('چقدر فکر را باور داشتید؟'),
          _buildSlider(
            value: _beliefInitial,
            leftLabel: 'اصلاً باور نداشتم',
            rightLabel: 'کاملاً باور داشتم',
            onChanged: (v) => setState(() => _beliefInitial = v),
          ),
          SizedBox(height: AppSizes.md),
          // Field 5: Supporting evidence
          _buildLabel('یک شاهد موافق چیست؟'),
          TextField(
            controller: _evidenceForCtrl,
            maxLength: 200,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'یک اطلاعات قابل مشاهده که از فکر حمایت می\u200cکند...',
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
          SizedBox(height: AppSizes.md),
          // Field 6: Counter evidence
          _buildLabel('یک شاهد مخالف یا اطلاعات تکمیلی چیست؟'),
          TextField(
            controller: _evidenceAgainstCtrl,
            maxLength: 200,
            maxLines: 2,
            decoration: InputDecoration(
              hintText:
                  'یک اطلاعات که نشان می\u200cدهد فکر ممکن است تمام واقعیت نباشد...',
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
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitPart1 ? () => _goToPage(2) : null,
              child: const Text('ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  // --- D27-03: Balanced thought + re-evaluation ---
  bool get _canSubmitPart2 => _balancedThoughtCtrl.text.isNotEmpty;

  Widget _buildBalancedReEvaluation() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'فکر متعادل و ارزیابی مجدد',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Summary of what was entered
          Container(
            width: double.infinity,
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
                  'خلاصه تمرین',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                _buildSummaryRow('فکر اولیه', '«${_thoughtCtrl.text}»'),
                SizedBox(height: AppSizes.xs),
                _buildSummaryRow('شاهد موافق', _evidenceForCtrl.text),
                SizedBox(height: AppSizes.xs),
                _buildSummaryRow(
                  'شاهد مخالف یا تکمیلی',
                  _evidenceAgainstCtrl.text,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Field: Alternative explanation (optional)
          _buildLabel('چه توضیح دیگری ممکن است وجود داشته باشد؟ (اختیاری)'),
          TextField(
            controller: _alternativeViewCtrl,
            maxLength: 200,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'توضیح جایگزین...',
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
          SizedBox(height: AppSizes.md),
          // Field: Balanced thought
          _buildLabel('فکر متعادل\u200cتر شما چیست؟'),
          TextField(
            controller: _balancedThoughtCtrl,
            maxLength: 250,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'فکر متعادل خود را بنویسید...',
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
          SizedBox(height: AppSizes.md),
          // Slider: Current belief in original thought
          _buildLabel('اکنون چقدر فکر اولیه را باور دارید؟'),
          _buildSlider(
            value: _beliefAfter,
            onChanged: (v) => setState(() => _beliefAfter = v),
          ),
          SizedBox(height: AppSizes.md),
          // Slider: Current emotion intensity
          _buildLabel('شدت هیجان اکنون چقدر است؟'),
          _buildSlider(
            value: _emotionAfter,
            onChanged: (v) => setState(() => _emotionAfter = v),
          ),
          SizedBox(height: AppSizes.sm),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Text(
              'کاهش\u200cنیافتن نمره به معنای ناموفق\u200cبودن تمرین نیست. ممکن است برای بررسی یک فکر، زمان یا تکرار بیشتری لازم باشد.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitPart2 ? _submitExercise : null,
              child: const Text('ثبت تمرین'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _submitExercise() {
    context.read<Week4ViewModel>().submitExerciseResponse(
      weekNumber: 4,
      dayNumber: 27,
      exerciseType: 'complete_restructuring_record',
      data: {
        'new_situation': _situationCtrl.text,
        'new_automatic_thought': _thoughtCtrl.text,
        'emotion_initial': _emotionInitial.toInt(),
        'belief_initial': _beliefInitial.toInt(),
        'evidence_for': _evidenceForCtrl.text,
        'evidence_against': _evidenceAgainstCtrl.text,
        'alternative_view': _alternativeViewCtrl.text,
        'new_balanced_thought': _balancedThoughtCtrl.text,
        'belief_after': _beliefAfter.toInt(),
        'emotion_after': _emotionAfter.toInt(),
      },
    );
    _goToPage(3);
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(top: 8, left: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textPrimary,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _buildSlider({
    required double value,
    required ValueChanged<double> onChanged,
    String leftLabel = '۰',
    String rightLabel = '۱۰',
  }) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            label: value.toInt().toString(),
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftLabel,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value.toInt().toString(),
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              rightLabel,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
