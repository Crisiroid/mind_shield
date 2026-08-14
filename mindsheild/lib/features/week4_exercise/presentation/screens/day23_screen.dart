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
import '../view_models/week4_view_model.dart';

class Day23Screen extends StatefulWidget {
  const Day23Screen({super.key});

  @override
  State<Day23Screen> createState() => _Day23ScreenState();
}

class _Day23ScreenState extends State<Day23Screen> {
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
                  dayNumber: 23,
                  dayTitle: 'شواهد موافق فکر',
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
                    // D23-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week4ViewModel>().submitExerciseResponse(
                          weekNumber: 4,
                          dayNumber: 23,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D23-02: What is evidence?
                    TextEducationPage(
                      title: 'شواهد با احساس یا تکرار فکر تفاوت دارد',
                      bodyText:
                          'شواهد یعنی اطلاعات مشخص و قابل مشاهده\u200cای که به نظر می\u200cرسد از فکر حمایت می\u200cکند.\n\nاحساس شدید، تکرار فکر یا واقعی\u200cبه\u200cنظررسیدن آن، به\u200cتنهایی شاهد محسوب نمی\u200cشود.',
                      cards: const [
                        InfoCard(
                          title: 'مثال',
                          text:
                              'فکر: «عملکرد من کاملاً ضعیف بوده است.»\n\nشاهد قابل مشاهده: «دو بخش از گزارش برای اصلاح بازگردانده شد.»\n\nموردی که شاهد نیست: «احساس می\u200cکنم بی\u200cکفایتم.»',
                        ),
                        InfoCard(
                          title: 'نکته',
                          text:
                              'ثبت شواهد موافق به معنای تأیید کامل فکر نیست. هدف این است که بررسی منصفانه از اطلاعات واقعی آغاز شود.',
                        ),
                      ],
                      primaryButtonText: 'ثبت شواهد',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D23-03: Supporting evidence form
                    _buildEvidenceForm(),
                    // D23-04: Day end
                    DayEndPage(
                      title: 'پایان روز بیست\u200cوسوم',
                      missionText:
                          'بررسی منصفانه فکر از دیدن شواهد موافق آغاز می\u200cشود؛ حتی اگر این شواهد ناخوشایند باشند.\n\nمأموریت: امروز میان «واقعیتی که اتفاق افتاده» و «معنایی که ذهن به آن داده است» تفاوت بگذارید.',
                      notificationText:
                          'امروز شواهد واقعی مرتبط با فکر انتخاب\u200cشده را بررسی کنید.',
                      buttonText: 'پایان روز بیست\u200cوسوم',
                      onButtonPressed: () {
                        context.read<Week4ViewModel>().completeDay(
                          weekNumber: 4,
                          dayNumber: 23,
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

  // Form state
  final _evidence1Ctrl = TextEditingController();
  final _evidence2Ctrl = TextEditingController();
  final _fallbackThoughtCtrl = TextEditingController();
  bool _noEvidenceFound = false;
  String? _selfClassification;

  final _classificationOptions = [
    'واقعیت یا اطلاعات قابل مشاهده',
    'احساس شخصی',
    'تکرار همان فکر',
    'مطمئن نیستم',
  ];

  bool get _canSubmit =>
      !_noEvidenceFound &&
      _evidence1Ctrl.text.isNotEmpty &&
      _selfClassification != null;

  bool get _showFeelingWarning =>
      _selfClassification == 'احساس شخصی' ||
      _selfClassification == 'تکرار همان فکر';

  Widget _buildEvidenceForm() {
    final vm = context.read<Week4ViewModel>();
    final selectedThought = vm.lastSelectedThought;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ثبت شواهد موافق',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Safety box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              'یک موقعیت خفیف یا متوسط و غیرمحرمانه انتخاب کنید. از ثبت نام افراد، محل خدمت، یگان، اطلاعات سازمانی یا جزئیات مأموریتی خودداری کنید.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Display thought from day 22 or fallback
          if (selectedThought != null) ...[
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'فکر انتخاب\u200cشده شما:',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    '«$selectedThought»',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildLabel('فکری را که می\u200cخواهید بررسی کنید کوتاه بنویسید.'),
            TextField(
              controller: _fallbackThoughtCtrl,
              maxLength: 200,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'فکر را کوتاه بنویسید...',
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
          ],
          SizedBox(height: AppSizes.lg),
          // Field 1: Observable evidence
          _buildLabel(
            'کدام اطلاعات قابل مشاهده از این فکر حمایت می\u200cکنند؟',
          ),
          TextField(
            controller: _evidence1Ctrl,
            maxLength: 200,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'شاهد اول...',
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
          SizedBox(height: AppSizes.md),
          // Field 2: Optional second evidence
          _buildLabel('شاهد دیگری وجود دارد؟ (اختیاری)'),
          TextField(
            controller: _evidence2Ctrl,
            maxLength: 200,
            maxLines: 2,
            enabled: !_noEvidenceFound,
            decoration: InputDecoration(
              hintText: 'شاهد دوم...',
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
          SizedBox(height: AppSizes.md),
          // Option: No evidence found
          InkWell(
            onTap: () => setState(() {
              _noEvidenceFound = !_noEvidenceFound;
              if (_noEvidenceFound) {
                _evidence1Ctrl.clear();
                _evidence2Ctrl.clear();
              }
            }),
            child: Row(
              children: [
                Checkbox(
                  value: _noEvidenceFound,
                  onChanged: (v) =>
                      setState(() => _noEvidenceFound = v ?? false),
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    'شاهد مشخصی پیدا نکردم.',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Control question
          _buildLabel('آنچه نوشته\u200cاید بیشتر کدام است؟'),
          ..._classificationOptions.map((opt) {
            final isSelected = _selfClassification == opt;
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.xs),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: () => setState(() => _selfClassification = opt),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.xs,
                    ),
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
                        Radio<String>(
                          value: opt,
                          groupValue: _selfClassification,
                          onChanged: (v) =>
                              setState(() => _selfClassification = v),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            opt,
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
          // Warning if feeling or repetition selected
          if (_showFeelingWarning) ...[
            SizedBox(height: AppSizes.sm),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                'احساس\u200cها مهم\u200cاند، اما برای این تمرین تلاش کنید یک اتفاق یا اطلاعات قابل مشاهده را ثبت کنید.',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_noEvidenceFound || _canSubmit)
                  ? _submitEvidence
                  : null,
              child: const Text('ثبت شواهد'),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _goToPage(3),
              child: Text(
                'امروز انجام نمی\u200cدهم',
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

  void _submitEvidence() {
    context.read<Week4ViewModel>().submitExerciseResponse(
      weekNumber: 4,
      dayNumber: 23,
      exerciseType: 'supporting_evidence',
      data: {
        'supporting_evidence_1': _evidence1Ctrl.text,
        'supporting_evidence_2': _evidence2Ctrl.text,
        'supporting_evidence_none': _noEvidenceFound,
        'evidence_self_classification': _selfClassification,
        if (_fallbackThoughtCtrl.text.isNotEmpty)
          'fallback_thought': _fallbackThoughtCtrl.text,
      },
    );
    _goToPage(3);
  }

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
}
