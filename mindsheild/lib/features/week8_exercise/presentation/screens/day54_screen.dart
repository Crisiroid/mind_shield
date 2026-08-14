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

class Day54Screen extends StatefulWidget {
  const Day54Screen({super.key});

  @override
  State<Day54Screen> createState() => _Day54ScreenState();
}

class _Day54ScreenState extends State<Day54Screen> {
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
                  dayNumber: 54,
                  dayTitle: 'اگر تمرین\u200cها متوقف شدند',
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
                    // D54-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week8ViewModel>().submitExerciseResponse(
                          weekNumber: 8,
                          dayNumber: 54,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D54-02: Pause is not failure
                    TextEducationPage(
                      title: 'چند روز توقف، تمام پیشرفت را از بین نمی\u200cبرد',
                      bodyText:
                          'تغییر برنامه، خستگی، بیماری، سفر یا افزایش فشار ممکن است باعث توقف تمرین\u200cها شود. وقفه در تمرین طبیعی است.\n\nیکی از موانع بازگشت این است که فرد پس از وقفه نتیجه بگیرد: «دیگر فایده\u200cای ندارد» یا «همه\u200cچیز را خراب کردم».',
                      imageWidget: _buildW8Img03(),
                      cards: const [
                        InfoCard(
                          title: 'سه گام بازگشت',
                          text:
                              '۱. وقفه را بدون سرزنش می\u200cپذیرم.\n۲. علت اصلی را بررسی می\u200cکنم.\n۳. با کوچک\u200cترین نسخه یک مهارت شروع می\u200cکنم.',
                        ),
                      ],
                      primaryButtonText: 'برنامه بازگشت خود را بسازم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D54-03: Return plan form
                    _buildReturnPlanForm(),
                    // D54-04: Day end
                    DayEndPage(
                      title: 'پایان روز پنجاه\u200cوچهارم',
                      feedbackText:
                          'بازگشت با یک قدم کوچک، عملی\u200cتر از تلاش برای جبران کامل روزهای ازدست\u200cرفته است.',
                      missionText:
                          'جمله بازگشت خود را به خاطر بسپارید:\n«لازم نیست همه\u200cچیز را از ابتدا شروع کنم؛ فقط قدم بعدی را انجام می\u200cدهم.»',
                      notificationText:
                          'برای وقفه\u200cهای احتمالی، یک برنامه ساده بازگشت تنظیم کنید.',
                      buttonText: 'پایان روز پنجاه\u200cوچهارم',
                      onButtonPressed: () {
                        context.read<Week8ViewModel>().completeDay(
                          weekNumber: 8,
                          dayNumber: 54,
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

  // D54-03 form state
  final Set<String> _interruptionCauses = {};
  String? _postInterruptionThought;
  String? _balancedMessage;
  String? _returnFirstStep;

  final _causeOptions = [
    'فشار کاری',
    'تغییر برنامه',
    'خستگی',
    'بیماری',
    'سفر یا جابه\u200cجایی',
    'فراموشی',
    'ناامیدی',
    'احساس بی\u200cنیازی پس از بهترشدن',
    'مانع دیگر',
  ];

  final _thoughtOptions = [
    'دیگر فایده\u200cای ندارد.',
    'از برنامه عقب افتاده\u200cام.',
    'باید همه\u200cچیز را از ابتدا انجام دهم.',
    'من توان ادامه ندارم.',
    'فکر دیگری',
    'مطمئن نیستم',
  ];

  final _balancedOptions = [
    'وقفه طبیعی است و می\u200cتوانم با یک قدم کوچک برگردم.',
    'لازم نیست تمرین\u200cهای ازدست\u200cرفته را جبران کنم.',
    'فقط مهارتی را انتخاب می\u200cکنم که اکنون کاربرد دارد.',
    'می\u200cتوانم از حمایت استفاده کنم.',
    'پاسخ دیگر',
  ];

  final _firstStepOptions = [
    'یک دقیقه توجه به تنفس',
    'مرور جعبه\u200cابزار',
    'ثبت یک فکر',
    'انجام یک فعالیت کوتاه',
    'تعریف یک مشکل',
    'تماس با فرد حمایتگر',
    'قدم دیگر',
  ];

  bool get _canSubmitReturn =>
      _interruptionCauses.isNotEmpty &&
      _postInterruptionThought != null &&
      _balancedMessage != null &&
      _returnFirstStep != null;

  Widget _buildReturnPlanForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'برنامه بازگشت',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Q1
          Text(
            'چه چیزی ممکن است باعث وقفه شود؟',
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
          ..._causeOptions.map(
            (opt) => _buildCheckTile(
              opt,
              _interruptionCauses.contains(opt),
              (checked) {
                setState(() {
                  if (checked) {
                    if (_interruptionCauses.length < 2) {
                      _interruptionCauses.add(opt);
                    }
                  } else {
                    _interruptionCauses.remove(opt);
                  }
                });
              },
              enabled:
                  _interruptionCauses.contains(opt) ||
                  _interruptionCauses.length < 2,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2
          Text(
            'پس از وقفه، کدام فکر ممکن است ظاهر شود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._thoughtOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _postInterruptionThought,
              (v) => setState(() => _postInterruptionThought = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3
          Text(
            'کدام پاسخ متعادل\u200cتر است؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._balancedOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _balancedMessage,
              (v) => setState(() => _balancedMessage = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4
          Text(
            'اولین قدم بازگشت شما چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._firstStepOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _returnFirstStep,
              (v) => setState(() => _returnFirstStep = v),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitReturn ? _submitReturn : null,
              child: const Text('ثبت برنامه بازگشت'),
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

  void _submitReturn() {
    context.read<Week8ViewModel>().submitExerciseResponse(
      weekNumber: 8,
      dayNumber: 54,
      exerciseType: 'return_after_interruption',
      data: {
        'interruption_causes': _interruptionCauses.toList(),
        'post_interruption_thought': _postInterruptionThought,
        'balanced_return_message': _balancedMessage,
        'return_first_step': _returnFirstStep,
      },
    );
    _goToPage(3);
  }

  Widget _buildW8Img03() {
    return Image.asset(
      'assets/images/week8/w8_img_03.png',
      height: 180,
      errorBuilder: (_, __, ___) => Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pause_circle_outline,
                      color: AppColors.success,
                      size: 28,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'وقفه موقت',
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'می\u200cتوان با یک قدم کوچک بازگشت',
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 120, color: AppColors.divider),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      color: AppColors.error,
                      size: 28,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'کنارگذاشتن کامل',
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'دیگر فایده\u200cای ندارد',
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
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
}
