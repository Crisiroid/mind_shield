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
import '../view_models/week8_view_model.dart';

class Day52Screen extends StatefulWidget {
  const Day52Screen({super.key});

  @override
  State<Day52Screen> createState() => _Day52ScreenState();
}

class _Day52ScreenState extends State<Day52Screen> {
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
                  dayNumber: 52,
                  dayTitle: 'برای هر موقعیت، کدام مهارت؟',
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
                    // D52-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week8ViewModel>().submitExerciseResponse(
                          weekNumber: 8,
                          dayNumber: 52,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D52-02: Choosing the right tool
                    TextEducationPage(
                      title: 'یک مهارت برای همه موقعیت\u200cها کافی نیست',
                      bodyText:
                          'نوع موقعیت تعیین می\u200cکند کدام مهارت کاربرد بیشتری دارد. یک مشکل واقعی ممکن است به حل مسئله نیاز داشته باشد، در حالی که یک فکر تکراری ممکن است با مشاهده فکر یا بررسی شواهد بهتر مدیریت شود.',
                      cards: const [
                        InfoCard(
                          title: 'تنش بدنی',
                          text: 'توقف کوتاه بدن، اسکن بدن یا تنفس آگاهانه',
                        ),
                        InfoCard(
                          title: 'فکر منفی تکراری',
                          text: 'ثبت فکر، بررسی شواهد یا مشاهده فکر',
                        ),
                        InfoCard(
                          title: 'خلق یا انرژی پایین',
                          text: 'یک فعالیت کوچک و قابل اجرا',
                        ),
                        InfoCard(
                          title: 'هیجان شدید',
                          text: 'نام\u200cگذاری هیجان، مکث و انتخاب پاسخ',
                        ),
                        InfoCard(
                          title: 'مشکل مشخص',
                          text: 'حل مسئله گام\u200cبه\u200cگام',
                        ),
                      ],
                      helpTitle: 'کادر ایمنی',
                      helpText:
                          'در موقعیت خطر واقعی یا موضوع تخصصی، مهارت خودیار جایگزین اقدام رسمی یا کمک حرفه\u200cای نیست.',
                      primaryButtonText: 'جعبه\u200cابزار خود را بسازم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D52-03: Building toolbox
                    _buildToolboxForm(),
                    // D52-04: Day end
                    DayEndPage(
                      title: 'پایان روز پنجاه\u200cودوم',
                      feedbackText:
                          'انتخاب یک مهارت مناسب، از انجام هم\u200cزمان چند تمرین کاربردی\u200cتر است.',
                      missionText:
                          'اگر امروز یکی از این موقعیت\u200cها رخ داد، ابزار انتخاب\u200cشده را برای چند دقیقه امتحان کنید.',
                      notificationText:
                          'امروز برای هر موقعیت، یک مهارت ساده انتخاب کنید.',
                      buttonText: 'پایان روز پنجاه\u200cودوم',
                      onButtonPressed: () {
                        context.read<Week8ViewModel>().completeDay(
                          weekNumber: 8,
                          dayNumber: 52,
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

  // D52-03 form state
  String? _bodyTensionTool;
  String? _repetitiveThoughtTool;
  String? _lowMoodTool;
  String? _highEmotionTool;
  String? _realProblemTool;

  final _bodyTensionOptions = [
    'توقف کوتاه بدن',
    'اسکن بدن',
    'تنفس آگاهانه',
    'فعالیت بدنی سبک و متناسب',
    'مهارت دیگر',
    'مطمئن نیستم',
  ];

  final _repetitiveThoughtOptions = [
    'ثبت فکر',
    'بررسی شواهد',
    'نوشتن فکر متعادل',
    'نام\u200cگذاری «این یک فکر است»',
    'عبارت «متوجه می\u200cشوم که...»',
    'مهارت دیگر',
    'مطمئن نیستم',
  ];

  final _lowMoodOptions = [
    'انجام یک فعالیت کوچک',
    'کوچک\u200cکردن یک کار',
    'ارتباط با فرد حمایتگر',
    'مرور برنامه روزانه',
    'مهارت دیگر',
    'مطمئن نیستم',
  ];

  final _highEmotionOptions = [
    'مکث و تنفس',
    'نام\u200cگذاری هیجان',
    'مشاهده میل به عمل',
    'انتخاب پاسخ سنجیده\u200cتر',
    'فاصله\u200cگرفتن از موقعیت، در صورت امن و مجازبودن',
    'مهارت دیگر',
    'مطمئن نیستم',
  ];

  final _realProblemOptions = [
    'تعریف دقیق مشکل',
    'تولید راه\u200cحل\u200cها',
    'انتخاب قدم اول',
    'درخواست اطلاعات یا کمک',
    'ارتباط قاطعانه',
    'مهارت دیگر',
    'مطمئن نیستم',
  ];

  bool get _canSubmitToolbox =>
      _bodyTensionTool != null &&
      _repetitiveThoughtTool != null &&
      _lowMoodTool != null &&
      _highEmotionTool != null &&
      _realProblemTool != null;

  Widget _buildToolboxForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ساخت جعبه\u200cابزار',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Body tension
          _buildToolSection(
            'تنش بدنی',
            'وقتی تنش بدنی افزایش پیدا می\u200cکند:',
            _bodyTensionOptions,
            _bodyTensionTool,
            (v) => setState(() => _bodyTensionTool = v),
          ),
          SizedBox(height: AppSizes.lg),
          // Repetitive thought
          _buildToolSection(
            'فکر تکراری',
            'وقتی یک فکر منفی تکرار می\u200cشود:',
            _repetitiveThoughtOptions,
            _repetitiveThoughtTool,
            (v) => setState(() => _repetitiveThoughtTool = v),
          ),
          SizedBox(height: AppSizes.lg),
          // Low mood
          _buildToolSection(
            'خلق یا انرژی پایین',
            'وقتی خلق یا انرژی پایین است:',
            _lowMoodOptions,
            _lowMoodTool,
            (v) => setState(() => _lowMoodTool = v),
          ),
          SizedBox(height: AppSizes.lg),
          // High emotion
          _buildToolSection(
            'هیجان شدید',
            'وقتی هیجان شدید و میل به واکنش سریع وجود دارد:',
            _highEmotionOptions,
            _highEmotionTool,
            (v) => setState(() => _highEmotionTool = v),
          ),
          SizedBox(height: AppSizes.lg),
          // Real problem
          _buildToolSection(
            'مشکل مشخص',
            'وقتی یک مشکل واقعی وجود دارد:',
            _realProblemOptions,
            _realProblemTool,
            (v) => setState(() => _realProblemTool = v),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitToolbox ? _submitToolbox : null,
              child: const Text('ذخیره جعبه\u200cابزار'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildToolSection(
    String title,
    String subtitle,
    List<String> options,
    String? selected,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          subtitle,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontSm,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        SizedBox(height: AppSizes.sm),
        ...options.map((opt) => _buildRadioTile(opt, selected, onChanged)),
      ],
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

  void _submitToolbox() {
    context.read<Week8ViewModel>().submitExerciseResponse(
      weekNumber: 8,
      dayNumber: 52,
      exerciseType: 'personal_toolbox',
      data: {
        'body_tension_tool': _bodyTensionTool,
        'repetitive_thought_tool': _repetitiveThoughtTool,
        'low_mood_tool': _lowMoodTool,
        'high_emotion_tool': _highEmotionTool,
        'real_problem_tool': _realProblemTool,
      },
    );
    _goToPage(3);
  }
}
