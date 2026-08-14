import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/multi_choice_quiz_page.dart';
import '../../../week1_exercise/presentation/widgets/week_evaluation_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week3_view_model.dart';

class Day21Screen extends StatefulWidget {
  const Day21Screen({super.key});

  @override
  State<Day21Screen> createState() => _Day21ScreenState();
}

class _Day21ScreenState extends State<Day21Screen> {
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
                  dayNumber: 21,
                  dayTitle: 'مرور الگوهای فکری',
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
                    // D21-01: Week summary
                    _buildWeekSummary(),
                    // D21-02: Personal review
                    _buildPersonalReview(),
                    // D21-03: Educational quiz (5 questions)
                    MultiChoiceQuizPage(
                      title: 'آزمون آموزشی',
                      questions: const [
                        QuizQuestion(
                          question: 'فکر خودکار چیست؟',
                          options: [
                            'فکری که همیشه درست است.',
                            'جمله یا تصویری که سریع در پاسخ به موقعیت ظاهر می\u200cشود.',
                            'تصمیمی که پس از بررسی کامل گرفته می\u200cشود.',
                            'فقط یک فکر مثبت.',
                          ],
                          correctAnswerIndex: 1,
                        ),
                        QuizQuestion(
                          question:
                              '«اگر کامل نباشم، شکست خورده\u200cام» کدام الگوست؟',
                          options: [
                            'ذهن\u200cخوانی',
                            'همه یا هیچ',
                            'پیش\u200cبینی منفی',
                            'برچسب\u200cزدن',
                          ],
                          correctAnswerIndex: 1,
                        ),
                        QuizQuestion(
                          question:
                              '«مطمئنم همه فکر می\u200cکنند ناتوانم» کدام الگوست؟',
                          options: [
                            'ذهن\u200cخوانی',
                            'باید ذهنی',
                            'فاجعه\u200cسازی',
                            'هیچ\u200cکدام',
                          ],
                          correctAnswerIndex: 0,
                        ),
                        QuizQuestion(
                          question:
                              'شدت باور به یک فکر چه چیزی را نشان می\u200cدهد؟',
                          options: [
                            'حقیقت قطعی فکر',
                            'میزان واقعی\u200cبه\u200cنظررسیدن فکر برای فرد',
                            'تشخیص اختلال',
                            'شدت ضعف فرد',
                          ],
                          correctAnswerIndex: 1,
                        ),
                        QuizQuestion(
                          question: 'هدف هفته سوم چه بود؟',
                          options: [
                            'جایگزین\u200cکردن همه افکار منفی',
                            'حذف کامل افکار',
                            'شناسایی و ثبت افکار خودکار',
                            'اثبات نادرست\u200cبودن افکار',
                          ],
                          correctAnswerIndex: 2,
                        ),
                      ],
                      endMessage:
                          'هدف آزمون، مرور محتواست و نمره آن بیانگر وضعیت روان\u200cشناختی شما نیست.',
                      onCompleted: (score) {
                        context.read<Week3ViewModel>().submitExerciseResponse(
                          weekNumber: 3,
                          dayNumber: 21,
                          exerciseType: 'week_3_quiz',
                          data: {'score': score, 'total': 5},
                        );
                        _goToPage(3);
                      },
                    ),
                    // D21-04: Week evaluation
                    WeekEvaluationPage(
                      onSubmit: (data) {
                        context.read<Week3ViewModel>().submitExerciseResponse(
                          weekNumber: 3,
                          dayNumber: 21,
                          exerciseType: 'week_3_evaluation',
                          data: data,
                        );
                        _goToPage(4);
                      },
                    ),
                    // D21-05: Week end
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

