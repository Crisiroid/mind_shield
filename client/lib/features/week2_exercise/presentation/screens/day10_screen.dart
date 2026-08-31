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

class Day10Screen extends StatefulWidget {
  const Day10Screen({super.key});

  @override
  State<Day10Screen> createState() => _Day10ScreenState();
}

class _Day10ScreenState extends State<Day10Screen> {
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
                  dayNumber: 10,
                  dayTitle: 'اسکن بدن',
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
                    // D10-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 10,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D10-02: What is body scan?
                    TextEducationPage(
                      title: 'توجه را در بدن حرکت می\u200cدهیم',
                      bodyText:
                          'در اسکن بدن، توجه به\u200cتدریج میان بخش\u200cهای مختلف بدن حرکت می\u200cکند.\n\nممکن است در بعضی نواحی فشار، گرما، سنگینی، انقباض یا هیچ احساس مشخصی وجود داشته باشد. همه این تجربه\u200cها قابل قبول\u200cاند.\n\nهدف اسکن بدن، پیدا کردن مشکل، رسیدن به آرامش کامل یا ایجاد احساس خاص نیست. هدف، مشاهده منظم تجربه بدن است.',
                      imageWidget: Image.asset(
                        'assets/images/week2/w2_img_02.png',
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
                            Icons.accessibility_new,
                            size: 48,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      noteText:
                          'اگر در ناحیه\u200cای احساس ناخوشایندی وجود داشت، می\u200cتوانید توجه را به تماس پاها با زمین یا صداهای محیط بازگردانید.',
                      primaryButtonText: 'شروع اسکن بدن',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D10-03: Body scan audio
                    AudioPlayerPage(
                      title: 'اسکن کوتاه بدن',
                      instruction:
                          'می\u200cتوانید نشسته یا درازکشیده باشید. وضعیتی را انتخاب کنید که امن و نسبتاً راحت باشد.',
                      audioAssetPath: 'assets/audio/week2/w2_aud_02.mp3',
                      safetyText:
                          'اگر در ناحیه\u200cای احساس ناخوشایندی وجود داشت، می\u200cتوانید توجه را به تماس پاها با زمین یا صداهای محیط بازگردانید.',
                      questionText: 'چه مقدار از تمرین را انجام دادید؟',
                      statusOptions: const ['کامل', 'بخشی', 'انجام ندادم'],
                      skipText: 'عبور از تمرین',
                      onSkip: () => _goToPage(3),
                      onSubmit: (status) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 10,
                          exerciseType: 'body_scan',
                          data: {'status': status},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D10-04: Registration and end
                    _D10Registration(
                      onSubmit: (data) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 10,
                          exerciseType: 'body_scan_reflection',
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
                                  'دشواربودن تمرکز به معنای ناموفق\u200cبودن تمرین نیست. هر بار که متوجه حواس\u200cپرتی می\u200cشوید و برمی\u200cگردید، مهارت توجه را تمرین می\u200cکنید.',
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
                                            dayNumber: 10,
                                          );
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('پایان روز دهم'),
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

// D10-04: Registration form with 3 questions
class _D10Registration extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;
  const _D10Registration({required this.onSubmit});

  @override
  State<_D10Registration> createState() => _D10RegistrationState();
}

class _D10RegistrationState extends State<_D10Registration> {
  String? _scanStatus;
  String? _noticedArea;
  String? _difficulty;

  final _statusOptions = ['کامل', 'بخشی', 'انجام ندادم'];
  final _areaOptions = [
    'پاها',
    'شکم',
    'قفسه سینه',
    'شانه\u200cها و دست\u200cها',
    'صورت و فک',
    'کل بدن',
    'ناحیه مشخصی نبود',
  ];
  final _difficultyOptions = ['آسان', 'نسبتاً آسان', 'دشوار', 'مطمئن نیستم'];

  bool get _canSubmit => _scanStatus != null;

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
            'چه مقدار از تمرین را انجام دادید؟',
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
              _scanStatus,
              (v) => setState(() => _scanStatus = v),
            ),
          ),
          if (_scanStatus == 'کامل' || _scanStatus == 'بخشی') ...[
            SizedBox(height: AppSizes.lg),
            // Q2
            Text(
              'کدام ناحیه بیشتر توجه شما را جلب کرد؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            ..._areaOptions.map(
              (opt) => _buildRadioTile(
                opt,
                _noticedArea,
                (v) => setState(() => _noticedArea = v),
              ),
            ),
            SizedBox(height: AppSizes.lg),
            // Q3
            Text(
              'انجام تمرین برای شما چگونه بود؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            ..._difficultyOptions.map(
              (opt) => _buildRadioTile(
                opt,
                _difficulty,
                (v) => setState(() => _difficulty = v),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit
                  ? () => widget.onSubmit({
                      'status': _scanStatus,
                      'noticed_area': _noticedArea,
                      'difficulty': _difficulty,
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
