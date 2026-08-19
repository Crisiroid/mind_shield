import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/multi_choice_quiz_page.dart';
import '../../../week1_exercise/presentation/widgets/week_evaluation_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week2_view_model.dart';

class Day14Screen extends StatefulWidget {
  const Day14Screen({super.key});

  @override
  State<Day14Screen> createState() => _Day14ScreenState();
}

class _Day14ScreenState extends State<Day14Screen> {
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
                  dayNumber: 14,
                  dayTitle: 'مرور هفته دوم',
                  currentStep: _currentPage,
                  totalSteps: _totalSteps,
                ),
              ),
              Expanded(
                child: Consumer<Week2ViewModel>(
                  builder: (context, vm, _) {
                    return PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) =>
                          setState(() => _currentPage = page),
                      children: [
                        // D14-01: Week summary
                        _D14WeekSummary(vm: vm, onContinue: () => _goToPage(1)),
                        // D14-02: Personal review
                        _D14PersonalReview(
                          onSubmit: (data) {
                            vm.submitExerciseResponse(
                              weekNumber: 2,
                              dayNumber: 14,
                              exerciseType: 'week_2_review',
                              data: data,
                            );
                            _goToPage(2);
                          },
                        ),
                        // D14-03: Quiz (5 questions)
                        MultiChoiceQuizPage(
                          title: 'آزمون آموزشی',
                          questions: const [
                            QuizQuestion(
                              question: 'هدف اصلی اسکن بدن چیست؟',
                              options: [
                                'پیدا کردن بیماری جسمانی',
                                'آرام\u200cکردن اجباری بدن',
                                'مشاهده نظام\u200cمند احساسات بخش\u200cهای مختلف بدن',
                                'حذف کامل تنش',
                              ],
                              correctAnswerIndex: 2,
                            ),
                            QuizQuestion(
                              question:
                                  'در تنفس آگاهانه چه کاری انجام می\u200cدهیم؟',
                              options: [
                                'نفس را تا حد ممکن عمیق می\u200cکنیم.',
                                'تنفس طبیعی را مشاهده می\u200cکنیم.',
                                'نفس را برای چند ثانیه نگه می\u200cداریم.',
                                'تلاش می\u200cکنیم هیچ فکری نداشته باشیم.',
                              ],
                              correctAnswerIndex: 1,
                            ),
                            QuizQuestion(
                              question:
                                  'اگر هنگام تمرین حواس پرت شود، پاسخ مناسب چیست؟',
                              options: [
                                'خود را سرزنش کنیم.',
                                'تمرین را متوقف و شکست\u200cخورده بدانیم.',
                                'متوجه شویم و توجه را بازگردانیم.',
                                'با افکار مبارزه کنیم.',
                              ],
                              correctAnswerIndex: 2,
                            ),
                            QuizQuestion(
                              question:
                                  'اگر تمرکز بر تنفس باعث سرگیجه یا ناراحتی شد، چه کاری مناسب\u200cتر است؟',
                              options: [
                                'تمرین را با فشار بیشتری ادامه دهیم.',
                                'تنفس را سریع\u200cتر کنیم.',
                                'تمرین را متوقف و به تنفس طبیعی و محیط بازگردیم.',
                                'نفس را نگه داریم.',
                              ],
                              correctAnswerIndex: 2,
                            ),
                            QuizQuestion(
                              question: 'ذهن\u200cآگاهی به معنای چیست؟',
                              options: [
                                'حذف همه احساس\u200cهای ناخوشایند',
                                'توجه هدفمند و غیرقضاوتی به تجربه لحظه حال',
                                'نادیده\u200cگرفتن مشکلات',
                                'رسیدن قطعی و فوری به آرامش',
                              ],
                              correctAnswerIndex: 1,
                            ),
                          ],
                          endMessage:
                              'این آزمون فقط برای مرور محتواست و نتیجه آن بیانگر وضعیت روان\u200cشناختی شما نیست.',
                          onCompleted: (score) {
                            vm.submitExerciseResponse(
                              weekNumber: 2,
                              dayNumber: 14,
                              exerciseType: 'week_2_quiz',
                              data: {'score': score, 'total': 5},
                            );
                            _goToPage(3);
                          },
                        ),
                        // D14-04: Week evaluation
                        WeekEvaluationPage(
                          onSubmit: (data) {
                            vm.submitExerciseResponse(
                              weekNumber: 2,
                              dayNumber: 14,
                              exerciseType: 'week_2_evaluation',
                              data: {
                                'week_2_clarity_score': data['clarity_score'],
                                'audio_usability_score':
                                    data['usefulness_score'],
                                'audio_duration_rating':
                                    data['duration_rating'],
                                'mindfulness_significant_distress':
                                    data['significant_distress'],
                              },
                            );
                            _goToPage(4);
                          },
                          questionTwoText:
                              'تمرین\u200cهای صوتی چقدر قابل استفاده بودند؟',
                          onHelpNeeded: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusLg,
                                  ),
                                ),
                                title: Text(
                                  'راهنما و کمک',
                                  style: PersianFonts.Vazir.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'انجام تمرین\u200cهای صوتی الزامی نیست. در صورت نیاز از بخش «راهنما و کمک» استفاده کنید.',
                                  style: PersianFonts.Vazir.copyWith(
                                    height: 1.7,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      'بستن',
                                      style: PersianFonts.Vazir.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // D14-05: Week end
                        _D14WeekEnd(
                          onFinish: () {
                            vm.completeDay(weekNumber: 2, dayNumber: 14);
                            Navigator.of(context).pop();
                          },
                          onReviewSummary: () => _goToPage(0),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// D14-01: Week summary
class _D14WeekSummary extends StatelessWidget {
  final Week2ViewModel vm;
  final VoidCallback onContinue;

  const _D14WeekSummary({required this.vm, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final daysCompleted = vm.completedDaysCount;
    final audioCompleted = vm.audioExercisesCompleted;
    final lastTension = vm.lastTensionScore;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خلاصه هفته دوم',
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
            icon: Icons.headphones,
            iconColor: AppColors.info,
            label:
                'تمرین\u200cهای صوتی انجام\u200cشده یا نیمه\u200cانجام\u200cشده',
            value: '$audioCompleted از ۵',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.speed,
            iconColor: AppColors.secondary,
            label: 'آخرین نمره تنش ثبت\u200cشده',
            value: lastTension != null ? '$lastTension از ۱۰' : 'ثبت نشده',
            subtitle: lastTension != null
                ? null
                : 'نمره\u200cای برای آخرین تمرین تنفس ثبت نشده است.',
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
              'این اطلاعات فقط برای مرور تجربه شما هستند و نتیجه تشخیصی محسوب نمی\u200cشوند.',
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
              onPressed: onContinue,
              child: const Text('مرور هفته'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
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

// D14-02: Personal review with 4 questions
class _D14PersonalReview extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;
  const _D14PersonalReview({required this.onSubmit});

  @override
  State<_D14PersonalReview> createState() => _D14PersonalReviewState();
}

class _D14PersonalReviewState extends State<_D14PersonalReview> {
  final _learningCtrl = TextEditingController();
  String? _earlyBodyArea;
  String? _preferredExercise;
  String? _preferredTime;

  final _bodyAreas = [
    'سر و صورت',
    'گردن و شانه',
    'قفسه سینه',
    'شکم',
    'دست\u200cها یا پاها',
    'کل بدن',
    'ناحیه مشخصی شناسایی نکردم',
  ];

  final _exercises = [
    'توقف یک\u200cدقیقه\u200cای بدن',
    'اسکن بدن',
    'مشاهده تنفس',
    'تمرین سه\u200cدقیقه\u200cای',
    'تنفس در موقعیت روزمره',
    'هیچ\u200cکدام',
    'مطمئن نیستم',
  ];

  final _times = [
    'آغاز روز',
    'میان کار',
    'زمان استراحت',
    'پس از پایان کار',
    'پیش از خواب',
    'زمان ثابتی پیدا نکردم',
  ];

  bool get _canSubmit =>
      _earlyBodyArea != null &&
      _preferredExercise != null &&
      _preferredTime != null;

  @override
  void dispose() {
    _learningCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // Q1
          Text(
            'کدام ناحیه بدن معمولاً زودتر توجه شما را جلب می\u200cکند؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._bodyAreas.map(
            (opt) => _buildRadio(
              opt,
              _earlyBodyArea,
              (v) => setState(() => _earlyBodyArea = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2
          Text(
            'کدام تمرین برای شما قابل استفاده\u200cتر بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._exercises.map(
            (opt) => _buildRadio(
              opt,
              _preferredExercise,
              (v) => setState(() => _preferredExercise = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3
          Text(
            'مناسب\u200cترین زمان برای تمرین شما چه زمانی بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._times.map(
            (opt) => _buildRadio(
              opt,
              _preferredTime,
              (v) => setState(() => _preferredTime = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4
          Text(
            'مهم\u200cترین چیزی که این هفته آموختید چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          TextField(
            controller: _learningCtrl,
            maxLength: 200,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'پاسخ خود را بنویسید...',
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
              onPressed: _canSubmit
                  ? () => widget.onSubmit({
                      'early_body_area': _earlyBodyArea,
                      'preferred_mindfulness_exercise': _preferredExercise,
                      'preferred_practice_time': _preferredTime,
                      'week_2_learning_text': _learningCtrl.text,
                    })
                  : null,
              child: const Text('ثبت مرور'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildRadio(
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

// D14-05: Week end
class _D14WeekEnd extends StatelessWidget {
  final VoidCallback onFinish;
  final VoidCallback? onReviewSummary;

  const _D14WeekEnd({required this.onFinish, this.onReviewSummary});

  @override
  Widget build(BuildContext context) {
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
              'هفته دوم به پایان رسید',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'در این هفته، توجه به احساسات بدنی و جریان طبیعی تنفس را تمرین کردید.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'هدف این تمرین\u200cها حذف فوری تنش نبود؛ هدف آن بود که تجربه بدن و تنفس را زودتر، دقیق\u200cتر و بدون قضاوت فوری مشاهده کنید.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'در هفته سوم، افکار خودکار و الگوهای فکری تکرارشونده را شناسایی خواهید کرد.',
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
                Icon(Icons.headphones, color: AppColors.primary, size: 22),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'می\u200cتوانید تمرین صوتی مورد علاقه خود را از بخش «ثبت\u200cهای من» دوباره پخش کنید.',
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
              onPressed: onFinish,
              child: const Text('پایان هفته دوم'),
            ),
          ),
          if (onReviewSummary != null) ...[
            SizedBox(height: AppSizes.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onReviewSummary,
                child: Text(
                  'مرور دوباره خلاصه',
                  style: PersianFonts.Vazir.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}