  Widget _buildWeekSummary() {
    final vm = context.read<Week3ViewModel>();
    final daysCompleted = vm.completedDaysCount;
    final thoughtRecords = vm.thoughtRecordsCount;
    final lastBelief = vm.lastBeliefScore;
    final lastPattern = vm.lastThoughtPattern;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خلاصه هفته سوم',
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
            label: 'تعداد فکرهای ثبت\u200cشده',
            value: '$thoughtRecords',
            subtitle: thoughtRecords == 0
                ? 'هنوز فکر شخصی ثبت نشده است.'
                : null,
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.speed,
            iconColor: AppColors.secondary,
            label: 'آخرین میزان باور ثبت\u200cشده',
            value: lastBelief != null ? '$lastBelief از ۱۰' : 'داده کافی نیست',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.category_outlined,
            iconColor: AppColors.warning,
            label: 'الگوی فکری انتخاب\u200cشده در آخرین ثبت',
            value: lastPattern ?? 'ثبت نشده',
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
              'این اطلاعات برای خودپایشی هستند و نتیجه تشخیصی محسوب نمی\u200cشوند.',
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

  // Personal review state
  String? _familiarPattern;
  String? _difficultComponent;
  String? _commonContext;
  final _learningCtrl = TextEditingController();

  final _patternOptions = [
    'همه یا هیچ',
    'برچسب\u200cزدن',
    'پیش\u200cبینی منفی',
    'فاجعه\u200cسازی',
    'ذهن\u200cخوانی',
    'بایدهای ذهنی',
    'هیچ\u200cکدام',
    'مطمئن نیستم',
  ];

  final _componentOptions = [
    'موقعیت',
    'فکر',
    'هیجان',
    'میزان باور',
    'تشخیص الگوی فکری',
    'هیچ\u200cکدام',
    'مطمئن نیستم',
  ];

  final _contextOptions = [
    'فشار زمانی',
    'ارزیابی عملکرد',
    'ارتباط با دیگران',
    'ابهام یا انتظار',
    'خستگی',
    'موضوع خانوادگی',
    'موقعیت دیگر',
    'الگوی مشخصی ندیدم',
  ];

  bool _canSubmitReview() =>
      _familiarPattern != null &&
      _difficultComponent != null &&
      _commonContext != null;

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
            'کدام الگوی فکری برای شما آشناتر بود؟',
            _patternOptions,
            _familiarPattern,
            (v) => setState(() => _familiarPattern = v),
          ),
          SizedBox(height: AppSizes.md),
          _buildReviewQuestion(
            'شناسایی کدام بخش برای شما دشوارتر بود؟',
            _componentOptions,
            _difficultComponent,
            (v) => setState(() => _difficultComponent = v),
          ),
          SizedBox(height: AppSizes.md),
          _buildReviewQuestion(
            'فکرهای خودکار بیشتر در چه نوع موقعیتی ظاهر می\u200cشوند؟',
            _contextOptions,
            _commonContext,
            (v) => setState(() => _commonContext = v),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'مهم\u200cترین چیزی که این هفته درباره افکار خود آموختید چیست؟',
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
    context.read<Week3ViewModel>().submitExerciseResponse(
      weekNumber: 3,
      dayNumber: 21,
      exerciseType: 'week_3_review',
      data: {
        'familiar_pattern': _familiarPattern,
        'difficult_component': _difficultComponent,
        'common_context': _commonContext,
        'learning_text': _learningCtrl.text,
      },
    );
    _goToPage(2);
  }

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
              'هفته سوم به پایان رسید',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'در این هفته یاد گرفتید افکار خودکار را از موقعیت و هیجان تفکیک کنید و چند الگوی فکری رایج را بشناسید.\n\nهدف این هفته تغییر فوری افکار نبود؛ هدف این بود که آن\u200cها را واضح\u200cتر مشاهده و ثبت کنید.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'در هفته چهارم، یاد می\u200cگیرید شواهد مربوط به یک فکر را بررسی و فکر متعادل\u200cتری ایجاد کنید.',
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
                    'قوی یا تکرارشونده\u200cبودن یک فکر، لزوماً به معنای درست\u200cبودن آن نیست.',
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
                context.read<Week3ViewModel>().completeDay(
                  weekNumber: 3,
                  dayNumber: 21,
                );
                Navigator.of(context).pop();
              },
              child: const Text('پایان هفته سوم'),
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
