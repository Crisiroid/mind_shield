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
import '../view_models/week2_view_model.dart';

class Day12Screen extends StatefulWidget {
  const Day12Screen({super.key});

  @override
  State<Day12Screen> createState() => _Day12ScreenState();
}

class _Day12ScreenState extends State<Day12Screen> {
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
                  dayNumber: 12,
                  dayTitle: 'سه دقیقه مکث و تنفس',
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
                    // D12-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 12,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D12-02: 3-minute audio + question
                    _D12AudioAndQuestion(
                      onSubmit: (data) {
                        context.read<Week2ViewModel>().submitExerciseResponse(
                          weekNumber: 2,
                          dayNumber: 12,
                          exerciseType: 'three_minute_breathing',
                          data: data,
                        );
                        _goToPage(2);
                      },
                    ),
                    // D12-03: Day end
                    DayEndPage(
                      title: 'پایان روز دوازدهم',
                      missionText:
                          'تمرین کوتاه و منظم معمولاً از تمرین طولانی و پراکنده قابل اجرا\u200cتر است.\n\nامروز در صورت امکان، پیش از یک فعالیت عادی مانند شروع کار یا استراحت، یک دم و بازدم طبیعی را آگاهانه مشاهده کنید.',
                      notificationText:
                          'تمرین سه\u200cدقیقه\u200cای تنفس آماده است.',
                      buttonText: 'پایان روز دوازدهم',
                      onButtonPressed: () {
                        context.read<Week2ViewModel>().completeDay(
                          weekNumber: 2,
                          dayNumber: 12,
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
}

// D12-02: Audio player with pre-text and question
class _D12AudioAndQuestion extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;
  const _D12AudioAndQuestion({required this.onSubmit});

  @override
  State<_D12AudioAndQuestion> createState() => _D12AudioAndQuestionState();
}

class _D12AudioAndQuestionState extends State<_D12AudioAndQuestion> {
  bool _isPlaying = false;
  String? _practiceStatus;

  final _statusOptions = ['کامل', 'بخشی', 'انجام ندادم'];

  void _togglePlay() => setState(() => _isPlaying = !_isPlaying);
  void _stop() => setState(() => _isPlaying = false);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سه دقیقه مکث و تنفس',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'امروز محتوای آموزشی جدیدی ارائه نمی\u200cشود. تمرین روزهای قبل را کمی طولانی\u200cتر تکرار می\u200cکنید.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
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
              'در وضعیت امن انجام دهید. لازم نیست تنفس را عمیق یا کنترل کنید.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          // Audio player controls
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      30,
                      (i) => Container(
                        width: 3,
                        height: 10 + (i % 5) * 8.0,
                        margin: EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(
                            alpha: _isPlaying ? 0.6 : 0.3,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      icon: Icons.replay,
                      label: 'شروع مجدد',
                      onTap: () => setState(() => _isPlaying = true),
                    ),
                    SizedBox(width: AppSizes.lg),
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppColors.textOnPrimary,
                          size: 32,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.lg),
                    _buildControlButton(
                      icon: Icons.stop,
                      label: 'توقف',
                      onTap: _stop,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                widget.onSubmit({'status': 'skipped'});
              },
              child: Text(
                'عبور از تمرین',
                style: PersianFonts.Vazir.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          Text(
            'چه مقدار از تمرین را انجام دادید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._statusOptions.map((option) {
            final isSelected = _practiceStatus == option;
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.sm),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: () => setState(() => _practiceStatus = option),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: option,
                          groupValue: _practiceStatus,
                          onChanged: (v) => setState(() => _practiceStatus = v),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            option,
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
          }),
          SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _practiceStatus != null
                  ? () => widget.onSubmit({'status': _practiceStatus})
                  : null,
              child: const Text('ثبت و ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
