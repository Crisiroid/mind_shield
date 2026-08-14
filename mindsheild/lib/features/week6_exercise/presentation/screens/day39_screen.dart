import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week6_view_model.dart';

class Day39Screen extends StatefulWidget {
  const Day39Screen({super.key});

  @override
  State<Day39Screen> createState() => _Day39ScreenState();
}

class _Day39ScreenState extends State<Day39Screen> {
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
                  dayNumber: 39,
                  dayTitle: 'هیجان اکنون چیست؟',
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
                    // D39-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week6ViewModel>().submitExerciseResponse(
                          weekNumber: 6,
                          dayNumber: 39,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D39-02: Emotion, body and action urge education
                    TextEducationPage(
                      title: 'هیجان، بدن و میل به عمل',
                      bodyText:
                          'هیجان\u200cها بخشی طبیعی از پاسخ انسان به موقعیت\u200cها هستند. آن\u200cها ممکن است توجه ما را به خطر، نیاز، فقدان، بی\u200cعدالتی یا موضوعی مهم جلب کنند.\n\nهر هیجان معمولاً با نشانه\u200cهای بدنی و یک میل به عمل همراه است.',
                      imageWidget: _buildW6Img02(),
                      cards: const [
                        InfoCard(
                          title: 'اضطراب',
                          text:
                              'نشانه احتمالی: افزایش ضربان قلب\nمیل احتمالی: اجتناب یا اطمینان\u200cخواهی',
                        ),
                        InfoCard(
                          title: 'خشم',
                          text:
                              'نشانه احتمالی: تنش عضلات\nمیل احتمالی: پاسخ سریع یا مقابله',
                        ),
                        InfoCard(
                          title: 'ناراحتی',
                          text:
                              'نشانه احتمالی: سنگینی یا کاهش انرژی\nمیل احتمالی: کناره\u200cگیری',
                        ),
                      ],
                      noteText:
                          'میل به عمل با خود رفتار یکسان نیست. می\u200cتوان میل را مشاهده کرد و سپس درباره رفتار تصمیم گرفت.',
                      primaryButtonText: 'هیجان خود را بررسی کنم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D39-03: Emotion registration form
                    _buildEmotionForm(),
                    // D39-04: Day end
                    DayEndPage(
                      title: 'پایان روز سی\u200cونهم',
                      feedbackText:
                          'نام\u200cگذاری هیجان به معنای قضاوت یا تأیید رفتار نیست. شما فقط تجربه موجود و میل همراه آن را واضح\u200cتر مشاهده کردید.',
                      missionText:
                          'امروز یک بار جمله زیر را کامل کنید:\n«اکنون متوجه حضورِ ... هستم.»',
                      notificationText:
                          'امروز هیجان، نشانه بدنی و میل به عمل را نام\u200cگذاری کنید.',
                      buttonText: 'پایان روز سی\u200cونهم',
                      onButtonPressed: () {
                        context.read<Week6ViewModel>().completeDay(
                          weekNumber: 6,
                          dayNumber: 39,
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

  // D39-03 form state
  String? _emotionType;
  double _emotionIntensity = 5;
  String? _bodyArea;
  String? _actionUrge;

  final _emotionOptions = [
    'اضطراب',
    'نگرانی',
    'خشم',
    'ناراحتی',
    'شرم',
    'احساس گناه',
    'ناامیدی',
    'ترس',
    'سردرگمی',
    'بی\u200cحسی',
    'هیجان دیگر',
    'مطمئن نیستم',
  ];

  final _bodyAreaOptions = [
    'سر و صورت',
    'گردن و شانه',
    'قفسه سینه',
    'شکم',
    'دست\u200cها',
    'پاها',
    'کل بدن',
    'محل مشخصی ندارد',
    'مطمئن نیستم',
  ];

  final _actionUrgeOptions = [
    'اجتناب یا دورشدن',
    'پاسخ سریع',
    'سکوت یا کناره\u200cگیری',
    'اطمینان\u200cخواهی',
    'بررسی مکرر',
    'گریه',
    'کمک\u200cخواستن',
    'میل دیگری',
    'میل مشخصی ندارد',
    'مطمئن نیستم',
  ];

  bool get _canSubmitEmotion =>
      _emotionType != null && _bodyArea != null && _actionUrge != null;

  Widget _buildEmotionForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اکنون چه هیجانی وجود دارد؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Q1: Emotion type
          Text(
            'هیجان اصلی چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._emotionOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _emotionType,
              (v) => setState(() => _emotionType = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2: Intensity slider
          Text(
            'شدت آن از صفر تا ده چقدر است؟',
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
              value: _emotionIntensity,
              min: 0,
              max: 10,
              divisions: 10,
              label: _emotionIntensity.toInt().toString(),
              onChanged: (v) => setState(() => _emotionIntensity = v),
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
                _emotionIntensity.toInt().toString(),
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
          SizedBox(height: AppSizes.lg),
          // Q3: Body area
          Text(
            'هیجان را بیشتر در کدام ناحیه بدن احساس می\u200cکنید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._bodyAreaOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _bodyArea,
              (v) => setState(() => _bodyArea = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4: Action urge
          Text(
            'این هیجان چه میلی به عمل ایجاد می\u200cکند؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._actionUrgeOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _actionUrge,
              (v) => setState(() => _actionUrge = v),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitEmotion ? _submitEmotion : null,
              child: const Text('ثبت هیجان'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
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

  void _submitEmotion() {
    context.read<Week6ViewModel>().submitExerciseResponse(
      weekNumber: 6,
      dayNumber: 39,
      exerciseType: 'emotion_identification',
      data: {
        'emotion_type': _emotionType,
        'emotion_intensity': _emotionIntensity.toInt(),
        'emotion_body_area': _bodyArea,
        'emotion_action_urge': _actionUrge,
      },
    );
    _goToPage(3);
  }

  Widget _buildW6Img02() {
    return Image.asset(
      'assets/images/week6/w6_img_02.png',
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
            _buildFlowStep('موقعیت'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('هیجان و نشانه بدنی'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('میل به عمل'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('مکث کوتاه'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('انتخاب پاسخ'),
            SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'خشم ← تنش بدن ← میل به پاسخ سریع ← مکث ← پاسخ سنجیده\u200cتر',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ),
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
