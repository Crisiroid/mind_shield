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

class Day25Screen extends StatefulWidget {
  const Day25Screen({super.key});

  @override
  State<Day25Screen> createState() => _Day25ScreenState();
}

class _Day25ScreenState extends State<Day25Screen> {
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
                  dayNumber: 25,
                  dayTitle: 'فکر متعادل',
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
                    // D25-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week4ViewModel>().submitExerciseResponse(
                          weekNumber: 4,
                          dayNumber: 25,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D25-02: What is balanced thought?
                    TextEducationPage(
                      title: 'نه انکار مشکل، نه اغراق درباره آن',
                      bodyText:
                          'فکر متعادل، دشواری واقعی موقعیت را می\u200cپذیرد؛ اما نتیجه\u200cگیری\u200cهای کلی، قطعی یا شدید را کاهش می\u200cدهد.\n\nفکر متعادل باید با شواهد هماهنگ، باورپذیر و کاربردی باشد.\n\nفرمول ساده: واقعیت دشوار + اطلاعات تکمیلی + اقدام ممکن',
                      imageWidget: _buildW4Img02(),
                      cards: const [
                        InfoCard(
                          title: 'مثال',
                          text:
                              'فکر اولیه: «من کاملاً بی\u200cکفایتم.»\n\nفکر مثبت غیرواقعی: «من در همه کارها عالی هستم.»\n\nفکر متعادل: «این بخش از کارم نیاز به اصلاح دارد، اما یک ایراد به معنای بی\u200cکفایتی کامل من نیست. می\u200cتوانم بخش مشخص را بررسی و اصلاح کنم.»',
                        ),
                        InfoCard(
                          title: 'نکته',
                          text:
                              'اگر فکر جدید برای شما باورپذیر نیست، احتمالاً بیش از حد مثبت یا بسیار متفاوت از شواهد نوشته شده است.',
                        ),
                      ],
                      primaryButtonText: 'فکر متعادل خود را بنویسم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D25-03: Balanced thought form
                    _buildBalancedThoughtForm(),
                    // D25-04: Day end
                    DayEndPage(
                      title: 'پایان روز بیست\u200cوپنجم',
                      missionText:
                          'فکر متعادل قرار نیست تجربه شما را بی\u200cاهمیت جلوه دهد. هدف آن است که موقعیت را دقیق\u200cتر و با انعطاف بیشتر ببینید.\n\nمأموریت: امروز در صورت بازگشت فکر اولیه، فکر متعادل خود را یک بار مرور کنید.',
                      notificationText:
                          'امروز با استفاده از شواهد، یک فکر متعادل\u200cتر بنویسید.',
                      buttonText: 'پایان روز بیست\u200cوپنجم',
                      onButtonPressed: () {
                        context.read<Week4ViewModel>().completeDay(
                          weekNumber: 4,
                          dayNumber: 25,
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
  final _balancedThoughtCtrl = TextEditingController();
  double _beliefCurrent = 5;
  double _balancedBelief = 5;

  bool get _canSubmit => _balancedThoughtCtrl.text.isNotEmpty;

  Widget _buildBalancedThoughtForm() {
    final vm = context.read<Week4ViewModel>();
    final selectedThought = vm.lastSelectedThought;
    final supporting = vm.supportingEvidence;
    final counter = vm.counterEvidence;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نوشتن فکر متعادل',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Safety box
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
              'یک موقعیت خفیف یا متوسط و غیرمحرمانه انتخاب کنید. از ثبت نام افراد، محل خدمت، یگان، اطلاعات سازمانی یا جزئیات مأموریتی خودداری کنید.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Summary of previous days
          if (selectedThought != null ||
              supporting.isNotEmpty ||
              counter.isNotEmpty) ...[
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
                    'خلاصه روزهای قبل',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSizes.sm),
                  if (selectedThought != null) ...[
                    _buildSummaryRow('فکر اولیه', '«$selectedThought»'),
                    SizedBox(height: AppSizes.xs),
                  ],
                  if (supporting.isNotEmpty) ...[
                    _buildSummaryRow('شاهد موافق', supporting.join(' | ')),
                    SizedBox(height: AppSizes.xs),
                  ],
                  if (counter.isNotEmpty) ...[
                    _buildSummaryRow(
                      'اطلاعات مخالف یا تکمیلی',
                      counter.join(' | '),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: AppSizes.lg),
          ],
          // Field 1: Balanced thought
          _buildLabel(
            'با درنظرگرفتن تمام اطلاعات، فکر متعادل\u200cتر شما چیست؟',
          ),
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
          SizedBox(height: AppSizes.xs),
          Text(
            'تلاش کنید هم دشواری واقعی و هم اطلاعات تکمیلی را در جمله خود بیاورید.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Field 2: Current belief in original thought
          _buildLabel('اکنون چقدر فکر اولیه را باور دارید؟'),
          _buildSlider(
            value: _beliefCurrent,
            onChanged: (v) => setState(() => _beliefCurrent = v),
          ),
          SizedBox(height: AppSizes.lg),
          // Field 3: Balanced thought belief
          _buildLabel('فکر متعادل جدید چقدر برای شما باورپذیر است؟'),
          _buildSlider(
            value: _balancedBelief,
            onChanged: (v) => setState(() => _balancedBelief = v),
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
              'لازم نیست باور به فکر اولیه به صفر برسد. حتی تغییر کوچک نیز می\u200cتواند نشان دهد که اکنون اطلاعات بیشتری را در نظر می\u200cگیرید.',
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
              onPressed: _canSubmit ? _submitBalancedThought : null,
              child: const Text('ثبت فکر متعادل'),
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

  void _submitBalancedThought() {
    context.read<Week4ViewModel>().submitExerciseResponse(
      weekNumber: 4,
      dayNumber: 25,
      exerciseType: 'balanced_thought',
      data: {
        'balanced_thought': _balancedThoughtCtrl.text,
        'initial_thought_belief_current': _beliefCurrent.toInt(),
        'balanced_thought_belief': _balancedBelief.toInt(),
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

  Widget _buildW4Img02() {
    return Image.asset(
      'assets/images/week4/w4_img_02.png',
      height: 180,
      errorBuilder: (_, __, ___) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeatureCard(
              'انکار نمی\u200cکند',
              'دشواری واقعی موقعیت را می\u200cپذیرد.',
            ),
            SizedBox(height: AppSizes.xs),
            _buildFeatureCard(
              'اغراق نمی\u200cکند',
              'از یک اتفاق، نتیجه کلی و قطعی نمی\u200cگیرد.',
            ),
            SizedBox(height: AppSizes.xs),
            _buildFeatureCard(
              'کاربردی است',
              'به فرد کمک می\u200cکند اقدام مناسب\u200cتری انتخاب کند.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            description,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
