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
import '../view_models/week4_view_model.dart';

class Day22Screen extends StatefulWidget {
  const Day22Screen({super.key});

  @override
  State<Day22Screen> createState() => _Day22ScreenState();
}

class _Day22ScreenState extends State<Day22Screen> {
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
                  dayNumber: 22,
                  dayTitle: 'یک فکر را دقیق\u200cتر بررسی کنیم',
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
                    // D22-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week4ViewModel>().submitExerciseResponse(
                          weekNumber: 4,
                          dayNumber: 22,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D22-02: What is cognitive restructuring?
                    TextEducationPage(
                      title: 'یک فکر را دقیق\u200cتر بررسی می\u200cکنیم',
                      bodyText:
                          'در هفته گذشته یاد گرفتید افکار خودکار را شناسایی و ثبت کنید. این هفته بررسی می\u200cکنید که یک فکر تا چه اندازه تمام اطلاعات موقعیت را منعکس می\u200cکند.\n\nدر بازسازی شناختی، ابتدا فکر خودکار مشخص می\u200cشود. سپس شواهد موافق، شواهد مخالف و توضیح\u200cهای احتمالی دیگر بررسی می\u200cشوند. در پایان، فکر متعادل\u200cتری نوشته می\u200cشود.',
                      imageWidget: _buildW4Img01(),
                      cards: const [
                        InfoCard(
                          title: 'مهم',
                          text:
                              'هدف، متقاعدکردن خود به اینکه «همه\u200cچیز خوب است» نیست. ممکن است موقعیت واقعاً دشوار باشد؛ اما فکر اولیه فقط بخشی از واقعیت را نشان دهد.',
                        ),
                      ],
                      primaryButtonText: 'انتخاب فکر',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D22-03: Select thought form
                    _buildSelectThoughtForm(),
                    // D22-04: Day end
                    DayEndPage(
                      title: 'پایان روز بیست\u200cودوم',
                      missionText:
                          'فکر انتخاب\u200cشده ثبت شد. امروز لازم نیست آن را تغییر دهید. در روزهای بعد، اطلاعات مربوط به این فکر را مرحله\u200cبه\u200cمرحله بررسی خواهید کرد.\n\nمأموریت: فقط توجه کنید آیا ذهن شما این فکر را به\u200cعنوان یک واقعیت قطعی بیان می\u200cکند یا یک تفسیر احتمالی.',
                      notificationText:
                          'امروز یک فکر را برای بررسی دقیق\u200cتر انتخاب کنید.',
                      buttonText: 'پایان روز بیست\u200cودوم',
                      onButtonPressed: () {
                        context.read<Week4ViewModel>().completeDay(
                          weekNumber: 4,
                          dayNumber: 22,
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
  double _beliefInitial = 5;

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

  bool get _canSubmitThought =>
      _situationCtrl.text.isNotEmpty &&
      _thoughtCtrl.text.isNotEmpty &&
      _emotion != null;

  Widget _buildSelectThoughtForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'یک فکر قابل\u200cمدیریت انتخاب کنید',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
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
            child: Text(
              'یک موقعیت خفیف یا متوسط انتخاب کنید. بهتر است شدیدترین یا خصوصی\u200cترین تجربه خود را برای این تمرین انتخاب نکنید.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
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
          _buildLabel('چه فکری از ذهن شما گذشت؟'),
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
          // Field 3: Emotion dropdown
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
          _buildLabel('شدت هیجان چقدر بود؟'),
          _buildSlider(
            value: _emotionIntensity,
            onChanged: (v) => setState(() => _emotionIntensity = v),
          ),
          SizedBox(height: AppSizes.md),
          // Field 5: Belief slider
          _buildLabel('در آن لحظه چقدر فکر را باور داشتید؟'),
          _buildSlider(
            value: _beliefInitial,
            leftLabel: 'اصلاً باور نداشتم',
            rightLabel: 'کاملاً باور داشتم',
            onChanged: (v) => setState(() => _beliefInitial = v),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitThought ? _submitThought : null,
              child: const Text('ثبت فکر'),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _goToPage(3),
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

  void _submitThought() {
    context.read<Week4ViewModel>().submitExerciseResponse(
      weekNumber: 4,
      dayNumber: 22,
      exerciseType: 'cognitive_restructuring_thought_selection',
      data: {
        'selected_situation': _situationCtrl.text,
        'selected_thought': _thoughtCtrl.text,
        'selected_emotion': _emotion,
        'emotion_intensity_initial': _emotionIntensity.toInt(),
        'thought_belief_initial': _beliefInitial.toInt(),
      },
    );
    _goToPage(3);
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

  Widget _buildW4Img01() {
    return Image.asset(
      'assets/images/week4/w4_img_01.png',
      height: 180,
      errorBuilder: (_, __, ___) => Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_outlined,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            _buildFlowStep('فکر اولیه'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('بررسی شواهد موافق و مخالف'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('فکر متعادل\u200cتر'),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStep(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: PersianFonts.Vazir.copyWith(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
