import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/multi_choice_quiz_page.dart';
import '../../../week1_exercise/presentation/widgets/week_evaluation_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week6_view_model.dart';

class Day42Screen extends StatefulWidget {
  const Day42Screen({super.key});

  @override
  State<Day42Screen> createState() => _Day42ScreenState();
}

class _Day42ScreenState extends State<Day42Screen> {
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
                  dayNumber: 42,
                  dayTitle: 'مرور هفته ششم',
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
                    // D42-01: Week summary
                    Consumer<Week6ViewModel>(
                      builder: (context, vm, _) => _buildWeekSummary(vm),
                    ),
                    // D42-02: Personal review
                    _buildPersonalReview(),
                    // D42-03: Educational quiz
                    MultiChoiceQuizPage(
                      title: 'آزمون آموزشی',
                      questions: const [
                        QuizQuestion(
                          question: 'مشاهده فکر به چه معناست؟',
                          options: [
                            'اثبات نادرست\u200cبودن فکر',
                            'حذف\u200cکردن فکر',
                            'تشخیص فکر به\u200cعنوان یک رویداد ذهنی',
                            'جایگزین\u200cکردن فوری فکر مثبت',
                          ],
                          correctAnswerIndex: 2,
                          feedbackCorrect:
                              'صحیح! مشاهده فکر یعنی تشخیص فکر به\u200cعنوان یک رویداد ذهنی.',
                        ),
                        QuizQuestion(
                          question:
                              'کدام جمله فاصله بیشتری از فکر ایجاد می\u200cکند؟',
                          options: [
                            'من قطعاً شکست می\u200cخورم.',
                            'نباید این فکر را داشته باشم.',
                            'متوجه می\u200cشوم که این فکر را دارم که ممکن است شکست بخورم.',
                            'این فکر هیچ اهمیتی ندارد.',
                          ],
                          correctAnswerIndex: 2,
                          feedbackCorrect:
                              'صحیح! عبارت «متوجه می\u200cشوم که...» فاصله بیشتری ایجاد می\u200cکند.',
                        ),
                        QuizQuestion(
                          question: 'پذیرش هیجان به چه معناست؟',
                          options: [
                            'دوست\u200cداشتن هیجان',
                            'تسلیم\u200cشدن',
                            'تشخیص وجود هیجان بدون تلاش فوری برای سرکوب آن',
                            'تأیید تمام رفتارهای ناشی از هیجان',
                          ],
                          correctAnswerIndex: 2,
                          feedbackCorrect:
                              'صحیح! پذیرش یعنی تشخیص وجود هیجان بدون تلاش فوری برای سرکوب.',
                        ),
                        QuizQuestion(
                          question: 'میل به عمل چه تفاوتی با رفتار دارد؟',
                          options: [
                            'تفاوتی ندارند.',
                            'میل یک گرایش اولیه است و رفتار می\u200cتواند انتخاب شود.',
                            'هر میل باید اجرا شود.',
                            'میل همیشه غیرمنطقی است.',
                          ],
                          correctAnswerIndex: 1,
                          feedbackCorrect:
                              'صحیح! میل یک گرایش اولیه است و رفتار قابل انتخاب است.',
                        ),
                        QuizQuestion(
                          question:
                              'اگر تمرین باعث ناراحتی شدید شد، چه کاری مناسب\u200cتر است؟',
                          options: [
                            'ادامه با فشار بیشتر',
                            'نادیده\u200cگرفتن ناراحتی',
                            'توقف، بازگشت به محیط و استفاده از راهنما در صورت نیاز',
                            'انتخاب تجربه شدیدتر',
                          ],
                          correctAnswerIndex: 2,
                          feedbackCorrect:
                              'صحیح! توقف و بازگشت به محیط مناسب\u200cترین کار است.',
                        ),
                      ],
                      onCompleted: (score) {
                        context.read<Week6ViewModel>().submitExerciseResponse(
                          weekNumber: 6,
                          dayNumber: 42,
                          exerciseType: 'week_6_quiz',
                          data: {'week_6_quiz_score': score},
                        );
                        _goToPage(3);
                      },
                      endMessage:
                          'آزمون برای مرور محتواست و نمره آن وضعیت روان\u200cشناختی شما را نشان نمی\u200cدهد.',
                      buttonText: 'ادامه',
                    ),
                    // D42-04: Week evaluation
                    WeekEvaluationPage(
                      onSubmit: (data) {
                        context.read<Week6ViewModel>().submitExerciseResponse(
                          weekNumber: 6,
                          dayNumber: 42,
                          exerciseType: 'week_6_evaluation',
                          data: {
                            'week_6_clarity_score': data['clarity_score'],
                            'observation_acceptance_usability':
                                data['usefulness_score'],
                            'week_6_audio_duration': data['duration_rating'],
                            'week_6_significant_distress':
                                data['significant_distress'],
                          },
                        );
                        _goToPage(4);
                      },
                      onHelpNeeded: () {
                        // Navigate to help section
                      },
                    ),
                    // D42-05: Week end
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

  // D42-02: Personal review form state
  String? _preferredExercise;
  String? _hardestStep;
  String? _acceptanceDefinition;
  final _learningCtrl = TextEditingController();

