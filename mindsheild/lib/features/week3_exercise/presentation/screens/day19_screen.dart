import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week3_view_model.dart';

class Day19Screen extends StatefulWidget {
  const Day19Screen({super.key});

  @override
  State<Day19Screen> createState() => _Day19ScreenState();
}

class _Day19ScreenState extends State<Day19Screen> {
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
                  dayNumber: 19,
                  dayTitle: 'ذهن‌خوانی و بایدها',
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
                    // D19-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week3ViewModel>().submitExerciseResponse(
                          weekNumber: 3,
                          dayNumber: 19,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D19-02: Mind reading
                    TextEducationPage(
                      title:
                          'وقتی بدون شواهد کافی، نظر دیگران را قطعی می\u200cدانیم',
                      bodyText:
                          'در ذهن\u200cخوانی، فرد تصور می\u200cکند می\u200cداند دیگران درباره او چه فکر یا احساسی دارند؛ بدون آنکه شواهد روشن کافی وجود داشته باشد.',
                      cards: const [
                        InfoCard(
                          title: 'مثال',
                          text: '«حتماً فکر می\u200cکنند من ضعیفم.»',
                        ),
                        InfoCard(
                          title: 'مثال',
                          text:
                              '«مطمئنم از من ناراضی است، حتی اگر چیزی نگفته باشد.»',
                        ),
                      ],
                      noteText:
                          'ممکن است حدس ما درست باشد؛ اما حدس با واقعیت قطعی یکسان نیست.',
                      primaryButtonText: 'ادامه',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D19-03: Shoulds
                    TextEducationPage(
                      title: 'قواعد سخت\u200cگیرانه درباره خود و دیگران',
                      bodyText:
                          'بعضی جمله\u200cهای «باید» و «نباید» به ما جهت می\u200cدهند. مشکل زمانی ایجاد می\u200cشود که این قواعد مطلق، غیرقابل انعطاف و تنبیه\u200cکننده شوند.\n\nمثال\u200cها:\n«نباید هیچ\u200cوقت خسته شوم.»\n«باید همیشه همه مشکلات را خودم حل کنم.»\n«نباید کمک بخواهم.»\n\nباید سخت\u200cگیرانه معمولاً با احساس گناه، شرم، خشم یا فشار بیشتر همراه می\u200cشود.',
                      primaryButtonText: 'ادامه',
                      onPrimaryButton: () => _goToPage(3),
                    ),
                    // D19-04: Quiz + personal question + end
                    _buildExerciseAndEnd(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final Map<int, String> _quizAnswers = {};
  String? _selectedShould;

  final _correctAnswers = {
    0: 'ذهن\u200cخوانی',
    1: 'باید ذهنی',
    2: 'هیچ\u200cکدام',
  };

  final _shouldOptions = [
    'نباید اشتباه کنم.',
    'نباید خسته شوم.',
    'باید همه مشکلات را خودم حل کنم.',
    'باید همیشه قوی به نظر برسم.',
    'نباید کمک بخواهم.',
    'باید همه را راضی نگه دارم.',
    'مورد دیگر',
    'هیچ\u200cکدام',
    'ترجیح می\u200cدهم پاسخ ندهم',
  ];

  bool _canSubmit() => _quizAnswers.length == 3 && _selectedShould != null;

  void _submitAndComplete() {
    int score = 0;
    for (int i = 0; i < 3; i++) {
      if (_quizAnswers[i] == _correctAnswers[i]) score++;
    }

    context.read<Week3ViewModel>().submitExerciseResponse(
      weekNumber: 3,
      dayNumber: 19,
      exerciseType: 'mind_reading_shoulds',
      data: {'score': score, 'total': 3, 'selected_should': _selectedShould},
    );

    context.read<Week3ViewModel>().completeDay(weekNumber: 3, dayNumber: 19);
    Navigator.of(context).pop();
  }

  Widget _buildExerciseAndEnd() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تمرین',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          _buildQuizQuestion(
            index: 0,
            question:
                '«حتماً همکارانم فکر می\u200cکنند من توانایی کافی ندارم.»',
            options: ['ذهن\u200cخوانی', 'باید ذهنی', 'هیچ\u200cکدام'],
          ),
          _buildQuizQuestion(
            index: 1,
            question: '«باید همیشه در هر شرایطی آرام باشم.»',
            options: ['ذهن\u200cخوانی', 'باید ذهنی', 'هیچ\u200cکدام'],
          ),
          _buildQuizQuestion(
            index: 2,
            question: '«از من خواسته شد بخشی از کار را اصلاح کنم.»',
            options: ['ذهن\u200cخوانی', 'باید ذهنی', 'هیچ\u200cکدام'],
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'کدام باید ذهنی برای شما آشناتر است؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._shouldOptions.map(
            (opt) => _buildRadioOption(
              opt,
              _selectedShould,
              (v) => setState(() => _selectedShould = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              'شناسایی بایدهای سخت\u200cگیرانه به معنای کنارگذاشتن مسئولیت یا استانداردها نیست؛ هدف، دیدن فشار اضافی این قواعد است.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit() ? _submitAndComplete : null,
              child: const Text('پایان روز نوزدهم'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildQuizQuestion({
    required int index,
    required String question,
    required List<String> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سؤال ${index + 1}',
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontXs,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          question,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w600,
            height: 1.7,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.sm),
        ...options.map(
          (opt) => _buildRadioOption(opt, _quizAnswers[index], (v) {
            setState(() => _quizAnswers[index] = opt);
          }),
        ),
        SizedBox(height: AppSizes.md),
      ],
    );
  }

  Widget _buildRadioOption(
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
}
