import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/audio_player_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week6_view_model.dart';

class Day40Screen extends StatefulWidget {
  const Day40Screen({super.key});

  @override
  State<Day40Screen> createState() => _Day40ScreenState();
}

class _Day40ScreenState extends State<Day40Screen> {
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
                  dayNumber: 40,
                  dayTitle: 'پذیرش هیجان',
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
                    // D40-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week6ViewModel>().submitExerciseResponse(
                          weekNumber: 6,
                          dayNumber: 40,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D40-02: Acceptance education with W6-IMG-03
                    TextEducationPage(
                      title: 'پذیرش با تسلیم تفاوت دارد',
                      bodyText:
                          'وقتی هیجانی ناخوشایند ایجاد می\u200cشود، ممکن است تلاش کنیم آن را فوراً سرکوب، انکار یا حذف کنیم. گاهی این تلاش، توجه و درگیری ما را بیشتر می\u200cکند.\n\nپذیرش یعنی تشخیص اینکه هیجان اکنون وجود دارد و اجازه\u200cدادن به مشاهده کوتاه آن، بدون واکنش فوری.\n\nپذیرش به این معنا نیست:\n• هیجان را دوست داشته باشیم.\n• فکر همراه آن را درست بدانیم.\n• شرایط ناعادلانه یا خطرناک را تحمل کنیم.\n• اقدام مؤثر را کنار بگذاریم.\n• برای مدت طولانی در ناراحتی شدید بمانیم.',
                      imageWidget: _buildW6Img03(),
                      cards: const [
                        InfoCard(
                          title: 'جمله تمرین',
                          text:
                              '«این هیجان اکنون وجود دارد. لازم نیست همین لحظه آن را حذف کنم.»',
                        ),
                      ],
                      primaryButtonText: 'تمرین پذیرش',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D40-03: Audio player
                    AudioPlayerPage(
                      title: 'پذیرش هیجان',
                      instruction:
                          'یک هیجان خفیف یا متوسط انتخاب کنید. اگر اکنون هیجان بسیار شدیدی دارید، این تمرین را انجام ندهید و از تمرین\u200cهای توجه به محیط یا راهنما و کمک استفاده کنید.\n\nفایل صوتی زیر حدود ۳ تا ۴ دقیقه است.',
                      audioAssetPath: 'assets/audio/week6/w6_aud_02.mp3',
                      skipText: 'عبور از تمرین',
                      onSkip: () => _goToPage(3),
                      onSubmit: (status) {
                        context.read<Week6ViewModel>().submitExerciseResponse(
                          weekNumber: 6,
                          dayNumber: 40,
                          exerciseType: 'emotion_acceptance',
                          data: {'audio_status': status},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D40-04: Registration + Day end
                    _buildAcceptanceForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // D40-04 form state
  String? _completionStatus;
  String? _acceptanceExperience;
  String? _acceptanceUnderstanding;

  final _completionOptions = ['کامل', 'بخشی', 'انجام ندادم.'];

  final _experienceOptions = [
    'توانستم هیجان را برای مدت کوتاهی مشاهده کنم.',
    'مدام تلاش می\u200cکردم آن را تغییر دهم.',
    'توجه من بیشتر روی فکرها بود.',
    'ناراحتی بیشتر شد.',
    'احساس خاصی متوجه نشدم.',
    'مطمئن نیستم.',
    'تمرین را انجام ندادم.',
  ];

  final _understandingOptions = [
    'اجازه\u200cدادن به وجود هیجان',
    'تسلیم و ناتوانی',
    'تحمل اجباری',
    'بی\u200cتفاوتی',
    'هنوز تفاوت آن\u200cها را نمی\u200cدانم',
  ];

  bool get _canSubmit =>
      _completionStatus != null &&
      _acceptanceExperience != null &&
      _acceptanceUnderstanding != null;

  Widget _buildAcceptanceForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ثبت تجربه',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Q1: Completion
          Text(
            'چه مقدار از تمرین را انجام دادید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._completionOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _completionStatus,
              (v) => setState(() => _completionStatus = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2: Experience
          Text(
            'در طول تمرین چه تجربه\u200cای داشتید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._experienceOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _acceptanceExperience,
              (v) => setState(() => _acceptanceExperience = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3: Understanding
          Text(
            'پذیرش برای شما بیشتر شبیه کدام تجربه بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._understandingOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _acceptanceUnderstanding,
              (v) => setState(() => _acceptanceUnderstanding = v),
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Message
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              'پذیرش یک مهارت تدریجی است. لازم نیست در اولین تمرین احساس متفاوت یا آرامش فوری ایجاد شود.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submitForm : null,
              child: const Text('پایان روز چهلم'),
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

  void _submitForm() {
    context.read<Week6ViewModel>().submitExerciseResponse(
      weekNumber: 6,
      dayNumber: 40,
      exerciseType: 'acceptance_experience',
      data: {
        'emotion_acceptance_status': _completionStatus,
        'acceptance_experience': _acceptanceExperience,
        'acceptance_understanding': _acceptanceUnderstanding,
      },
    );
    context.read<Week6ViewModel>().completeDay(weekNumber: 6, dayNumber: 40);
    Navigator.of(context).pop();
  }

  Widget _buildW6Img03() {
    return Image.asset(
      'assets/images/week6/w6_img_03.png',
      height: 180,
      errorBuilder: (_, __, ___) => Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Acceptance column
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'پذیرش',
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSmallStep('می\u200cپذیرم این هیجان اکنون وجود دارد.'),
                    _buildSmallStep('لازم نیست فوراً آن را حذف کنم.'),
                    _buildSmallStep('می\u200cتوانم اقدام مؤثر انتخاب کنم.'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Surrender column
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'تسلیم یا بی\u200cعملی',
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSmallStep('هیچ کاری نمی\u200cتوانم انجام دهم.'),
                    _buildSmallStep('باید شرایط نامناسب را تحمل کنم.'),
                    _buildSmallStep(
                      'اقدامی برای حفاظت یا حل مشکل انجام نمی\u200cدهم.',
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

  Widget _buildSmallStep(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: PersianFonts.Vazir.copyWith(
          fontSize: 9,
          height: 1.4,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