  final _exerciseOptions = [
    'نام\u200cگذاری فکر',
    'مشاهده صوتی افکار',
    'عبارت «متوجه می\u200cشوم که...»',
    'نام\u200cگذاری هیجان',
    'پذیرش هیجان',
    'مکث و انتخاب پاسخ',
    'هیچ\u200cکدام',
    'مطمئن نیستم',
  ];

  final _hardestOptions = [
    'تشخیص هیجان',
    'احساس\u200cکردن آن در بدن',
    'مشاهده بدون سرکوب',
    'مشاهده میل به عمل',
    'مکث پیش از رفتار',
    'انتخاب پاسخ',
    'مطمئن نیستم',
  ];

  final _definitionOptions = [
    'تشخیص وجود هیجان بدون واکنش فوری',
    'موافقت با همه فکرها',
    'تسلیم\u200cشدن',
    'نادیده\u200cگرفتن مشکل',
    'هنوز مطمئن نیستم',
  ];

  bool get _canSubmitReview =>
      _preferredExercise != null &&
      _hardestStep != null &&
      _acceptanceDefinition != null;

  Widget _buildWeekSummary(Week6ViewModel vm) {
    final completedDays = vm.completedDaysCount;
    final audioCount = vm.audioExercisesCompleted;
    final emotionCount = vm.registeredEmotionsCount;
    final pauseCount = vm.pauseExercisesCount;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خلاصه هفته ششم',
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
            value: '$completedDays از ۷',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.headphones,
            iconColor: AppColors.info,
            label:
                'تمرین\u200cهای صوتی انجام\u200cشده یا نیمه\u200cانجام\u200cشده',
            value: '$audioCount از ۳',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.favorite_outline,
            iconColor: AppColors.secondary,
            label: 'تعداد هیجان\u200cهای ثبت\u200cشده',
            value: '$emotionCount',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            icon: Icons.pause_circle_outline,
            iconColor: AppColors.primary,
            label: 'تعداد تمرین\u200cهای مکث و انتخاب',
            value: '$pauseCount',
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
              'این اطلاعات فقط میزان استفاده شما از تمرین\u200cها را نشان می\u200cدهند و نتیجه تشخیصی نیستند.',
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
          SizedBox(height: AppSizes.md),
          // Q1: Preferred exercise
          Text(
            'کدام تمرین برای شما کاربردی\u200cتر بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._exerciseOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _preferredExercise,
              (v) => setState(() => _preferredExercise = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2: Hardest step
          Text(
            'هنگام هیجان، کدام بخش دشوارتر بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._hardestOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _hardestStep,
              (v) => setState(() => _hardestStep = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3: Acceptance definition
          Text(
            'پذیرش اکنون برای شما بیشتر به چه معناست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._definitionOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _acceptanceDefinition,
              (v) => setState(() => _acceptanceDefinition = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4: Most important learning
          Text(
            'مهم\u200cترین چیزی که این هفته آموختید چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'حداکثر ۲۰۰ کاراکتر',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: _learningCtrl,
            maxLength: 200,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'آموخته خود را بنویسید...',
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
              onPressed: _canSubmitReview ? _submitReview : null,
              child: const Text('ثبت و ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildWeekEnd() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هفته ششم به پایان رسید',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'در این هفته تمرین کردید افکار را به\u200cعنوان رویدادهای ذهنی مشاهده کنید، هیجان\u200cها را نام\u200cگذاری کنید و پیش از واکنش فوری، مکث کوتاهی ایجاد کنید.\n\nپذیرش به معنای تأیید همه فکرها یا کنارگذاشتن اقدام نیست. پذیرش کمک می\u200cکند تجربه موجود را واضح\u200cتر ببینید و سپس پاسخ خود را انتخاب کنید.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.8,
              color: AppColors.textPrimary,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'یادآوری',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  'هدف این تمرین\u200cها حذف افکار و هیجان\u200cها نیست؛ هدف، افزایش انعطاف در نحوه پاسخ\u200cدادن به آن\u200cهاست.',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    height: 1.7,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.md),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              'در هفته هفتم، حل مسئله گام\u200cبه\u200cگام و ارتباط قاطعانه را تمرین خواهید کرد.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.info,
              ),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<Week6ViewModel>().completeDay(
                  weekNumber: 6,
                  dayNumber: 42,
                );
                Navigator.of(context).pop();
              },
              child: const Text('پایان هفته ششم'),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _goToPage(0),
              child: Text(
                'مرور دوباره خلاصه',
                style: PersianFonts.Vazir.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
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

  void _submitReview() {
    context.read<Week6ViewModel>().submitExerciseResponse(
      weekNumber: 6,
      dayNumber: 42,
      exerciseType: 'week_6_review',
      data: {
        'preferred_week6_exercise': _preferredExercise,
        'hardest_acceptance_step': _hardestStep,
        'acceptance_definition_selected': _acceptanceDefinition,
        'week_6_learning_text': _learningCtrl.text.trim().isNotEmpty
            ? _learningCtrl.text.trim()
            : null,
      },
    );
    _goToPage(2);
  }
}
