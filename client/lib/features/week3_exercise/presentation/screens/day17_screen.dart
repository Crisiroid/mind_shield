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

class Day17Screen extends StatefulWidget {
  const Day17Screen({super.key});

  @override
  State<Day17Screen> createState() => _Day17ScreenState();
}

class _Day17ScreenState extends State<Day17Screen> {
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
                  dayNumber: 17,
                  dayTitle: 'همه یا هیچ',
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
                    // D17-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week3ViewModel>().submitExerciseResponse(
                          weekNumber: 3,
                          dayNumber: 17,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D17-02: All-or-nothing thinking
                    TextEducationPage(
                      title: 'وقتی فقط دو حالت می\u200cبینیم',
                      bodyText:
                          'در تفکر همه یا هیچ، موقعیت فقط در دو حالت دیده می\u200cشود: موفقیت کامل یا شکست کامل، عالی یا افتضاح، توانمند یا ناتوان.\n\nاین نوع فکر، بخش\u200cهای میانی و اطلاعات جزئی\u200cتر را نادیده می\u200cگیرد.',
                      cards: const [
                        InfoCard(
                          title: 'مثال',
                          text:
                              '«اگر این کار بی\u200cنقص نباشد، کاملاً شکست خورده\u200cام.»',
                        ),
                        InfoCard(
                          title: 'مثال',
                          text: '«یا باید همیشه قوی باشم، یا فرد ضعیفی هستم.»',
                        ),
                      ],
                      noteText:
                          'عملکرد افراد معمولاً روی یک طیف قرار دارد، نه فقط در دو نقطه صفر و صد.',
                      primaryButtonText: 'ادامه',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D17-03: Labeling
                    TextEducationPage(
                      title: 'وقتی یک رفتار را به هویت تبدیل می\u200cکنیم',
                      bodyText:
                          'در برچسب\u200cزدن، فرد از یک اشتباه یا تجربه محدود، نتیجه\u200cای کلی درباره تمام هویت خود می\u200cگیرد.\n\nمثال:\nرویداد: بخشی از یک گزارش نیاز به اصلاح دارد.\nبرچسب: «من بی\u200cکفایتم.»\n\nتوصیف دقیق\u200cتر رفتار با تعریف کلی هویت تفاوت دارد.\n\nمثال دقیق\u200cتر:\n«این بخش از گزارش نیاز به اصلاح دارد.»',
                      primaryButtonText: 'ادامه',
                      onPrimaryButton: () => _goToPage(3),
                    ),
                    // D17-04: Quiz + personal question + day end
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

  Widget _buildExerciseAndEnd() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تمرین آموزشی',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // 4 quiz questions
          _buildQuizQuestion(
            index: 0,
            question: '«اگر در این کار بهترین نباشم، یعنی شکست خورده\u200cام.»',
            options: ['همه یا هیچ', 'برچسب\u200cزدن', 'هیچ\u200cکدام'],
            onSelect: (selected) => _quizAnswers[0] = selected,
          ),
          _buildQuizQuestion(
            index: 1,
            question: '«من یک فرد بی\u200cارزش هستم.»',
            options: ['همه یا هیچ', 'برچسب\u200cزدن', 'هیچ\u200cکدام'],
            onSelect: (selected) => _quizAnswers[1] = selected,
          ),
          _buildQuizQuestion(
            index: 2,
            question: '«این بخش از کارم نیاز به اصلاح دارد.»',
            options: ['همه یا هیچ', 'برچسب\u200cزدن', 'هیچ\u200cکدام'],
            onSelect: (selected) => _quizAnswers[2] = selected,
          ),
          _buildQuizQuestion(
            index: 3,
            question:
                '«یا باید کاملاً آرام باشم یا کنترل خود را از دست داده\u200cام.»',
            options: ['همه یا هیچ', 'برچسب\u200cزدن', 'هیچ\u200cکدام'],
            onSelect: (selected) => _quizAnswers[3] = selected,
          ),
          SizedBox(height: AppSizes.lg),
          // Personal question
          Text(
            'کدام الگو برای شما آشناتر است؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ...[
            'همه یا هیچ',
            'برچسب\u200cزدن',
            'هر دو',
            'هیچ\u200cکدام',
            'مطمئن نیستم',
          ].map(
            (opt) => _buildRadioOption(
              opt,
              _familiarPattern,
              (v) => setState(() => _familiarPattern = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Info message
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              'شناسایی یک الگوی فکری به معنای سرزنش خود نیست. این الگوها در بسیاری از افراد و به\u200cویژه هنگام فشار بیشتر می\u200cشوند.',
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
              onPressed: _canSubmitQuiz() ? _submitQuizAndComplete : null,
              child: const Text('پایان روز هفدهم'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  final Map<int, String> _quizAnswers = {};
  String? _familiarPattern;

  final _correctAnswers = {
    0: 'همه یا هیچ',
    1: 'برچسب\u200cزدن',
    2: 'هیچ\u200cکدام',
    3: 'همه یا هیچ',
  };

  bool _canSubmitQuiz() {
    return _quizAnswers.length == 4 && _familiarPattern != null;
  }

  void _submitQuizAndComplete() {
    int score = 0;
    for (int i = 0; i < 4; i++) {
      if (_quizAnswers[i] == _correctAnswers[i]) score++;
    }

    context.read<Week3ViewModel>().submitExerciseResponse(
      weekNumber: 3,
      dayNumber: 17,
      exerciseType: 'all_or_nothing_labeling',
      data: {'score': score, 'total': 4, 'familiar_pattern': _familiarPattern},
    );

    context.read<Week3ViewModel>().completeDay(weekNumber: 3, dayNumber: 17);
    Navigator.of(context).pop();
  }

  Widget _buildQuizQuestion({
    required int index,
    required String question,
    required List<String> options,
    required ValueChanged<String> onSelect,
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
            onSelect(opt);
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
