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
import '../view_models/week7_view_model.dart';

class Day46Screen extends StatefulWidget {
  const Day46Screen({super.key});

  @override
  State<Day46Screen> createState() => _Day46ScreenState();
}

class _Day46ScreenState extends State<Day46Screen> {
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
                  dayNumber: 46,
                  dayTitle: 'ارزیابی راه\u200cحل\u200cها',
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
                    // D46-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week7ViewModel>().submitExerciseResponse(
                          weekNumber: 7,
                          dayNumber: 46,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D46-02: Evaluation criteria
                    TextEducationPage(
                      title:
                          'بهترین راه\u200cحل لزوماً کامل\u200cترین راه نیست',
                      bodyText:
                          'یک راه\u200cحل مناسب باید علاوه بر فایده احتمالی، از نظر زمان، منابع، ایمنی، مقررات و امکان اجرا نیز بررسی شود.',
                      cards: const [
                        InfoCard(
                          title: 'اثر احتمالی',
                          text: 'چقدر می\u200cتواند به نتیجه موردنظر کمک کند؟',
                        ),
                        InfoCard(
                          title: 'امکان اجرا',
                          text:
                              'با زمان، انرژی و منابع فعلی چقدر قابل انجام است؟',
                        ),
                        InfoCard(
                          title: 'ایمنی',
                          text:
                              'آیا خطر جسمانی، روان\u200cشناختی یا سازمانی ایجاد می\u200cکند؟',
                        ),
                        InfoCard(
                          title: 'هماهنگی با مقررات',
                          text:
                              'آیا با مسئولیت\u200cها و مسیرهای رسمی سازگار است؟',
                        ),
                        InfoCard(
                          title: 'پیامد برای دیگران',
                          text: 'چه اثر احتمالی بر افراد مرتبط دارد؟',
                        ),
                      ],
                      noteText:
                          'اگر راهی خطرناک، غیرقانونی یا مغایر مقررات است، حتی اگر سریع باشد گزینه مناسبی نیست.',
                      primaryButtonText: 'راه\u200cها را ارزیابی کنم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D46-03: Evaluate solutions form
                    _buildEvaluationForm(),
                    // D46-04: Day end
                    DayEndPage(
                      title: 'پایان روز چهل\u200cوششم',
                      feedbackText:
                          'راه\u200cحلی که اثر متوسط اما امکان اجرای بالایی دارد، ممکن است از راه\u200cحلی ایده\u200cآل اما غیرقابل اجرا مفیدتر باشد.',
                      missionText:
                          'بررسی کنید برای عملی\u200cشدن گزینه مناسب\u200cتر، چه منبع یا اطلاعاتی لازم است.',
                      notificationText:
                          'امروز مزایا، محدودیت\u200cها و امکان اجرای راه\u200cحل\u200cها را بررسی کنید.',
                      buttonText: 'پایان روز چهل\u200cوششم',
                      onButtonPressed: () {
                        context.read<Week7ViewModel>().completeDay(
                          weekNumber: 7,
                          dayNumber: 46,
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

  // D46-03 form state
  final _evaluations = <int, Map<String, dynamic>>{};
  String? _preferredSolution;

  final _feasibilityOptions = ['کم', 'متوسط', 'زیاد'];
  final _safetyOptions = [
    'مناسب',
    'نیازمند بررسی بیشتر',
    'نامناسب',
    'مطمئن نیستم',
  ];
  final _preferenceOptions = [
    'راه\u200cحل اول',
    'راه\u200cحل دوم',
    'راه\u200cحل سوم',
    'ترکیب چند راه',
    'هنوز مطمئن نیستم',
  ];

  bool get _canSubmitEvaluation => _preferredSolution != null;

  Widget _buildEvaluationForm() {
    final vm = context.read<Week7ViewModel>();
    final solutions = vm.solutions;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ارزیابی راه\u200cحل\u200cها',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          if (solutions.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Text(
                'هنوز راه\u200cحلی ثبت نشده است. می\u200cتوانید امروز راه\u200cحل\u200cها را کوتاه بنویسید.',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.info,
                  height: 1.6,
                ),
              ),
            ),
          // Generate evaluation cards for each solution
          ...List.generate(solutions.length, (i) {
            _evaluations.putIfAbsent(i, () => {});
            return _buildSolutionCard(i, solutions[i]);
          }),
          SizedBox(height: AppSizes.lg),
          // Preferred solution
          Text(
            'در نگاه اول، کدام راه مناسب\u200cتر به نظر می\u200cرسد؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._preferenceOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _preferredSolution,
              (v) => setState(() => _preferredSolution = v),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitEvaluation ? _submitEvaluation : null,
              child: const Text('ثبت ارزیابی'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildSolutionCard(int index, String solutionText) {
    final eval = _evaluations[index]!;
    final benefitCtrl = TextEditingController(text: eval['main_benefit'] ?? '');
    final limitCtrl = TextEditingController(
      text: eval['main_limitation'] ?? '',
    );

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSizes.lg),
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
            'کارت راه\u200cحل ${index + 1}',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            solutionText,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'فایده اصلی (حداکثر ۱۰۰ کاراکتر):',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: benefitCtrl,
            maxLength: 100,
            maxLines: 2,
            onChanged: (v) => _evaluations[index]!['main_benefit'] = v,
            decoration: InputDecoration(
              hintText: 'فایده اصلی...',
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
              isDense: true,
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
          Text(
            'محدودیت یا هزینه اصلی (حداکثر ۱۰۰ کاراکتر):',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: limitCtrl,
            maxLength: 100,
            maxLines: 2,
            onChanged: (v) => _evaluations[index]!['main_limitation'] = v,
            decoration: InputDecoration(
              hintText: 'محدودیت اصلی...',
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
              isDense: true,
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
          Text(
            'امکان اجرا:',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          ..._feasibilityOptions.map((opt) {
            final isSelected = eval['feasibility'] == opt;
            return InkWell(
              onTap: () {
                setState(() => _evaluations[index]!['feasibility'] = opt);
              },
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: AppSizes.xs),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: opt,
                      groupValue: eval['feasibility'],
                      onChanged: (v) => setState(
                        () => _evaluations[index]!['feasibility'] = v,
                      ),
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Text(
                        opt,
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontSm,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: AppSizes.md),
          Text(
            'ایمنی و سازگاری:',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          ..._safetyOptions.map((opt) {
            final isSelected = eval['safety_fit'] == opt;
            return InkWell(
              onTap: () {
                setState(() => _evaluations[index]!['safety_fit'] = opt);
              },
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: AppSizes.xs),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: opt,
                      groupValue: eval['safety_fit'],
                      onChanged: (v) => setState(
                        () => _evaluations[index]!['safety_fit'] = v,
                      ),
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Text(
                        opt,
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontSm,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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

  void _submitEvaluation() {
    final responseData = <String, dynamic>{
      'preliminary_preferred_solution': _preferredSolution,
    };
    _evaluations.forEach((index, eval) {
      responseData['solution_${index + 1}_evaluation'] = eval;
    });
    context.read<Week7ViewModel>().submitExerciseResponse(
      weekNumber: 7,
      dayNumber: 46,
      exerciseType: 'solution_evaluation',
      data: responseData,
    );
    _goToPage(3);
  }
}
