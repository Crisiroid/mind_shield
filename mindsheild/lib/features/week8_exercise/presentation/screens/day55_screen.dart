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

class Day55Screen extends StatefulWidget {
  const Day55Screen({super.key});

  @override
  State<Day55Screen> createState() => _Day55ScreenState();
}

class _Day55ScreenState extends State<Day55Screen> {
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
                  dayNumber: 55,
                  dayTitle: 'چه زمانی کمک بیشتری لازم است؟',
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
                    // D55-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week8ViewModel>().submitExerciseResponse(
                          weekNumber: 8,
                          dayNumber: 55,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D55-02: Self-help limitations
                    TextEducationPage(
                      title:
                          'استفاده از کمک حرفه\u200cای بخشی از مراقبت از خود است',
                      bodyText:
                          'مهارت\u200cهای خودیار می\u200cتوانند برای مدیریت بسیاری از فشارهای روزمره مفید باشند، اما جایگزین کامل ارزیابی یا درمان حرفه\u200cای نیستند.\n\nاگر نشانه\u200cها شدید، پایدار یا رو به افزایش باشند، عملکرد روزانه را مختل کنند یا احساس کنید توان مراقبت از خود را ندارید، لازم است از خدمات تخصصی یا مسیرهای رسمی کمک استفاده شود.',
                      cards: const [
                        InfoCard(
                          title: 'نشانه\u200cهای نیاز به کمک بیشتر',
                          text:
                              'افزایش مداوم استرس، اضطراب یا خلق پایین\nاختلال قابل توجه خواب یا عملکرد\nناتوانی در انجام وظایف روزمره\nکناره\u200cگیری شدید از دیگران\nافزایش رفتارهای پرخطر\nاحساس ناامنی\nناتوانی در مراقبت از خود\nوجود افکار آسیب به خود یا دیگری',
                        ),
                      ],
                      helpTitle: 'کادر مهم',
                      helpText:
                          'در وضعیت خطر فوری یا احساس ناامنی، منتظر تمرین بعدی اپ نمانید و از مسیرهای اضطراری یا خدمات مصوب استفاده کنید.',
                      primaryButtonText: 'منابع حمایت خود را مشخص کنم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D55-03: Support plan form
                    _buildSupportPlanForm(),
                    // D55-04: Day end
                    DayEndPage(
                      title: 'پایان روز پنجاه\u200cوپنجم',
                      feedbackText:
                          'کمک\u200cخواستن نشانه شکست مهارت\u200cهای خودیار نیست. تشخیص محدودیت خودیاری و استفاده به\u200cموقع از حمایت، بخشی از مراقبت از سلامت روان است.',
                      missionText:
                          'مطمئن شوید مسیر «راهنما و کمک» را می\u200cشناسید.',
                      notificationText:
                          'منابع حمایت و زمان استفاده از کمک حرفه\u200cای را مرور کنید.',
                      buttonText: 'پایان روز پنجاه\u200cوپنجم',
                      onButtonPressed: () {
                        context.read<Week8ViewModel>().completeDay(
                          weekNumber: 8,
                          dayNumber: 55,
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

  // D55-03 form state
  String? _supportType;
  final Set<String> _helpTriggers = {};
  String? _helpPageReviewed;
  String? _firstHelpAction;

  final _supportTypeOptions = [
    'فرد مورد اعتماد',
    'یکی از اعضای خانواده',
    'دوست یا همکار مورد اعتماد',
    'روان\u200cشناس یا روان\u200cپزشک',
    'مرکز مشاوره یا خدمات سلامت',
    'مسیر رسمی سازمانی',
    'خدمت اضطراری',
    'هنوز مشخص نکرده\u200cام',
  ];

  final _helpTriggerOptions = [
    'ادامه نشانه\u200cها برای مدت طولانی',
    'اختلال در کار یا زندگی روزمره',
    'افزایش شدید اضطراب یا خلق پایین',
    'اختلال شدید خواب',
    'کناره\u200cگیری شدید',
    'احساس ناامنی',
    'ناتوانی در مراقبت از خود',
    'علامت دیگر',
  ];

  final _helpPageOptions = ['بله', 'اکنون مشاهده می\u200cکنم.', 'فعلاً نه'];

  final _firstActionOptions = [
    'تماس با فرد حمایتگر',
    'گرفتن وقت از متخصص',
    'مراجعه به مرکز مصوب',
    'استفاده از مسیر رسمی',
    'تماس با خدمت اضطراری',
    'هنوز مشخص نکرده\u200cام',
  ];

  bool get _canSubmitSupport =>
      _supportType != null &&
      _helpTriggers.isNotEmpty &&
      _helpPageReviewed != null &&
      _firstHelpAction != null;

  Widget _buildSupportPlanForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'برنامه حمایت',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Q1
          Text(
            'در صورت افزایش فشار، اولین نوع منبع حمایت شما چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._supportTypeOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _supportType,
              (v) => setState(() => _supportType = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2
          Text(
            'چه علامتی نشان می\u200cدهد باید از کمک حرفه\u200cای استفاده کنید؟',
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
          ..._helpTriggerOptions.map(
            (opt) => _buildCheckTile(
              opt,
              _helpTriggers.contains(opt),
              (checked) {
                setState(() {
                  if (checked) {
                    if (_helpTriggers.length < 2) {
                      _helpTriggers.add(opt);
                    }
                  } else {
                    _helpTriggers.remove(opt);
                  }
                });
              },
              enabled: _helpTriggers.contains(opt) || _helpTriggers.length < 2,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3
          Text(
            'آیا مسیر «راهنما و کمک» را مشاهده کرده\u200cاید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._helpPageOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _helpPageReviewed,
              (v) => setState(() => _helpPageReviewed = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4
          Text(
            'اولین اقدام شما در صورت نیاز چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._firstActionOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _firstHelpAction,
              (v) => setState(() => _firstHelpAction = v),
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Privacy note
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              'نام، شماره تلفن یا اطلاعات هویتی فرد حمایتگر در اپ وارد نشود.',
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
              onPressed: _canSubmitSupport ? _submitSupport : null,
              child: const Text('ثبت برنامه حمایت'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
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

  void _submitSupport() {
    context.read<Week8ViewModel>().submitExerciseResponse(
      weekNumber: 8,
      dayNumber: 55,
      exerciseType: 'support_plan',
      data: {
        'support_type': _supportType,
        'professional_help_triggers': _helpTriggers.toList(),
        'help_page_reviewed': _helpPageReviewed,
        'first_help_action': _firstHelpAction,
      },
    );
    _goToPage(3);
  }
}
