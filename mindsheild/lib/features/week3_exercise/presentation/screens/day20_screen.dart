import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week3_view_model.dart';

class Day20Screen extends StatefulWidget {
  const Day20Screen({super.key});

  @override
  State<Day20Screen> createState() => _Day20ScreenState();
}

class _Day20ScreenState extends State<Day20Screen> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalSteps = 3;

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
                  dayNumber: 20,
                  dayTitle: 'ثبت فکر خودکار',
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
                    // D20-01: Guide
                    TextEducationPage(
                      title: 'یک فکر واقعی را ثبت کنید',
                      bodyText:
                          'یک موقعیت خفیف یا متوسط و غیرمحرمانه از امروز یا روزهای اخیر انتخاب کنید.\n\nتلاش کنید فکر را با همان کلماتی که در ذهن شما ظاهر شد بنویسید؛ کوتاه، مستقیم و بدون توضیح طولانی.',
                      cards: const [
                        InfoCard(
                          title: 'موقعیت',
                          text: 'پاسخ پیام کاری دیر ارسال شد.',
                        ),
                        InfoCard(
                          title: 'فکر',
                          text:
                              '«حتماً درخواست من را بی\u200cاهمیت می\u200cدانند.»',
                        ),
                      ],
                      noteText:
                          'امروز هنوز قرار نیست فکر را تغییر دهید یا شواهد آن را بررسی کنید.',
                      primaryButtonText: 'شروع ثبت',
                      onPrimaryButton: () => _goToPage(1),
                    ),
                    // D20-02: Thought record form
                    _buildThoughtRecordForm(),
                    // D20-03: Feedback + end
                    DayEndPage(
                      title: 'بازخورد',
                      missionText:
                          'شما یک فکر خودکار را شناسایی و ثبت کردید. هدف امروز تغییر آن نبود؛ فقط آن را واضح\u200cتر دیدید.\n\nدر هفته بعد یاد می\u200cگیرید چگونه شواهد مربوط به یک فکر را بررسی و تفسیر متعادل\u200cتری ایجاد کنید.',
                      notificationText:
                          'امروز یک فکر خودکار را کوتاه و مستقیم ثبت کنید.',
                      buttonText: 'پایان روز بیستم',
                      onButtonPressed: () {
                        context.read<Week3ViewModel>().completeDay(
                          weekNumber: 3,
                          dayNumber: 20,
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

  // Form state
  final _situationCtrl = TextEditingController();
  final _thoughtCtrl = TextEditingController();
  String? _emotion;
  double _emotionIntensity = 5;
  double _belief = 5;
  String? _thoughtPattern;

  final _emotions = [
    'اضطراب',
    'نگرانی',
    'خشم',
    'ناراحتی',
    'شرم',
    'ناامیدی',
    'ترس',
    'احساس گناه',
    'سردرگمی',
    'هیجان دیگر',
  ];

  final _patterns = [
    'همه یا هیچ',
    'برچسب\u200cزدن',
    'پیش\u200cبینی منفی',
    'فاجعه\u200cسازی',
    'ذهن\u200cخوانی',
    'باید ذهنی',
    'مطمئن نیستم',
    'هیچ\u200cکدام',
  ];

  bool get _canSubmit =>
      _situationCtrl.text.isNotEmpty &&
      _thoughtCtrl.text.isNotEmpty &&
      _emotion != null &&
      _thoughtPattern != null;

  Widget _buildThoughtRecordForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reminder banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            margin: EdgeInsets.only(bottom: AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'موقعیت را به\u200cصورت کلی ثبت کنید. از نوشتن نام افراد، محل خدمت، یگان، شماره پرسنلی یا اطلاعات سازمانی و مأموریتی خودداری کنید.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
          ),
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
          // Field 2: Thought
          _buildLabel('چه فکر یا تصویر ذهنی\u200cای ظاهر شد؟'),
          TextField(
            controller: _thoughtCtrl,
            maxLength: 200,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'فکر خود را با همان کلماتی که آمد بنویسید.',
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
          // Field 3: Emotion
          _buildLabel('هیجان اصلی چه بود؟'),
          DropdownButtonFormField<String>(
            value: _emotion,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
            ),
            items: _emotions.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: PersianFonts.Vazir.copyWith(fontSize: AppSizes.fontSm),
                ),
              );
            }).toList(),
            onChanged: (v) => setState(() => _emotion = v),
          ),
          SizedBox(height: AppSizes.md),
          // Field 4: Emotion intensity slider
          _buildLabel('شدت هیجان از صفر تا ده چقدر بود؟'),
          _buildSlider(
            value: _emotionIntensity,
            onChanged: (v) => setState(() => _emotionIntensity = v),
          ),
          SizedBox(height: AppSizes.md),
          // Field 5: Belief slider
          _buildLabel('چقدر این فکر را باور داشتید؟'),
          _buildSlider(
            value: _belief,
            onChanged: (v) => setState(() => _belief = v),
          ),
          SizedBox(height: AppSizes.md),
          // Field 6: Thought pattern
          _buildLabel('این فکر بیشتر به کدام الگو شباهت دارد؟'),
          ..._patterns.map(
            (p) => _buildRadioOption(
              p,
              _thoughtPattern,
              (v) => setState(() => _thoughtPattern = v),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submitForm : null,
              child: const Text('ثبت فکر'),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _goToPage(2),
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

  void _submitForm() {
    context.read<Week3ViewModel>().submitExerciseResponse(
      weekNumber: 3,
      dayNumber: 20,
      exerciseType: 'daily_stress',
      data: {'stress_score': _emotionIntensity.toInt()},
    );

    context.read<Week3ViewModel>().submitExerciseResponse(
      weekNumber: 3,
      dayNumber: 20,
      exerciseType: 'thought_record',
      data: {
        'situation': _situationCtrl.text,
        'thought': _thoughtCtrl.text,
        'emotion': _emotion,
        'emotion_intensity': _emotionIntensity.toInt(),
        'belief': _belief.toInt(),
        'pattern': _thoughtPattern,
      },
    );

    _goToPage(2);
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
