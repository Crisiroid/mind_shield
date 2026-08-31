import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/multi_choice_quiz_page.dart';
import '../../../week1_exercise/presentation/widgets/week_evaluation_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week4_view_model.dart';

class Day28Screen extends StatefulWidget {
  const Day28Screen({super.key});

  @override
  State<Day28Screen> createState() => _Day28ScreenState();
}

class _Day28ScreenState extends State<Day28Screen> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalSteps = 5;

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
                  dayNumber: 28,
                  dayTitle: 'مرور بازسازی شناختی',
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
                    // D28-01: Week summary
                    _buildWeekSummary(),
                    // D28-02: Personal review
                    _buildPersonalReview(),
                    // D28-03: Educational quiz (5 questions)
                    MultiChoiceQuizPage(
                      title: 'آزمون آموزشی',
                      questions: const [
                        QuizQuestion(
                          question: 'هدف بازسازی شناختی چیست؟',
                          options: [
                            'تبدیل همه فکرها به افکار مثبت',
                            'حذف کامل افکار منفی',
                            'بررسی فکر با استفاده از اطلاعات و شواهد',
                            'نادیده\u200cگرفتن مشکل',
                          ],
                          correctAnswerIndex: 2,
                        ),
                        QuizQuestion(
                          question: 'کدام مورد شاهد محسوب می\u200cشود؟',
                          options: [
                            'احساس می\u200cکنم ناتوانم.',
                            'این فکر چند بار تکرار شده است.',
                            'دو بخش کار برای اصلاح بازگردانده شد.',
                            'فکر من بسیار واقعی به نظر می\u200cرسد.',
                          ],
                          correctAnswerIndex: 2,
                        ),
                        QuizQuestion(
                          question: 'فکر متعادل چه ویژگی\u200cای دارد؟',
                          options: [
                            'همیشه کاملاً مثبت است.',
                            'دشواری و اطلاعات تکمیلی را با هم در نظر می\u200cگیرد.',
                            'مشکل را انکار می\u200cکند.',
                            'فقط باعث آرامش می\u200cشود.',
                          ],
                          correctAnswerIndex: 1,
                        ),
                        QuizQuestion(
                          question:
                              'اگر پس از تمرین، باور به فکر اولیه کاهش پیدا نکند، چه نتیجه\u200cای می\u200cگیریم؟',
                          options: [
                            'تمرین قطعاً شکست خورده است.',
                            'فکر اولیه حتماً درست است.',
                            'ممکن است بررسی بیشتر یا تکرار تمرین لازم باشد.',
                            'باید یک فکر بسیار مثبت بنویسیم.',
                          ],
                          correctAnswerIndex: 2,
                        ),
                        QuizQuestion(
                          question: 'بررسی شواهد به چه معنا نیست؟',
                          options: [
                            'توجه به واقعیت\u200cهای قابل مشاهده',
                            'بررسی استثناها',
                            'نادیده\u200cگرفتن خطر واقعی',
                            'یافتن توضیح\u200cهای احتمالی دیگر',
                          ],
                          correctAnswerIndex: 2,
                        ),
                      ],
                      endMessage:
                          'این آزمون برای مرور مهارت است و نمره آن بیانگر وضعیت روان\u200cشناختی شما نیست.',
                      onCompleted: (score) {
                        context.read<Week4ViewModel>().submitExerciseResponse(
                          weekNumber: 4,
                          dayNumber: 28,
                          exerciseType: 'week_4_quiz',
                          data: {'score': score, 'total': 5},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D28-04: Week evaluation
                    WeekEvaluationPage(
                      onSubmit: (data) {
                        context.read<Week4ViewModel>().submitExerciseResponse(
                          weekNumber: 4,
                          dayNumber: 28,
                          exerciseType: 'week_4_evaluation',
                          data: data,
                        );
                        _goToPage(4);
                      },
                    ),
                    // D28-05: Week end
                    _buildWeekEnd(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- D28-01: Week summary ---
  Widget _buildWeekSummary() {
    final vm = context.read<Week4ViewModel>();
    final daysCompleted = vm.completedDaysCount;
    final thoughtExercises = vm.thoughtExercisesCount;
    final balancedCount = vm.balancedThoughtsCount;
    final beliefInitial = vm.lastBeliefInitial;
    final beliefAfter = vm.lastBeliefAfter;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خلاصه هفته چهارم',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          _buildStatCard(
            icon: Icons.check_circle_outline,
            iconColor: AppColors.success,
            label: 'روزهای تکمیل\u200cشده',
            value: '$daysCompleted از ۷',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.edit_note,
            iconColor: AppColors.info,
            label: 'تعداد تمرین\u200cهای بررسی فکر',
            value: '$thoughtExercises',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.balance,
            iconColor: AppColors.secondary,
            label: 'تعداد فکرهای متعادل ثبت\u200cشده',
            value: '$balancedCount',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.speed,
            iconColor: AppColors.warning,
            label: 'آخرین میزان باور اولیه',
            value: beliefInitial != null ? '$beliefInitial از ۱۰' : 'ثبت نشده',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.trending_flat,
            iconColor: AppColors.primary,
            label: 'آخرین میزان باور پس از بررسی',
            value: beliefAfter != null ? '$beliefAfter از ۱۰' : 'ثبت نشده',
          ),
          SizedBox(height: AppSizes.lg),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Text(
              'این تغییر فقط تجربه همان لحظه را نشان می\u200cدهد و نتیجه تشخیصی یا اثبات اثربخشی درمان نیست.',
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
              onPressed: () => _goToPage(1),
              child: const Text('مرور آموخته\u200cها'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  // --- D28-02: Personal review ---
  String? _easiestStep;
  String? _hardestStep;
  String? _helpfulQuestion;
  final _learningCtrl = TextEditingController();

  final _stepOptions = [
    'شناسایی فکر',
    'یافتن شواهد موافق',
    'یافتن شواهد مخالف',
    'یافتن توضیح جایگزین',
    'نوشتن فکر متعادل',
    'هیچ\u200cکدام',
    'مطمئن نیستم',
  ];

  final _questionOptions = [
    'چه شواهد واقعی وجود دارد؟',
    'آیا همیشه این اتفاق افتاده است؟',
    'چه اطلاعاتی نادیده گرفته شده است؟',
    'آیا توضیح دیگری ممکن است؟',
    'اگر فرد دیگری بود، چه می\u200cگفتم؟',
    'هیچ\u200cکدام',
    'مطمئن نیستم',
  ];

  bool _canSubmitReview() =>
      _easiestStep != null && _hardestStep != null && _helpfulQuestion != null;

  Widget _buildPersonalReview() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرور شخصی',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          _buildReviewQuestion(
            'کدام مرحله برای شما آسان\u200cتر بود؟',
            _stepOptions,
            _easiestStep,
            (v) => setState(() => _easiestStep = v),
          ),
          SizedBox(height: AppSizes.md),
          _buildReviewQuestion(
            'کدام مرحله دشوارتر بود؟',
            _stepOptions,
            _hardestStep,
            (v) => setState(() => _hardestStep = v),
          ),
          SizedBox(height: AppSizes.md),
          _buildReviewQuestion(
            'کدام سؤال بیشتر به شما کمک کرد؟',
            _questionOptions,
            _helpfulQuestion,
            (v) => setState(() => _helpfulQuestion = v),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'مهم\u200cترین چیزی که درباره افکار خود آموختید چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: _learningCtrl,
            maxLength: 200,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'پاسخ خود را بنویسید...',
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
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitReview() ? _submitReview : null,
              child: const Text('ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _submitReview() {
    context.read<Week4ViewModel>().submitExerciseResponse(
      weekNumber: 4,
      dayNumber: 28,
      exerciseType: 'week_4_review',
      data: {
        'easiest_restructuring_step': _easiestStep,
        'hardest_restructuring_step': _hardestStep,
        'most_helpful_question': _helpfulQuestion,
        'week_4_learning_text': _learningCtrl.text,
      },
    );
    _goToPage(2);
  }

  // --- D28-05: Week end ---
  Widget _buildWeekEnd() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Center(
            child: Text(
              'هفته چهارم به پایان رسید',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'در این هفته یاد گرفتید یک فکر خودکار را با استفاده از شواهد موافق، شواهد مخالف و توضیح\u200cهای جایگزین بررسی کنید و فکر متعادل\u200cتری بسازید.\n\nفکر متعادل، مشکل را انکار نمی\u200cکند؛ بلکه تلاش می\u200cکند تمام اطلاعات موجود را در نظر بگیرد.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'در هفته پنجم، ارتباط میان فعالیت\u200cهای روزانه، انرژی و خلق را بررسی خواهید کرد.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 22,
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'لازم نیست فکر متعادل همیشه باعث تغییر فوری هیجان شود. هدف، تمرین دیدن موقعیت از زاویه\u200cای کامل\u200cتر است.',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      height: 1.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<Week4ViewModel>().completeDay(
                  weekNumber: 4,
                  dayNumber: 28,
                );
                Navigator.of(context).pop();
              },
              child: const Text('پایان هفته چهارم'),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _goToPage(0),
              child: Text(
                'مرور دوباره خلاصه',
                style: PersianFonts.Vazir.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  // --- Shared helpers ---

  Widget _buildReviewQuestion(
    String question,
    List<String> options,
    String? selected,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.sm),
        ...options.map((opt) => _buildRadioOption(opt, selected, onChanged)),
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

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontXs,
                      color: AppColors.textHint,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
