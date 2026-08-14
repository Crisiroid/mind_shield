import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/audio_player_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week2_view_model.dart';

class Day11Screen extends StatefulWidget {
  const Day11Screen({super.key});

  @override
  State<Day11Screen> createState() => _Day11ScreenState();
}

class _Day11ScreenState extends State<Day11Screen> {
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
                  dayNumber: 11,
                  dayTitle: 'تنفس آگاهانه',
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
                    // D11-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 11,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D11-02: Mindful breathing education
                    TextEducationPage(
                      title: 'تنفس به\u200cعنوان نقطه بازگشت توجه',
                      bodyText:
                          'تنفس همیشه در لحظه حال رخ می\u200cدهد. به همین دلیل می\u200cتواند نقطه\u200cای برای بازگرداندن توجه باشد.\n\nدر این تمرین لازم نیست نفس عمیق بکشید، مدت دم و بازدم را اندازه بگیرید یا تنفس را کنترل کنید. فقط جریان طبیعی آن را مشاهده می\u200cکنید.\n\nممکن است توجه شما بارها از تنفس دور شود. هدف جلوگیری کامل از حواس\u200cپرتی نیست؛ هدف این است که متوجه آن شوید و توجه را بازگردانید.',
                      helpTitle: 'ایمنی',
                      helpText:
                          'اگر احساس سرگیجه، تنگی نفس یا ناراحتی کردید، تمرین را متوقف کنید و به تنفس طبیعی بازگردید.',
                      primaryButtonText: 'شروع تمرین',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D11-03: Breathing observation audio
                    AudioPlayerPage(
                      title: 'مشاهده طبیعی تنفس',
                      instruction:
                          'در وضعیت راحت قرار بگیرید و اجازه دهید تنفس به شکل طبیعی ادامه پیدا کند.',
                      audioAssetPath: 'assets/audio/week2/w2_aud_03.mp3',
                      skipText: 'عبور از تمرین',
                      onSkip: () => _goToPage(3),
                      onSubmit: (status) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 11,
                          exerciseType: 'breathing_observation',
                          data: {'status': status},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D11-04: Registration and end
                    _D11Registration(
                      onSubmit: (data) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 11,
                          exerciseType: 'breathing_observation_reflection',
                          data: data,
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
                                  'حواس\u200cپرتی بخشی طبیعی از تمرین است. مهارت اصلی، تشخیص حواس\u200cپرتی و بازگشت بدون سرزنش است.',
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
                                            dayNumber: 11,
                                          );
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('پایان روز یازدهم'),
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

// D11-04: Registration form with 3 questions
class _D11Registration extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;
  const _D11Registration({required this.onSubmit});

  @override
  State<_D11Registration> createState() => _D11RegistrationState();
}

class _D11RegistrationState extends State<_D11Registration> {
  String? _practiceStatus;
  String? _breathingLocation;
  String? _attentionReturn;

  final _statusOptions = ['کامل', 'بخشی', 'انجام ندادم'];
  final _locationOptions = [
    'بینی',
    'قفسه سینه',
    'شکم',
    'محل دیگری',
    'احساس مشخصی نداشتم',
  ];
  final _returnOptions = [
    'توانستم توجه را بازگردانم.',
    'چند بار بازگشتم، اما دشوار بود.',
    'بیشتر زمان حواسم پرت بود.',
    'مطمئن نیستم.',
    'تمرین را انجام ندادم.',
  ];

  bool get _canSubmit => _practiceStatus != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ثبت و پایان',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q1
          Text(
            'آیا تمرین را انجام دادید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._statusOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _practiceStatus,
              (v) => setState(() => _practiceStatus = v),
            ),
          ),
          if (_practiceStatus != null && _practiceStatus != 'انجام ندادم') ...[
            SizedBox(height: AppSizes.lg),
            // Q2
            Text(
              'تنفس را بیشتر در کجا احساس کردید؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            ..._locationOptions.map(
              (opt) => _buildRadioTile(
                opt,
                _breathingLocation,
                (v) => setState(() => _breathingLocation = v),
              ),
            ),
            SizedBox(height: AppSizes.lg),
            // Q3
            Text(
              'هنگام حواس\u200cپرتی چه اتفاقی افتاد؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            ..._returnOptions.map(
              (opt) => _buildRadioTile(
                opt,
                _attentionReturn,
                (v) => setState(() => _attentionReturn = v),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit
                  ? () => widget.onSubmit({
                      'status': _practiceStatus,
                      'breathing_location': _breathingLocation,
                      'attention_return_experience': _attentionReturn,
                    })
                  : null,
              child: const Text('ثبت و ادامه'),
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
      margin: EdgeInsets.only(bottom: AppSizes.sm),
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
              vertical: AppSizes.sm,
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
