import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week5_view_model.dart';

class Day32Screen extends StatefulWidget {
  const Day32Screen({super.key});

  @override
  State<Day32Screen> createState() => _Day32ScreenState();
}

class _Day32ScreenState extends State<Day32Screen> {
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
                  dayNumber: 32,
                  dayTitle: 'فعالیت برنامه\u200cریزی\u200cشده را امتحان کنیم',
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
                    // D32-01: Today's plan
                    _buildTodayPlan(),
                    // D32-02: Mood before activity
                    _buildMoodBefore(),
                    // D32-03: After activity registration
                    _buildAfterActivity(),
                    // D32-04: Day end
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

  // D32-01: Today's plan
  bool _didNotDoActivity = false;

  Widget _buildTodayPlan() {
    final vm = context.read<Week5ViewModel>();
    final plan = vm.plannedActivity;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'برنامه فعالیت شما',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          if (plan != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlanRow(
                    'فعالیت',
                    plan['planned_activity']?.toString() ?? '-',
                  ),
                  _buildPlanRow(
                    'زمان',
                    plan['planned_time']?.toString() ?? '-',
                  ),
                  _buildPlanRow(
                    'مدت',
                    plan['planned_duration']?.toString() ?? '-',
                  ),
                  _buildPlanRow(
                    'نسخه کوچک\u200cتر',
                    plan['minimum_activity_version']?.toString() ?? '-',
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'فعالیتی کوچک را برای امروز انتخاب کنید.',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      height: 1.7,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSizes.md),
                  _buildRadioOption(
                    'یک فعالیت لذت\u200cبخش',
                    _fallbackActivity,
                    (v) => setState(() => _fallbackActivity = v),
                  ),
                  _buildRadioOption(
                    'یک کار کوتاه عقب\u200cافتاده',
                    _fallbackActivity,
                    (v) => setState(() => _fallbackActivity = v),
                  ),
                  _buildRadioOption(
                    'ارتباط کوتاه با فرد حمایتگر',
                    _fallbackActivity,
                    (v) => setState(() => _fallbackActivity = v),
                  ),
                  _buildRadioOption(
                    'فعالیت بدنی سبک و متناسب',
                    _fallbackActivity,
                    (v) => setState(() => _fallbackActivity = v),
                  ),
                  _buildRadioOption(
                    'فعالیت دیگر',
                    _fallbackActivity,
                    (v) => setState(() => _fallbackActivity = v),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _goToPage(1),
              child: const Text('آماده\u200cام'),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                setState(() => _didNotDoActivity = true);
                _goToPage(3);
              },
              child: Text(
                'امروز انجام نمی\u200cدهم',
                style: PersianFonts.Vazir.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          if (_didNotDoActivity) ...[
            SizedBox(height: AppSizes.md),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Text(
                'انجام\u200cنشدن فعالیت مانع ادامه برنامه نیست. فردا می\u200cتوانید مانع را بررسی و فعالیت را کوچک\u200cتر کنید.',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  String? _fallbackActivity;

  // D32-02: Mood before activity
  double _moodBefore = 5;
  double _startDifficulty = 5;

  Widget _buildMoodBefore() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حال پیش از فعالیت',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'حال کلی شما پیش از فعالیت از صفر تا ده چقدر است؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          _buildSlider(
            value: _moodBefore,
            leftLabel: 'بسیار نامطلوب',
            rightLabel: 'بسیار مطلوب',
            onChanged: (v) => setState(() => _moodBefore = v),
          ),
          SizedBox(height: AppSizes.xl),
          Text(
            'شروع فعالیت اکنون چقدر دشوار به نظر می\u200cرسد؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          _buildSlider(
            value: _startDifficulty,
            leftLabel: 'اصلاً دشوار نیست',
            rightLabel: 'بسیار دشوار',
            onChanged: (v) => setState(() => _startDifficulty = v),
          ),
          SizedBox(height: AppSizes.xl),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              'اکنون از برنامه خارج شوید یا گوشی را کنار بگذارید و فعالیت را انجام دهید. پس از آن به این صفحه بازگردید.',
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
              onPressed: () => _goToPage(2),
              child: const Text('فعالیت را انجام می\u200cدهم'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  // D32-03: After activity
  String? _activityStatus;
  double _moodAfter = 5;
  double _pleasureRating = 5;
  double _accomplishmentRating = 5;
  String? _noncompletionBarrier;

  final _statusOptions = [
    'کامل انجام شد.',
    'بخشی انجام شد.',
    'فقط نسخه کوچک\u200cتر را انجام دادم.',
    'انجام ندادم.',
  ];

  final _barrierOptions = [
    'وقت کافی نداشتم.',
    'انرژی نداشتم.',
    'فراموش کردم.',
    'فعالیت دشوار بود.',
    'شرایط محیطی مناسب نبود.',
    'برنامه تغییر کرد.',
    'مانع دیگری وجود داشت.',
    'ترجیح می\u200cدهم پاسخ ندهم.',
  ];

  bool get _isActivityDone =>
      _activityStatus != null && _activityStatus != 'انجام ندادم.';

  bool get _canSubmitAfter =>
      _activityStatus != null &&
      (_isActivityDone || _noncompletionBarrier != null);

  Widget _buildAfterActivity() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ثبت پس از فعالیت',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q1: Activity status
          _buildLabel('آیا فعالیت را انجام دادید؟'),
          ..._statusOptions.map(
            (opt) => _buildRadioOption(
              opt,
              _activityStatus,
              (v) => setState(() => _activityStatus = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Conditional: if done
          if (_isActivityDone) ...[
            Text(
              'حال کلی شما پس از فعالیت از صفر تا ده چقدر است؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            _buildSlider(
              value: _moodAfter,
              leftLabel: 'بسیار نامطلوب',
              rightLabel: 'بسیار مطلوب',
              onChanged: (v) => setState(() => _moodAfter = v),
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              'فعالیت چقدر لذت\u200cبخش بود؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            _buildSlider(
              value: _pleasureRating,
              leftLabel: 'بدون لذت',
              rightLabel: 'بسیار لذت\u200cبخش',
              onChanged: (v) => setState(() => _pleasureRating = v),
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              'فعالیت چقدر احساس انجام\u200cدادن یا پیشرفت ایجاد کرد؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            _buildSlider(
              value: _accomplishmentRating,
              leftLabel: 'هیچ',
              rightLabel: 'بسیار زیاد',
              onChanged: (v) => setState(() => _accomplishmentRating = v),
            ),
          ],
          // Conditional: if not done
          if (_activityStatus == 'انجام ندادم.') ...[
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
              (opt) => _buildRadioOption(
                opt,
                _noncompletionBarrier,
                (v) => setState(() => _noncompletionBarrier = v),
              ),
            ),
          ],
          SizedBox(height: AppSizes.lg),
          // Fixed message
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              'لازم نیست فعالیت هم لذت زیاد و هم احساس پیشرفت زیاد ایجاد کند. بعضی فعالیت\u200cها فقط در یکی از این دو زمینه مؤثرند.',
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
              onPressed: _canSubmitAfter ? _submitAfter : null,
              child: const Text('ثبت تجربه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _submitAfter() {
    final data = <String, dynamic>{
      'activity_status': _activityStatus,
      'mood_before': _moodBefore.toInt(),
      'start_difficulty': _startDifficulty.toInt(),
    };

    if (_isActivityDone) {
      data['mood_after'] = _moodAfter.toInt();
      data['pleasure_rating'] = _pleasureRating.toInt();
      data['accomplishment_rating'] = _accomplishmentRating.toInt();
    } else {
      data['noncompletion_barrier'] = _noncompletionBarrier;
    }

    context.read<Week5ViewModel>().submitExerciseResponse(
      weekNumber: 5,
      dayNumber: 32,
      exerciseType: 'activity_completion',
      data: data,
    );
    _goToPage(3);
  }

  // D32-04: Day end
  Widget _buildDayEnd() {
    String feedbackText;
    if (_isActivityDone) {
      feedbackText =
          'شما یک فعالیت برنامه\u200cریزی\u200cشده را امتحان کردید. هدف، مشاهده تجربه واقعی بود؛ نه اثبات اینکه فعالیت حتماً حال را بهتر می\u200cکند.';
    } else if (_activityStatus == 'بخشی انجام شد.' ||
        _activityStatus == 'فقط نسخه کوچک\u200cتر را انجام دادم.') {
      feedbackText =
          'انجام بخشی از فعالیت نیز اطلاعات مفیدی درباره اندازه مناسب فعالیت فراهم می\u200cکند.';
    } else {
      feedbackText =
          'انجام\u200cنشدن فعالیت فرصتی برای شناسایی مانع است. فردا قدم را کوچک\u200cتر یا برنامه را واقع\u200cبینانه\u200cتر می\u200cکنید.';
    }

    return DayEndPage(
      title: 'پایان روز سی\u200cودوم',
      feedbackText: feedbackText,
      missionText: '',
      notificationText:
          'فعالیت کوچک برنامه\u200cریزی\u200cشده امروز را امتحان کنید.',
      buttonText: 'پایان روز سی\u200cودوم',
      onButtonPressed: () {
        context.read<Week5ViewModel>().completeDay(
          weekNumber: 5,
          dayNumber: 32,
        );
        Navigator.of(context).pop();
      },
    );
  }

  // --- Helpers ---

  Widget _buildPlanRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
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
