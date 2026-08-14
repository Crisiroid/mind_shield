import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/multi_choice_quiz_page.dart';
import '../../../week1_exercise/presentation/widgets/week_evaluation_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week5_view_model.dart';

class Day35Screen extends StatefulWidget {
  const Day35Screen({super.key});

  @override
  State<Day35Screen> createState() => _Day35ScreenState();
}

class _Day35ScreenState extends State<Day35Screen> {
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
                  dayNumber: 35,
                  dayTitle: 'برنامه شخصی فعالیت',
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
                    // D35-01: Week summary
                    _buildWeekSummary(),
                    // D35-02: Life values & meaningful activity
                    _buildLifeValuesForm(),
                    // D35-03: Continuation plan
                    _buildContinuationPlan(),
                    // D35-04: Quiz + evaluation
                    _buildQuizAndEvaluation(),
                    // D35-05: Week end
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

  // --- D35-01: Week summary ---
  Widget _buildWeekSummary() {
    final vm = context.read<Week5ViewModel>();
    final daysCompleted = vm.completedDaysCount;
    final plannedCount = vm.plannedActivitiesCount;
    final completedCount = vm.completedActivitiesCount;
    final pleasure = vm.lastPleasureRating;
    final accomplishment = vm.lastAccomplishmentRating;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خلاصه هفته پنجم',
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
            icon: Icons.event_note,
            iconColor: AppColors.info,
            label: 'فعالیت\u200cهای برنامه\u200cریزی\u200cشده',
            value: '$plannedCount',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.check_circle,
            iconColor: AppColors.primary,
            label: 'فعالیت\u200cهای انجام\u200cشده یا نیمه\u200cانجام\u200cشده',
            value: '$completedCount',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.favorite_border,
            iconColor: AppColors.secondary,
            label: 'آخرین نمره لذت',
            value: pleasure != null ? '$pleasure از ۱۰' : 'ثبت نشده',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.trending_up,
            iconColor: AppColors.warning,
            label: 'آخرین نمره احساس پیشرفت',
            value: accomplishment != null
                ? '$accomplishment از ۱۰'
                : 'ثبت نشده',
          ),
          SizedBox(height: AppSizes.lg),
          if (plannedCount == 0)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Text(
                'هنوز فعالیتی برای نمایش در خلاصه ثبت نشده است.',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Text(
              'این نمره\u200cها فقط تجربه فعالیت\u200cهای ثبت\u200cشده را نشان می\u200cدهند و نتیجه تشخیصی نیستند.',
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
              child: const Text('مرور هفته'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  // --- D35-02: Life values & meaningful activity ---
  final Set<String> _selectedLifeAreas = {};
  final _meaningfulActivityCtrl = TextEditingController();

  final _lifeAreaOptions = [
    'خانواده',
    'دوستی و ارتباط',
    'سلامت',
    'یادگیری و رشد',
    'مسئولیت\u200cپذیری',
    'معنویت',
    'کمک به دیگران',
    'تفریح و استراحت',
    'نظم شخصی',
    'پیشرفت شغلی',
    'حوزه دیگر',
    'ترجیح می\u200cدهم پاسخ ندهم.',
  ];

  bool get _canSubmitLifeValues =>
      _selectedLifeAreas.isNotEmpty && _meaningfulActivityCtrl.text.isNotEmpty;

  Widget _buildLifeValuesForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'کدام بخش زندگی برای شما مهم است؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'فعالیت\u200cهایی که فقط بر اساس فشار یا اجبار انتخاب می\u200cشوند، ممکن است در بلندمدت پایدار نباشند. ارتباط فعالیت با موضوعات مهم زندگی می\u200cتواند به معنا و ادامه\u200cپذیری آن کمک کند.\n\nموضوع مهم، چیزی است که برای شما ارزش یا اهمیت شخصی دارد؛ نه چیزی که دیگران الزاماً انتظار دارند.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'کدام حوزه\u200cها برای شما مهم\u200cترند؟ (حداکثر سه انتخاب)',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._lifeAreaOptions.map((item) {
            final isSelected = _selectedLifeAreas.contains(item);
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.xs),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedLifeAreas.remove(item);
                      } else if (_selectedLifeAreas.length < 3) {
                        _selectedLifeAreas.add(item);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Container(
                    padding: EdgeInsets.all(AppSizes.md),
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
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: null,
                            activeColor: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            item,
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
          Text(
            'یک فعالیت کوچک مرتبط با یکی از این حوزه\u200cها چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: _meaningfulActivityCtrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText:
                  'مثال: ده دقیقه صحبت با خانواده، پنج دقیقه مطالعه یا آماده\u200cکردن یک غذای ساده.',
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
              onPressed: _canSubmitLifeValues ? _submitLifeValues : null,
              child: const Text('ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _submitLifeValues() {
    context.read<Week5ViewModel>().submitExerciseResponse(
      weekNumber: 5,
      dayNumber: 35,
      exerciseType: 'meaningful_activity',
      data: {
        'important_life_areas': _selectedLifeAreas.toList(),
        'meaningful_small_activity': _meaningfulActivityCtrl.text,
      },
    );
    _goToPage(2);
  }

  // --- D35-03: Continuation plan ---
  String? _continuationActivity;
  String? _continuationFrequency;
  String? _continuationTime;
  final _continuationMinCtrl = TextEditingController();

  final _frequencyOptions = [
    'یک بار',
    'دو بار',
    'سه بار',
    'بیشتر',
    'هنوز مطمئن نیستم',
  ];

  final _timeOptions = [
    'آغاز روز',
    'هنگام استراحت',
    'پس از پایان کار',
    'عصر',
    'پیش از خواب',
    'زمان دیگر',
  ];

  bool get _canSubmitContinuation =>
      _continuationActivity != null &&
      _continuationFrequency != null &&
      _continuationTime != null;

  Widget _buildContinuationPlan() {
    final vm = context.read<Week5ViewModel>();
    final activities = vm.selectedActivities;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'برنامه کوچک هفته آینده',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q1: Which activity to continue?
          _buildLabel('کدام فعالیت این هفته برای ادامه مناسب\u200cتر است؟'),
          if (activities.isNotEmpty) ...[
            ...activities.map(
              (act) => _buildRadioOption(
                act,
                _continuationActivity,
                (v) => setState(() => _continuationActivity = v),
              ),
            ),
          ],
          _buildRadioOption(
            'فعالیت جدید',
            _continuationActivity,
            (v) => setState(() => _continuationActivity = v),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2: How many times?
          _buildLabel('چند بار می\u200cخواهید آن را انجام دهید؟'),
          ..._frequencyOptions.map(
            (opt) => _buildRadioOption(
              opt,
              _continuationFrequency,
              (v) => setState(() => _continuationFrequency = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3: Best time?
          _buildLabel('مناسب\u200cترین زمان چیست؟'),
          ..._timeOptions.map(
            (opt) => _buildRadioOption(
              opt,
              _continuationTime,
              (v) => setState(() => _continuationTime = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4: Minimum version
          _buildLabel('اگر برنامه دشوار شد، نسخه کوچک\u200cتر آن چیست؟'),
          TextField(
            controller: _continuationMinCtrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'نسخه کوچک\u200cتر را بنویسید...',
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
              onPressed: _canSubmitContinuation ? _submitContinuation : null,
              child: const Text('ثبت برنامه ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _submitContinuation() {
    context.read<Week5ViewModel>().submitExerciseResponse(
      weekNumber: 5,
      dayNumber: 35,
      exerciseType: 'activity_continuation_plan',
      data: {
        'continuation_activity': _continuationActivity,
        'continuation_frequency': _continuationFrequency,
        'continuation_time': _continuationTime,
        'continuation_minimum_version': _continuationMinCtrl.text,
      },
    );
    _goToPage(3);
  }

  // --- D35-04: Quiz + Evaluation ---
  bool _showEvaluation = false;

  Widget _buildQuizAndEvaluation() {
    if (_showEvaluation) {
      return WeekEvaluationPage(
        onSubmit: (data) {
          context.read<Week5ViewModel>().submitExerciseResponse(
            weekNumber: 5,
            dayNumber: 35,
            exerciseType: 'week_5_evaluation',
            data: data,
          );
          _goToPage(4);
        },
      );
    }

    return MultiChoiceQuizPage(
      title: 'آزمون آموزشی',
      questions: const [
        QuizQuestion(
          question: 'فعال\u200cسازی رفتاری به چه معناست؟',
          options: [
            'پرکردن تمام وقت با کار',
            'انجام تدریجی فعالیت\u200cهای مثبت و قابل اجرا',
            'منتظرماندن برای انگیزه کامل',
            'نادیده\u200cگرفتن خستگی',
          ],
          correctAnswerIndex: 1,
        ),
        QuizQuestion(
          question: 'اگر یک فعالیت انجام نشد، چه کاری مناسب\u200cتر است؟',
          options: [
            'خود را سرزنش کنیم.',
            'برنامه را کاملاً کنار بگذاریم.',
            'مانع را بررسی و فعالیت را کوچک\u200cتر کنیم.',
            'فعالیت بسیار دشوارتری انتخاب کنیم.',
          ],
          correctAnswerIndex: 2,
        ),
        QuizQuestion(
          question: 'کدام جمله درست\u200cتر است؟',
          options: [
            'همه فعالیت\u200cهای مفید باید لذت زیادی ایجاد کنند.',
            'بعضی فعالیت\u200cها لذت و بعضی احساس پیشرفت ایجاد می\u200cکنند.',
            'اگر خلق بهتر نشد، فعالیت بی\u200cفایده بوده است.',
            'فعالیت فقط زمانی انجام می\u200cشود که انگیزه وجود داشته باشد.',
          ],
          correctAnswerIndex: 1,
        ),
        QuizQuestion(
          question: 'یک برنامه روشن چه ویژگی\u200cای دارد؟',
          options: [
            'فقط هدف کلی دارد.',
            'زمان، فعالیت و اندازه تقریبی آن مشخص است.',
            'بسیار بزرگ و چالش\u200cبرانگیز است.',
            'امکان تغییر ندارد.',
          ],
          correctAnswerIndex: 1,
        ),
      ],
      endMessage:
          'این آزمون برای مرور آموزش است و نمره آن بیانگر وضعیت روان\u200cشناختی شما نیست.',
      onCompleted: (score) {
        context.read<Week5ViewModel>().submitExerciseResponse(
          weekNumber: 5,
          dayNumber: 35,
          exerciseType: 'week_5_quiz',
          data: {'score': score, 'total': 4},
        );
        setState(() => _showEvaluation = true);
      },
    );
  }

  // --- D35-05: Week end ---
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
              'هفته پنجم به پایان رسید',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'در این هفته، رابطه میان فعالیت، انرژی و خلق را بررسی کردید. یاد گرفتید فعالیت\u200cهای کوچک را انتخاب و برنامه\u200cریزی کنید، تجربه لذت و احساس پیشرفت را ثبت کنید و در صورت ایجاد مانع، قدم را کوچک\u200cتر سازید.\n\nهدف فعال\u200cسازی رفتاری، مجبورکردن خود به فعالیت زیاد نیست؛ هدف، بازگرداندن تدریجی فعالیت\u200cهای مثبت، مفید و معنادار به زندگی روزمره است.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'در هفته ششم، مشاهده افکار و پذیرش هیجان\u200cها را تمرین خواهید کرد.',
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
                    'نتیجه فعالیت\u200cها همیشه فوری یا یکسان نیست. اهمیت اصلی در مشاهده، آزمایش و تنظیم برنامه بر اساس تجربه واقعی شماست.',
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
                context.read<Week5ViewModel>().completeDay(
                  weekNumber: 5,
                  dayNumber: 35,
                );
                Navigator.of(context).pop();
              },
              child: const Text('پایان هفته پنجم'),
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

  // --- Helpers ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.xs),
      child: Text(
        text,
        style: PersianFonts.Vazir.copyWith(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
