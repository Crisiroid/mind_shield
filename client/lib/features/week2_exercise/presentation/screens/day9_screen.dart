import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/audio_player_page.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week2_view_model.dart';

class Day9Screen extends StatefulWidget {
  const Day9Screen({super.key});

  @override
  State<Day9Screen> createState() => _Day9ScreenState();
}

class _Day9ScreenState extends State<Day9Screen> {
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
                  dayNumber: 9,
                  dayTitle: 'یک دقیقه توجه به بدن',
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
                    // D9-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 9,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D9-02: Short pause education
                    TextEducationPage(
                      title: 'یک توقف کوتاه',
                      bodyText:
                          'گاهی نشانه\u200cهای بدن را زمانی متوجه می\u200cشویم که شدت آن\u200cها زیاد شده است. توقف کوتاه کمک می\u200cکند وضعیت بدن را زودتر بررسی کنیم.\n\nدر این تمرین لازم نیست بدن را آرام یا عضلات را شل کنید. فقط وضعیت تماس بدن، شانه\u200cها، صورت و تنفس را مشاهده می\u200cکنید.',
                      imageWidget: Image.asset(
                        'assets/images/week2/w2_img_01.png',
                        height: 180,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                          child: Icon(
                            Icons.pause_circle_outline,
                            size: 48,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      helpTitle: 'ایمنی',
                      helpText:
                          'این تمرین را هنگام رانندگی یا انجام فعالیتی که به توجه کامل نیاز دارد انجام ندهید.',
                      primaryButtonText: 'شروع تمرین',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D9-03: Audio player - 1 minute body pause
                    AudioPlayerPage(
                      title: 'توقف کوتاه بدن',
                      instruction:
                          'وضعیت راحتی انتخاب کنید. می\u200cتوانید چشم\u200cها را باز نگه دارید.',
                      audioAssetPath: 'assets/audio/week2/w2_aud_01.mp3',
                      skipText: 'عبور از تمرین',
                      onSkip: () => _goToPage(3),
                      onSubmit: (status) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 9,
                          exerciseType: 'one_minute_body_pause',
                          data: {'status': status},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D9-04: Registration and end
                    _D9Registration(
                      onSubmit: (data) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 9,
                          exerciseType: 'one_minute_body_pause_reflection',
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
                            content: DayEndPage(
                              title: 'پایان روز نهم',
                              missionText:
                                  'لازم نیست احساس خاصی پیدا کنید. همین توجه\u200cکردن، بخش اصلی تمرین است.',
                              notificationText:
                                  'یک دقیقه برای بررسی وضعیت بدن خود در نظر بگیرید.',
                              buttonText: 'پایان روز نهم',
                              onButtonPressed: () {
                                Navigator.of(context).pop();
                                context.read<Week2ViewModel>().completeDay(
                                  weekNumber: 2,
                                  dayNumber: 9,
                                );
                                Navigator.of(context).pop();
                              },
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

// D9-04: Registration form
class _D9Registration extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;
  const _D9Registration({required this.onSubmit});

  @override
  State<_D9Registration> createState() => _D9RegistrationState();
}

class _D9RegistrationState extends State<_D9Registration> {
  String? _practiceStatus;
  String? _noticedArea;

  final _statusOptions = ['بله', 'بخشی از آن را انجام دادم', 'انجام ندادم'];
  final _bodyAreas = [
    'پاها و تماس با زمین',
    'شانه\u200cها',
    'صورت و فک',
    'دست\u200cها',
    'تنفس',
    'بخش دیگر',
    'بخش مشخصی نبود',
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
          if (_practiceStatus == 'بله' ||
              _practiceStatus == 'بخشی از آن را انجام دادم') ...[
            SizedBox(height: AppSizes.lg),
            Text(
              'کدام بخش بدن بیشتر توجه شما را جلب کرد؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            ..._bodyAreas.map(
              (opt) => _buildRadioTile(
                opt,
                _noticedArea,
                (v) => setState(() => _noticedArea = v),
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
                      'noticed_area': _noticedArea,
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
