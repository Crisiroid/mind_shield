import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/audio_player_page.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week6_view_model.dart';

class Day37Screen extends StatefulWidget {
  const Day37Screen({super.key});

  @override
  State<Day37Screen> createState() => _Day37ScreenState();
}

class _Day37ScreenState extends State<Day37Screen> {
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
                  dayNumber: 37,
                  dayTitle: 'مشاهده افکار',
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
                    // D37-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week6ViewModel>().submitExerciseResponse(
                          weekNumber: 6,
                          dayNumber: 37,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D37-02: Exercise guide
                    TextEducationPage(
                      title: 'اجازه می\u200cدهیم فکر بیاید و برود',
                      bodyText:
                          'در این تمرین، توجه ابتدا روی تنفس یا تماس بدن با سطح قرار می\u200cگیرد. وقتی فکری ظاهر شد، فقط آن را با واژه «فکر» نام\u200cگذاری می\u200cکنید و دوباره توجه را بازمی\u200cگردانید.\n\nهدف خالی\u200cکردن ذهن نیست. حتی اگر در تمام تمرین افکار زیادی ظاهر شوند، تمرین همچنان قابل انجام است.',
                      helpTitle: 'ایمنی',
                      helpText:
                          'یک زمان نسبتاً آرام و امن انتخاب کنید. اگر تمرین ناراحت\u200cکننده شد، چشم\u200cها را باز نگه دارید و توجه را به محیط بازگردانید.',
                      primaryButtonText: 'شروع تمرین',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D37-03: Audio player
                    AudioPlayerPage(
                      title: 'مشاهده افکار',
                      instruction:
                          'فایل صوتی زیر حدود ۴ دقیقه است. در وضعیت راحت و امن قرار بگیرید و تمرین را شروع کنید.',
                      audioAssetPath: 'assets/audio/week6/w6_aud_01.mp3',
                      skipText: 'عبور از تمرین',
                      onSkip: () => _goToPage(3),
                      onSubmit: (status) {
                        context.read<Week6ViewModel>().submitExerciseResponse(
                          weekNumber: 6,
                          dayNumber: 37,
                          exerciseType: 'guided_thought_observation',
                          data: {'audio_status': status},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D37-04: Registration + Day end
                    _buildExperienceForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // D37-04 form state
  String? _completionStatus;
  String? _returnExperience;
  String? _difficulty;

  final _completionOptions = ['کامل', 'بخشی', 'انجام ندادم.'];

  final _returnOptions = [
    'توانستم فکر را متوجه شوم و برگردم.',
    'چند بار متوجه شدم، اما برگشتن دشوار بود.',
    'بیشتر زمان درگیر فکر بودم.',
    'فکر مشخصی متوجه نشدم.',
    'مطمئن نیستم.',
    'تمرین را انجام ندادم.',
  ];

  final _difficultyOptions = [
    'آسان',
    'نسبتاً آسان',
    'دشوار',
    'ناراحت\u200cکننده',
    'مطمئن نیستم',
  ];

  bool get _canSubmit =>
      _completionStatus != null &&
      _returnExperience != null &&
      _difficulty != null;

  Widget _buildExperienceForm() {
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
          // Q2: Return experience
          Text(
            'هنگام ظاهرشدن فکر، چه تجربه\u200cای داشتید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._returnOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _returnExperience,
              (v) => setState(() => _returnExperience = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3: Difficulty
          Text(
            'انجام تمرین چگونه بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
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
          SizedBox(height: AppSizes.lg),
          // Message
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              'درگیرشدن با فکر به معنای شکست نیست. لحظه\u200cای که متوجه درگیری می\u200cشوید، همان لحظه امکان بازگشت ایجاد شده است.',
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
              child: const Text('پایان روز سی\u200cوهفتم'),
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
      dayNumber: 37,
      exerciseType: 'thought_observation_experience',
      data: {
        'thought_observation_status': _completionStatus,
        'thought_return_experience': _returnExperience,
        'thought_observation_difficulty': _difficulty,
      },
    );
    context.read<Week6ViewModel>().completeDay(weekNumber: 6, dayNumber: 37);
    Navigator.of(context).pop();
  }
}
