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

class Day31Screen extends StatefulWidget {
  const Day31Screen({super.key});

  @override
  State<Day31Screen> createState() => _Day31ScreenState();
}

class _Day31ScreenState extends State<Day31Screen> {
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
                  dayNumber: 31,
                  dayTitle: 'از تصمیم کلی تا برنامه روشن',
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
                    // D31-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week5ViewModel>().submitExerciseResponse(
                          weekNumber: 5,
                          dayNumber: 31,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D31-02: What is a clear plan?
                    TextEducationPage(
                      title: '«بعداً انجام می\u200cدهم» برنامه نیست',
                      bodyText:
                          'وقتی زمان، مکان یا اندازه یک فعالیت مبهم باشد، احتمال به\u200cتعویق\u200cافتادن آن بیشتر می\u200cشود.\n\nیک برنامه روشن مشخص می\u200cکند چه کاری، در چه زمانی و با چه اندازه\u200cای انجام خواهد شد.',
                      cards: const [
                        InfoCard(
                          title: 'مثال مبهم',
                          text: 'باید بیشتر پیاده\u200cروی کنم.',
                        ),
                        InfoCard(
                          title: 'مثال روشن\u200cتر',
                          text:
                              'فردا پس از پایان کار، پنج دقیقه در محل امن قدم می\u200cزنم.',
                        ),
                        InfoCard(
                          title: 'مثال دوم — مبهم',
                          text: 'باید با خانواده بیشتر صحبت کنم.',
                        ),
                        InfoCard(
                          title: 'مثال دوم — روشن\u200cتر',
                          text:
                              'امشب یک تماس پنج\u200cدقیقه\u200cای برقرار می\u200cکنم.',
                        ),
                      ],
                      noteText:
                          'اگر برنامه کوچک به نظر می\u200cرسد، اشکالی ندارد. هدف شروع\u200cکردن است، نه انجام کامل و بی\u200cنقص.',
                      primaryButtonText: 'برنامه خود را تنظیم کنم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D31-03: Activity planning form
                    _buildPlanningForm(),
                    // D31-04: Day end with plan card
                    _buildDayEndWithPlan(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // D31-03 form state
  String? _selectedActivity;
  String? _plannedTime;
  final _customTimeCtrl = TextEditingController();
  String? _plannedDuration;
  String? _plannedLocation;
  final _minVersionCtrl = TextEditingController();
  double _confidence = 5;
  bool _showLowConfidenceMsg = false;

  final _timeOptions = [
    'امروز',
    'فردا',
    'پس از پایان کار',
    'هنگام استراحت',
    'پیش از خواب',
    'زمان دیگر',
  ];

  final _durationOptions = [
    '۲ دقیقه',
    '۵ دقیقه',
    '۱۰ دقیقه',
    '۱۵ دقیقه',
    'بیشتر',
  ];

  final _locationOptions = [
    'خانه',
    'محل کار، در زمان و مکان مجاز',
    'فضای باز امن',
    'محل دیگر',
    'نیاز به تعیین مکان ندارد',
  ];

  bool get _canSubmitPlan =>
      _selectedActivity != null &&
      _plannedTime != null &&
      (_plannedTime != 'زمان دیگر' || _customTimeCtrl.text.isNotEmpty) &&
      _plannedDuration != null &&
      _plannedLocation != null;

  Widget _buildPlanningForm() {
    final vm = context.read<Week5ViewModel>();
    final activities = vm.selectedActivities;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تنظیم برنامه فعالیت',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q1: Which activity?
          _buildLabel('کدام فعالیت را انجام می\u200cدهید؟'),
          if (activities.isNotEmpty) ...[
            ...activities.map(
              (act) => _buildRadioOption(
                act,
                _selectedActivity,
                (v) => setState(() => _selectedActivity = v),
              ),
            ),
          ] else ...[
            TextField(
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'فعالیت مورد نظر را بنویسید...',
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
              onChanged: (v) =>
                  setState(() => _selectedActivity = v.isNotEmpty ? v : null),
            ),
          ],
          SizedBox(height: AppSizes.md),
          // Q2: When?
          _buildLabel('چه زمانی انجام می\u200cدهید؟'),
          ..._timeOptions.map(
            (opt) => _buildRadioOption(
              opt,
              _plannedTime,
              (v) => setState(() => _plannedTime = v),
            ),
          ),
          if (_plannedTime == 'زمان دیگر') ...[
            SizedBox(height: AppSizes.xs),
            TextField(
              controller: _customTimeCtrl,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'زمان مورد نظر...',
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
          SizedBox(height: AppSizes.md),
          // Q3: Duration
          _buildLabel('مدت فعالیت چقدر است؟'),
          ..._durationOptions.map(
            (opt) => _buildRadioOption(
              opt,
              _plannedDuration,
              (v) => setState(() => _plannedDuration = v),
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Q4: Location
          _buildLabel('فعالیت را کجا انجام می\u200cدهید؟'),
          ..._locationOptions.map(
            (opt) => _buildRadioOption(
              opt,
              _plannedLocation,
              (v) => setState(() => _plannedLocation = v),
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Q5: Minimum version
          _buildLabel(
            'اگر انجام کامل آن ممکن نبود، کوچک\u200cترین نسخه فعالیت چیست؟',
          ),
          TextField(
            controller: _minVersionCtrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText:
                  'مثال: اگر ده دقیقه ممکن نبود، فقط دو دقیقه شروع می\u200cکنم.',
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
          // Q6: Confidence slider
          _buildLabel('از صفر تا ده، احتمال انجام این برنامه چقدر است؟'),
          _buildSlider(
            value: _confidence,
            onChanged: (v) {
              setState(() {
                _confidence = v;
                _showLowConfidenceMsg = v <= 4;
              });
            },
          ),
          if (_showLowConfidenceMsg) ...[
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
              child: Text(
                'ممکن است برنامه هنوز دشوار یا مبهم باشد. آیا می\u200cخواهید مدت آن را کوتاه\u200cتر یا زمان آن را تغییر دهید؟',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitPlan ? _submitPlan : null,
              child: const Text('ثبت برنامه فعالیت'),
            ),
          ),
          if (_showLowConfidenceMsg) ...[
            SizedBox(height: AppSizes.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _submitPlan(),
                child: Text(
                  'همین برنامه را ثبت می\u200cکنم',
                  style: PersianFonts.Vazir.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _submitPlan() {
    context.read<Week5ViewModel>().submitExerciseResponse(
      weekNumber: 5,
      dayNumber: 31,
      exerciseType: 'activity_schedule',
      data: {
        'planned_activity': _selectedActivity,
        'planned_time': _plannedTime == 'زمان دیگر'
            ? _customTimeCtrl.text
            : _plannedTime,
        'planned_duration': _plannedDuration,
        'planned_location': _plannedLocation,
        'minimum_activity_version': _minVersionCtrl.text,
        'completion_confidence': _confidence.toInt(),
      },
    );
    _goToPage(3);
  }

  // D31-04: Day end with plan card
  Widget _buildDayEndWithPlan() {
    final vm = context.read<Week5ViewModel>();
    final plan = vm.plannedActivity;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan card
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
                  Text(
                    'برنامه فعالیت شما',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppSizes.md),
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
            SizedBox(height: AppSizes.lg),
          ],
          Text(
            'برنامه شما باید با شرایط واقعی زندگی هماهنگ باشد. کوچک\u200cبودن برنامه به معنای کم\u200cارزش\u200cبودن آن نیست.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.8,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مأموریت امروز',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  'در زمان مشخص\u200cشده، فقط اولین قدم را آغاز کنید.',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    height: 1.8,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: AppColors.info,
                  size: 20,
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'امروز یک فعالیت کوچک را با زمان و مدت مشخص برنامه\u200cریزی کنید.',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.info,
                    ),
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
                context.read<Week5ViewModel>().completeDay(
                  weekNumber: 5,
                  dayNumber: 31,
                );
                Navigator.of(context).pop();
              },
              child: const Text('پایان روز سی\u200cویکم'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

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
              '۰',
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
              '۱۰',
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
