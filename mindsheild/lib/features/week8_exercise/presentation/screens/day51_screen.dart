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

class Day51Screen extends StatefulWidget {
  const Day51Screen({super.key});

  @override
  State<Day51Screen> createState() => _Day51ScreenState();
}

class _Day51ScreenState extends State<Day51Screen> {
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
                  dayNumber: 51,
                  dayTitle: 'علائم هشدار شخصی',
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
                    // D51-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week8ViewModel>().submitExerciseResponse(
                          weekNumber: 8,
                          dayNumber: 51,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D51-02: What are warning signs?
                    TextEducationPage(
                      title: 'تغییرات معمولاً نشانه\u200cهایی دارند',
                      bodyText:
                          'افزایش فشار روانی همیشه ناگهانی و بدون علامت نیست. تغییر در فکر، هیجان، بدن یا رفتار ممکن است نشان دهد که لازم است زودتر وضعیت خود را بررسی کنیم.\n\nوجود یک علامت به\u200cتنهایی به معنای وجود اختلال یا بازگشت کامل مشکل نیست. هدف، شناخت الگوی شخصی و اقدام زودهنگام است.',
                      imageWidget: _buildW8Img02(),
                      cards: const [
                        InfoCard(
                          title: 'مثال',
                          text:
                              'فکر: «نمی\u200cتوانم مدیریت کنم.»\nبدن: افزایش تنش شانه\u200cها\nرفتار: کنارگذاشتن فعالیت\u200cها\nاقدام: مکث و انتخاب یک مهارت ساده',
                        ),
                      ],
                      primaryButtonText: 'علائم خود را انتخاب کنم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D51-03: Warning signs checklist
                    _buildWarningSignsForm(),
                    // D51-04: Day end
                    DayEndPage(
                      title: 'پایان روز پنجاه\u200cویکم',
                      feedbackText:
                          'شناخت علامت هشدار به معنای بررسی مداوم و نگران\u200cکننده خود نیست. هدف این است که در صورت تکرار چند علامت، زودتر یک اقدام کوچک انجام دهید.',
                      missionText: 'اولین علامت هشدار خود را به خاطر بسپارید.',
                      notificationText:
                          'علائم اولیه فشار را در فکر، هیجان، بدن و رفتار مرور کنید.',
                      buttonText: 'پایان روز پنجاه\u200cویکم',
                      onButtonPressed: () {
                        context.read<Week8ViewModel>().completeDay(
                          weekNumber: 8,
                          dayNumber: 51,
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

  // D51-03 form state
  final Set<String> _thoughtSigns = {};
  final Set<String> _emotionSigns = {};
  final Set<String> _bodySigns = {};
  final Set<String> _behaviorSigns = {};
  String? _earliestDomain;

  final _thoughtOptions = [
    'نگرانی تکراری',
    'فاجعه\u200cسازی',
    'بایدهای سخت\u200cگیرانه',
    'خودانتقادی شدید',
    'ناامیدی',
    'مشکل در تصمیم\u200cگیری',
    'کاهش تمرکز',
    'فکر دیگر',
    'نشانه مشخصی ندارم',
  ];

  final _emotionOptions = [
    'اضطراب',
    'تحریک\u200cپذیری',
    'ناراحتی',
    'خشم',
    'شرم یا احساس گناه',
    'ناامیدی',
    'بی\u200cحسی هیجانی',
    'هیجان دیگر',
    'نشانه مشخصی ندارم',
  ];

  final _bodyOptions = [
    'تنش عضلات',
    'سردرد',
    'تغییر تنفس',
    'خستگی',
    'تغییر خواب',
    'ناراحتی معده',
    'تپش قلب',
    'علامت دیگر',
    'نشانه مشخصی ندارم',
  ];

  final _behaviorOptions = [
    'تعلل',
    'کاهش فعالیت',
    'کناره\u200cگیری از دیگران',
    'تحریک\u200cپذیری در ارتباط',
    'بررسی مکرر',
    'به\u200cهم\u200cخوردن برنامه روزانه',
    'کنارگذاشتن تمرین\u200cها',
    'درخواست\u200cنکردن کمک',
    'رفتار دیگر',
    'نشانه مشخصی ندارم',
  ];

  final _domainOptions = ['فکر', 'هیجان', 'بدن', 'رفتار', 'مطمئن نیستم'];

  bool get _canSubmitSigns => _earliestDomain != null;

  Widget _buildWarningSignsForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'چک\u200cلیست علائم هشدار',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Thought signs
          _buildSectionTitle('علائم فکری', 'حداکثر سه انتخاب'),
          ..._thoughtOptions.map(
            (opt) => _buildCheckTile(
              opt,
              _thoughtSigns.contains(opt),
              (checked) => _toggleInSet(_thoughtSigns, opt, checked, 3),
              enabled: _thoughtSigns.contains(opt) || _thoughtSigns.length < 3,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Emotion signs
          _buildSectionTitle('علائم هیجانی', 'حداکثر سه انتخاب'),
          ..._emotionOptions.map(
            (opt) => _buildCheckTile(
              opt,
              _emotionSigns.contains(opt),
              (checked) => _toggleInSet(_emotionSigns, opt, checked, 3),
              enabled: _emotionSigns.contains(opt) || _emotionSigns.length < 3,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Body signs
          _buildSectionTitle('علائم بدنی', 'حداکثر سه انتخاب'),
          ..._bodyOptions.map(
            (opt) => _buildCheckTile(
              opt,
              _bodySigns.contains(opt),
              (checked) => _toggleInSet(_bodySigns, opt, checked, 3),
              enabled: _bodySigns.contains(opt) || _bodySigns.length < 3,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Behavior signs
          _buildSectionTitle('علائم رفتاری', 'حداکثر سه انتخاب'),
          ..._behaviorOptions.map(
            (opt) => _buildCheckTile(
              opt,
              _behaviorSigns.contains(opt),
              (checked) => _toggleInSet(_behaviorSigns, opt, checked, 3),
              enabled:
                  _behaviorSigns.contains(opt) || _behaviorSigns.length < 3,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Earliest domain
          Text(
            'کدام حوزه معمولاً زودتر تغییر می\u200cکند؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._domainOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _earliestDomain,
              (v) => setState(() => _earliestDomain = v),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitSigns ? _submitSigns : null,
              child: const Text('ثبت علائم هشدار'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
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
            fontSize: AppSizes.fontXs,
            color: AppColors.textHint,
          ),
        ),
        SizedBox(height: AppSizes.sm),
      ],
    );
  }

  void _toggleInSet(Set<String> set, String value, bool checked, int max) {
    setState(() {
      if (checked) {
        if (set.length < max) set.add(value);
      } else {
        set.remove(value);
      }
    });
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

  void _submitSigns() {
    context.read<Week8ViewModel>().submitExerciseResponse(
      weekNumber: 8,
      dayNumber: 51,
      exerciseType: 'warning_signs',
      data: {
        'warning_thoughts': _thoughtSigns.toList(),
        'warning_emotions': _emotionSigns.toList(),
        'warning_body_signs': _bodySigns.toList(),
        'warning_behaviors': _behaviorSigns.toList(),
        'earliest_warning_domain': _earliestDomain,
      },
    );
    _goToPage(3);
  }

  Widget _buildW8Img02() {
    return Image.asset(
      'assets/images/week8/w8_img_02.png',
      height: 180,
      errorBuilder: (_, __, ___) => Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFlowStep('علامت هشدار', Icons.warning_amber_outlined),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('مکث و بررسی وضعیت', Icons.pause_circle_outline),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('انتخاب یک مهارت', Icons.checklist_outlined),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('انجام یک قدم کوچک', Icons.directions_run),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('بررسی نتیجه', Icons.assessment_outlined),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep(
              'در صورت نیاز، استفاده از حمایت',
              Icons.people_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStep(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            SizedBox(width: 6),
            Text(
              label,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
