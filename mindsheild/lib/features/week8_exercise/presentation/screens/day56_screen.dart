import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/multi_choice_quiz_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week8_view_model.dart';

class Day56Screen extends StatefulWidget {
  const Day56Screen({super.key});

  @override
  State<Day56Screen> createState() => _Day56ScreenState();
}

class _Day56ScreenState extends State<Day56Screen> {
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
                  dayNumber: 56,
                  dayTitle: 'برنامه ادامه مسیر',
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
                    // D56-01: 8-week summary
                    Consumer<Week8ViewModel>(
                      builder: (context, vm, _) => _buildWeekSummary(vm),
                    ),
                    // D56-02: Personal plan card
                    Consumer<Week8ViewModel>(
                      builder: (context, vm, _) => _buildPersonalPlanCard(vm),
                    ),
                    // D56-03: Course review quiz
                    MultiChoiceQuizPage(
                      title: 'آزمون مرور دوره',
                      questions: const [
                        QuizQuestion(
                          question:
                              'وقتی فشارهای موقعیت بیشتر از منابع ادراک\u200cشده باشند، چه چیزی ممکن است افزایش پیدا کند؟',
                          options: [
                            'استرس',
                            'هوش',
                            'توانایی قطعی',
                            'انگیزه در همه افراد',
                          ],
                          correctAnswerIndex: 0,
                          feedbackCorrect:
                              'صحیح! استرس نتیجه این عدم تعادل است.',
                        ),
                        QuizQuestion(
                          question: 'هدف تنفس آگاهانه چیست؟',
                          options: [
                            'تنفس بسیار عمیق',
                            'مشاهده جریان طبیعی تنفس',
                            'جلوگیری از همه افکار',
                            'حذف فوری اضطراب',
                          ],
                          correctAnswerIndex: 1,
                          feedbackCorrect:
                              'صحیح! هدف مشاهده جریان طبیعی تنفس است.',
                        ),
                        QuizQuestion(
                          question: 'فکر خودکار چیست؟',
                          options: [
                            'حقیقت قطعی',
                            'جمله یا تصویری که سریع ظاهر می\u200cشود',
                            'تصمیم کاملاً منطقی',
                            'فقط یک فکر مثبت',
                          ],
                          correctAnswerIndex: 1,
                          feedbackCorrect:
                              'صحیح! فکر خودکار جمله یا تصویری است که سریع ظاهر می\u200cشود.',
                        ),
                        QuizQuestion(
                          question: 'فکر متعادل چه ویژگی\u200cای دارد؟',
                          options: [
                            'مشکل را انکار می\u200cکند.',
                            'اطلاعات و شواهد را در نظر می\u200cگیرد.',
                            'همیشه بسیار مثبت است.',
                            'باید فوراً هیجان را حذف کند.',
                          ],
                          correctAnswerIndex: 1,
                          feedbackCorrect:
                              'صحیح! فکر متعادل اطلاعات و شواهد را در نظر می\u200cگیرد.',
                        ),
                        QuizQuestion(
                          question:
                              'اگر فعالیت دشوار باشد، چه کاری مناسب\u200cتر است؟',
                          options: [
                            'کنارگذاشتن کامل',
                            'سرزنش خود',
                            'کوچک\u200cکردن قدم',
                            'منتظرماندن برای انگیزه کامل',
                          ],
                          correctAnswerIndex: 2,
                          feedbackCorrect:
                              'صحیح! کوچک\u200cکردن قدم مناسب\u200cتر است.',
                        ),
                        QuizQuestion(
                          question: 'پذیرش هیجان به چه معناست؟',
                          options: [
                            'تأیید همه رفتارها',
                            'تشخیص وجود هیجان بدون واکنش فوری',
                            'تسلیم\u200cشدن',
                            'نادیده\u200cگرفتن مشکل',
                          ],
                          correctAnswerIndex: 1,
                          feedbackCorrect:
                              'صحیح! تشخیص وجود هیجان بدون واکنش فوری.',
                        ),
                        QuizQuestion(
                          question: 'اولین مرحله حل مسئله چیست؟',
                          options: [
                            'اجرای اولین راه',
                            'تعریف دقیق مشکل',
                            'سرزنش خود',
                            'درخواست فوری از دیگران',
                          ],
                          correctAnswerIndex: 1,
                          feedbackCorrect:
                              'صحیح! تعریف دقیق مشکل اولین مرحله است.',
                        ),
                      ],
                      onCompleted: (score) {
                        context.read<Week8ViewModel>().submitExerciseResponse(
                          weekNumber: 8,
                          dayNumber: 56,
                          exerciseType: 'final_course_quiz',
                          data: {'final_course_quiz_score': score},
                        );
                        _goToPage(3);
                      },
                      endMessage:
                          'این آزمون فقط برای مرور محتوای آموزشی است و نمره آن نشان\u200cدهنده وضعیت روان\u200cشناختی یا میزان موفقیت درمان نیست.',
                      buttonText: 'ادامه',
                    ),
                    // D56-04: App experience evaluation
                    _buildAppEvaluation(),
                    // D56-05: Course end
                    _buildCourseEnd(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // D56-04 form state
  double _clarityScore = 5;
  double _usabilityScore = 5;
  String? _durationRating;
  final Set<String> _preferredContentTypes = {};
  String? _technicalEase;
  String? _significantDistress;
  String? _recommendationIntention;
  final _feedbackCtrl = TextEditingController();

  final _durationOptions = [
    'کوتاه',
    'مناسب',
    'طولانی',
    'در روزهای مختلف متفاوت بود',
  ];
  final _contentTypeOptions = [
    'متن آموزشی',
    'سؤال\u200cهای چندگزینه\u200cای',
    'فرم\u200cهای ثبت',
    'فایل\u200cهای صوتی',
    'مرورهای هفتگی',
    'برنامه\u200cهای شخصی',
    'هیچ\u200cکدام',
    'مطمئن نیستم',
  ];
  final _technicalEaseOptions = [
    'بسیار آسان',
    'نسبتاً آسان',
    'نسبتاً دشوار',
    'بسیار دشوار',
  ];
  final _distressOptions = ['خیر', 'بله', 'ترجیح می\u200cدهم پاسخ ندهم'];
  final _recommendationOptions = ['بله', 'شاید', 'خیر', 'مطمئن نیستم'];

  bool get _canSubmitEvaluation =>
      _durationRating != null &&
      _technicalEase != null &&
      _significantDistress != null &&
      _recommendationIntention != null;

  Widget _buildWeekSummary(Week8ViewModel vm) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مسیر هشت\u200cهفته\u200cای شما',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          _buildStatCard(
            Icons.check_circle_outline,
            AppColors.success,
            'هفته\u200cهای تکمیل\u200cشده',
            '${7 + vm.completedDaysCount ~/ 7} از ۸',
          ),
          SizedBox(height: AppSizes.sm),
          _buildStatCard(
            Icons.calendar_today,
            AppColors.info,
            'روزهای تکمیل\u200cشده',
            '${vm.completedDaysCount} از ۵۶',
          ),
          if (vm.topSkills.isNotEmpty) ...[
            SizedBox(height: AppSizes.sm),
            _buildStatCard(
              Icons.star_outline,
              AppColors.warning,
              'مهارت\u200cهای منتخب',
              vm.topSkills.join('، '),
            ),
          ],
          if (vm.earliestWarningDomain != null) ...[
            SizedBox(height: AppSizes.sm),
            _buildStatCard(
              Icons.warning_amber_outlined,
              AppColors.error,
              'اولین حوزه هشدار',
              vm.earliestWarningDomain!,
            ),
          ],
          if (vm.maintenancePlan != null) ...[
            SizedBox(height: AppSizes.sm),
            _buildStatCard(
              Icons.schedule,
              AppColors.info,
              'تمرین منظم',
              vm.maintenancePlan!['regular_practice']?.toString() ?? '',
            ),
          ],
          if (vm.returnPlan != null) ...[
            SizedBox(height: AppSizes.sm),
            _buildStatCard(
              Icons.replay,
              AppColors.primary,
              'اولین قدم بازگشت',
              vm.returnPlan!['return_first_step']?.toString() ?? '',
            ),
          ],
          if (vm.supportPlan != null) ...[
            SizedBox(height: AppSizes.sm),
            _buildStatCard(
              Icons.people_outline,
              AppColors.success,
              'نوع منبع حمایت',
              vm.supportPlan!['support_type']?.toString() ?? '',
            ),
          ],
          SizedBox(height: AppSizes.md),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              'تعداد روزهای تکمیل\u200cشده به\u200cتنهایی نشان\u200cدهنده میزان بهبود یا وضعیت سلامت روان نیست.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                color: AppColors.info,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _goToPage(1),
              child: const Text('مشاهده برنامه شخصی'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildPersonalPlanCard(Week8ViewModel vm) {
    final skills = vm.topSkills;
    final warning = vm.earliestWarningDomain;
    final toolbox = vm.personalToolbox;
    final plan = vm.maintenancePlan;
    final ret = vm.returnPlan;
    final support = vm.supportPlan;

    // Find the toolbox tool related to the earliest warning domain
    String? warningTool;
    if (warning != null && toolbox != null) {
      if (warning == 'بدن') {
        warningTool = toolbox['body_tension_tool']?.toString();
      } else if (warning == 'فکر') {
        warningTool = toolbox['repetitive_thought_tool']?.toString();
      } else if (warning == 'هیجان') {
        warningTool = toolbox['high_emotion_tool']?.toString();
      }
    }

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'برنامه ادامه مسیر من',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          _buildPlanSection(
            'مهارت\u200cهای اصلی من',
            skills.isNotEmpty ? skills.join('، ') : null,
          ),
          _buildPlanSection('علامت هشدار اولیه من', warning),
          _buildPlanSection('مهارت من هنگام هشدار', warningTool),
          _buildPlanSection(
            'تمرین منظم من',
            plan?['regular_practice']?.toString(),
          ),
          _buildPlanSection(
            'نسخه کوتاه تمرین',
            plan?['minimum_practice_version']?.toString(),
          ),
          _buildPlanSection(
            'اگر وقفه ایجاد شد',
            ret?['balanced_return_message']?.toString(),
          ),
          _buildPlanSection(
            'اولین قدم بازگشت',
            ret?['return_first_step']?.toString(),
          ),
          _buildPlanSection('زمان درخواست کمک', () {
            final triggers = support?['professional_help_triggers'];
            if (triggers is List) return triggers.join('، ');
            return null;
          }()),
          _buildPlanSection(
            'اولین منبع حمایت',
            support?['support_type']?.toString(),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<Week8ViewModel>().submitExerciseResponse(
                  weekNumber: 8,
                  dayNumber: 56,
                  exerciseType: 'final_personal_plan',
                  data: {'generated': true},
                );
                _goToPage(2);
              },
              child: const Text('ذخیره برنامه'),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _goToPage(0),
              child: Text(
                'بازگشت به خلاصه',
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

  Widget _buildAppEvaluation() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ارزیابی تجربه استفاده از اپ',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Q1: Clarity slider
          Text(
            'محتوای برنامه چقدر قابل فهم بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              trackHeight: 6,
            ),
            child: Slider(
              value: _clarityScore,
              min: 0,
              max: 10,
              divisions: 10,
              label: _clarityScore.toInt().toString(),
              onChanged: (v) => setState(() => _clarityScore = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2: Usability slider
          Text(
            'تمرین\u200cها چقدر در زندگی روزمره قابل استفاده بودند؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              trackHeight: 6,
            ),
            child: Slider(
              value: _usabilityScore,
              min: 0,
              max: 10,
              divisions: 10,
              label: _usabilityScore.toInt().toString(),
              onChanged: (v) => setState(() => _usabilityScore = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3: Duration rating
          Text(
            'مدت تمرین\u200cهای روزانه چگونه بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._durationOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _durationRating,
              (v) => setState(() => _durationRating = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4: Content type (max 2)
          Text(
            'کدام نوع محتوا برای شما مفیدتر بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'حداکثر دو انتخاب',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._contentTypeOptions.map(
            (opt) => _buildCheckTile(
              opt,
              _preferredContentTypes.contains(opt),
              (checked) {
                setState(() {
                  if (checked) {
                    if (_preferredContentTypes.length < 2) {
                      _preferredContentTypes.add(opt);
                    }
                  } else {
                    _preferredContentTypes.remove(opt);
                  }
                });
              },
              enabled:
                  _preferredContentTypes.contains(opt) ||
                  _preferredContentTypes.length < 2,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q5: Technical ease
          Text(
            'استفاده فنی از اپ چگونه بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._technicalEaseOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _technicalEase,
              (v) => setState(() => _technicalEase = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q6: Significant distress
          Text(
            'آیا استفاده از برنامه باعث ناراحتی قابل توجه شد؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._distressOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _significantDistress,
              (v) => setState(() => _significantDistress = v),
            ),
          ),
          if (_significantDistress == 'بله') ...[
            SizedBox(height: AppSizes.sm),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Text(
                'انجام تمرین\u200cها الزامی نیست. در صورت نیاز از بخش «راهنما و کمک» استفاده کنید.',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.warning,
                  height: 1.6,
                ),
              ),
            ),
          ],
          SizedBox(height: AppSizes.lg),
          // Q7: Recommendation
          Text(
            'آیا استفاده از این برنامه را به فردی با شرایط مشابه پیشنهاد می\u200cکنید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._recommendationOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _recommendationIntention,
              (v) => setState(() => _recommendationIntention = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Optional feedback
          Text(
            'مهم\u200cترین پیشنهاد شما برای بهترشدن برنامه چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'حداکثر ۲۵۰ کاراکتر (اختیاری)',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: _feedbackCtrl,
            maxLength: 250,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'پیشنهاد شما...',
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
              onPressed: _canSubmitEvaluation ? _submitEvaluation : null,
              child: const Text('ثبت ارزیابی'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildCourseEnd() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'دوره هشت\u200cهفته\u200cای به پایان رسید',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'شما طی هشت هفته با مهارت\u200cهای شناختی\u200cـ\u200cرفتاری و ذهن\u200cآگاهی آشنا شدید و آن\u200cها را در موقعیت\u200cهای روزمره تمرین کردید.\n\nهدف برنامه حذف کامل استرس، افکار ناخوشایند یا هیجان\u200cهای دشوار نبود. هدف این بود که بتوانید واکنش\u200cهای خود را زودتر بشناسید و پاسخ\u200cهای مؤثرتری انتخاب کنید.\n\nبرنامه شخصی ادامه مسیر شما در بخش «ثبت\u200cهای من» باقی می\u200cماند و می\u200cتوانید آن را مرور یا ویرایش کنید.',
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
              color: AppColors.info.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'یادآوری پژوهشی',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  'ارزیابی\u200cهای پژوهشی، از جمله پس\u200cآزمون، به\u200cصورت جداگانه و از طریق پژوهشگر انجام خواهند شد.',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    height: 1.7,
                    color: AppColors.textPrimary,
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
                context.read<Week8ViewModel>().submitExerciseResponse(
                  weekNumber: 8,
                  dayNumber: 56,
                  exerciseType: 'intervention_complete',
                  data: {
                    'intervention_completed_at': DateTime.now()
                        .toIso8601String(),
                    'day_56_completed': true,
                    'final_personal_plan_generated': true,
                  },
                );
                context.read<Week8ViewModel>().completeDay(
                  weekNumber: 8,
                  dayNumber: 56,
                );
                Navigator.of(context).pop();
              },
              child: const Text('پایان دوره'),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _goToPage(1),
              child: Text(
                'مشاهده برنامه ادامه مسیر',
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

  Widget _buildStatCard(
    IconData icon,
    Color iconColor,
    String label,
    String value,
  ) {
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
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSection(String title, String? value) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSizes.sm),
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
            title,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value ?? 'هنوز مشخص نشده است.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: value != null ? AppColors.textPrimary : AppColors.textHint,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckTile(
    String value,
    bool isChecked,
    ValueChanged<bool> onChanged, {
    bool enabled = true,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSizes.xs),
      child: Material(
        color: enabled
            ? (isChecked
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: enabled ? () => onChanged(!isChecked) : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: isChecked ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    value,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.textHint,
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
    context.read<Week8ViewModel>().submitExerciseResponse(
      weekNumber: 8,
      dayNumber: 56,
      exerciseType: 'overall_app_evaluation',
      data: {
        'overall_clarity_score': _clarityScore.toInt(),
        'overall_usability_score': _usabilityScore.toInt(),
        'overall_duration_rating': _durationRating,
        'preferred_content_types': _preferredContentTypes.toList(),
        'technical_ease_rating': _technicalEase,
        'overall_significant_distress': _significantDistress,
        'recommendation_intention': _recommendationIntention,
        'optional_feedback': _feedbackCtrl.text.trim().isNotEmpty
            ? _feedbackCtrl.text.trim()
            : null,
      },
    );
    _goToPage(4);
  }
}
