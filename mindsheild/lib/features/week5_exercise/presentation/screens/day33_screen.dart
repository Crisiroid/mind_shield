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

class Day33Screen extends StatefulWidget {
  const Day33Screen({super.key});

  @override
  State<Day33Screen> createState() => _Day33ScreenState();
}

class _Day33ScreenState extends State<Day33Screen> {
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
                  dayNumber: 33,
                  dayTitle: 'همه فعالیت\u200cها یک اثر ندارند',
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
                    // D33-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week5ViewModel>().submitExerciseResponse(
                          weekNumber: 5,
                          dayNumber: 33,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D33-02: Pleasure vs accomplishment education
                    TextEducationPage(
                      title: 'لذت و پیشرفت، دو تجربه متفاوت\u200cاند',
                      bodyText:
                          'برای بهبود الگوی فعالیت، بهتر است فقط منتظر فعالیت\u200cهای بسیار لذت\u200cبخش نباشیم. ترکیبی از فعالیت\u200cهای لذت\u200cبخش، پیش\u200cبرنده و ارتباطی می\u200cتواند مفید باشد.',
                      cards: const [
                        InfoCard(
                          title: 'لذت',
                          text:
                              'بعضی فعالیت\u200cها تجربه خوشایند، آرامش یا علاقه ایجاد می\u200cکنند؛ مانند موسیقی، گفت\u200cوگوی کوتاه یا حضور در فضای باز.',
                        ),
                        InfoCard(
                          title: 'احساس پیشرفت',
                          text:
                              'بعضی فعالیت\u200cها ممکن است بسیار لذت\u200cبخش نباشند، اما احساس انجام\u200cدادن، نظم یا حرکت رو به جلو ایجاد کنند؛ مانند مرتب\u200cکردن یک بخش یا تکمیل قدمی کوتاه.',
                        ),
                      ],
                      bottomText:
                          'مرتب\u200cکردن یک کشو ممکن است لذت کمی داشته باشد، اما احساس پیشرفت ایجاد کند.\n\nتماس با فردی نزدیک ممکن است لذت و ارتباط بیشتری ایجاد کند، اما احساس انجام وظیفه کمتری داشته باشد.',
                      primaryButtonText: 'فعالیت دوم را انتخاب کنم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D33-03: Second activity selection form
                    _buildSecondActivityForm(),
                    // D33-04: Day end
                    DayEndPage(
                      title: 'پایان روز سی\u200cوسوم',
                      feedbackText:
                          'فعالیت\u200cهای مختلف نیازهای متفاوتی را پاسخ می\u200cدهند. هدف، پیدا کردن ترکیبی متناسب با شرایط شماست.',
                      missionText:
                          'فعالیت دوم را در زمان انتخاب\u200cشده انجام دهید؛ حتی اگر فقط نسخه کوچک\u200cتر آن ممکن باشد.',
                      notificationText:
                          'امروز فعالیتی متناسب با نیاز خود انتخاب کنید: لذت، پیشرفت یا ارتباط.',
                      buttonText: 'پایان روز سی\u200cوسوم',
                      onButtonPressed: () {
                        context.read<Week5ViewModel>().completeDay(
                          weekNumber: 5,
                          dayNumber: 33,
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

  // D33-03 form state
  String? _neededActivityType;
  String? _secondActivity;
  String? _secondActivityTime;
  final _secondMinVersionCtrl = TextEditingController();
  double _secondConfidence = 5;

  final _activityTypeOptions = [
    'فعالیت لذت\u200cبخش',
    'فعالیتی برای احساس پیشرفت',
    'فعالیت ارتباطی',
    'فعالیت مرتبط با سلامت',
    'مطمئن نیستم',
  ];

  final _timeOptions = [
    'امروز',
    'فردا',
    'پس از پایان کار',
    'زمان استراحت',
    'پیش از خواب',
    'زمان دیگر',
  ];

  bool get _canSubmitSecondActivity =>
      _neededActivityType != null &&
      _secondActivity != null &&
      _secondActivityTime != null;

  Widget _buildSecondActivityForm() {
    final vm = context.read<Week5ViewModel>();
    final activities = vm.selectedActivities;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'انتخاب فعالیت دوم',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q1: What type do you need?
          _buildLabel('در حال حاضر بیشتر به کدام نوع فعالیت نیاز دارید؟'),
          ..._activityTypeOptions.map(
            (opt) => _buildRadioOption(
              opt,
              _neededActivityType,
              (v) => setState(() => _neededActivityType = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2: What activity?
          _buildLabel('فعالیت دوم شما چیست؟'),
          if (activities.isNotEmpty) ...[
            ...activities.map(
              (act) => _buildRadioOption(
                act,
                _secondActivity,
                (v) => setState(() => _secondActivity = v),
              ),
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              'یا فعالیت دیگری انتخاب کنید:',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                color: AppColors.textHint,
              ),
            ),
          ],
          TextField(
            maxLength: 100,
            decoration: InputDecoration(
              hintText: 'فعالیت مورد نظر...',
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
                setState(() => _secondActivity = v.isNotEmpty ? v : null),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3: When?
          _buildLabel('چه زمانی آن را انجام می\u200cدهید؟'),
          ..._timeOptions.map(
            (opt) => _buildRadioOption(
              opt,
              _secondActivityTime,
              (v) => setState(() => _secondActivityTime = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4: Minimum version
          _buildLabel('کوچک\u200cترین نسخه فعالیت چیست؟'),
          TextField(
            controller: _secondMinVersionCtrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'کوچک\u200cترین نسخه را بنویسید...',
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
          // Q5: Confidence
          _buildLabel('احتمال انجام این فعالیت از صفر تا ده چقدر است؟'),
          _buildSlider(
            value: _secondConfidence,
            onChanged: (v) => setState(() => _secondConfidence = v),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitSecondActivity
                  ? _submitSecondActivity
                  : null,
              child: const Text('ثبت فعالیت دوم'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _submitSecondActivity() {
    context.read<Week5ViewModel>().submitExerciseResponse(
      weekNumber: 5,
      dayNumber: 33,
      exerciseType: 'pleasure_accomplishment',
      data: {
        'needed_activity_type': _neededActivityType,
        'second_planned_activity': _secondActivity,
        'second_activity_time': _secondActivityTime,
        'second_minimum_version': _secondMinVersionCtrl.text,
        'second_completion_confidence': _secondConfidence.toInt(),
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
