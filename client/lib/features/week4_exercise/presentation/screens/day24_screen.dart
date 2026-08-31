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

class Day24Screen extends StatefulWidget {
  const Day24Screen({super.key});

  @override
  State<Day24Screen> createState() => _Day24ScreenState();
}

class _Day24ScreenState extends State<Day24Screen> {
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
                  dayNumber: 24,
                  dayTitle: 'اطلاعات تکمیلی',
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
                    // D24-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week4ViewModel>().submitExerciseResponse(
                          weekNumber: 4,
                          dayNumber: 24,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D24-02: Supplementary info education
                    TextEducationPage(
                      title: 'آیا فکر اولیه تمام اطلاعات را در نظر گرفته است؟',
                      bodyText:
                          'افکار خودکار اغلب روی بخشی از اطلاعات تمرکز می\u200cکنند و بخش\u200cهای دیگر را نادیده می\u200cگیرند.\n\nشواهد مخالف یا اطلاعات تکمیلی، اطلاعاتی هستند که نشان می\u200cدهند فکر اولیه ممکن است بیش از حد کلی، قطعی یا شدید باشد.',
                      cards: const [
                        InfoCard(
                          title: 'استثنا',
                          text: 'آیا همیشه این اتفاق افتاده است؟',
                        ),
                        InfoCard(
                          title: 'اطلاعات دیگر',
                          text: 'چه بخشی از موقعیت در فکر اولیه دیده نشده است؟',
                        ),
                        InfoCard(
                          title: 'توضیح جایگزین',
                          text: 'آیا دلیل دیگری نیز ممکن است وجود داشته باشد؟',
                        ),
                        InfoCard(
                          title: 'دیدگاه بیرونی',
                          text:
                              'اگر فرد دیگری در این موقعیت بود، چه اطلاعاتی را به او یادآوری می‌کردید؟',
                        ),
                        InfoCard(
                          title: 'مثال',
                          text:
                              'فکر: «من همیشه همه‌چیز را خراب می‌کنم.»\n\nاطلاعات تکمیلی: «بخش‌های دیگری از همین کار درست انجام شده‌اند و فقط یک قسمت نیاز به اصلاح دارد.»',
                        ),
                      ],
                      primaryButtonText: 'بررسی اطلاعات تکمیلی',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D24-03: Counter evidence form
                    _buildCounterEvidenceForm(),
                    // D24-04: Day end
                    DayEndPage(
                      title: 'پایان روز بیست\u200cوچهارم',
                      missionText:
                          'دیدن اطلاعات تکمیلی به معنای انکار مشکل نیست. هدف این است که فکر اولیه را با تمام اطلاعات موجود مقایسه کنیم.\n\nمأموریت: وقتی ذهن از واژه\u200cهایی مانند «همیشه»، «هرگز»، «کاملاً» یا «حتماً» استفاده می\u200cکند، به دنبال یک استثنا یا اطلاعات تکمیلی بگردید.',
                      notificationText:
                          'امروز بررسی کنید چه اطلاعاتی در فکر اولیه دیده نشده است.',
                      buttonText: 'پایان روز بیست\u200cوچهارم',
                      onButtonPressed: () {
                        context.read<Week4ViewModel>().completeDay(
                          weekNumber: 4,
                          dayNumber: 24,
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
  final _contraryCtrl = TextEditingController();
  final _exceptionCtrl = TextEditingController();
  final _alternativeCtrl = TextEditingController();
  final _fallbackThoughtCtrl = TextEditingController();
  bool _noCounterEvidence = false;

  bool get _canSubmit =>
      !_noCounterEvidence &&
      (_contraryCtrl.text.isNotEmpty ||
          _exceptionCtrl.text.isNotEmpty ||
          _alternativeCtrl.text.isNotEmpty);

  Widget _buildCounterEvidenceForm() {
    final vm = context.read<Week4ViewModel>();
    final selectedThought = vm.lastSelectedThought;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ثبت شواهد مخالف',
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
          // Field 1: Contrary evidence
          _buildLabel(
            'چه اطلاعاتی نشان می\u200cدهد این فکر ممکن است تمام واقعیت نباشد؟',
          ),
          TextField(
            controller: _contraryCtrl,
            maxLength: 200,
            maxLines: 2,
            enabled: !_noCounterEvidence,
            decoration: InputDecoration(
              hintText: 'اطلاعات مخالف...',
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
          // Field 2: Exception evidence
          _buildLabel(
            'آیا نمونه یا استثنایی وجود دارد که با این فکر کاملاً هماهنگ نباشد؟',
          ),
          TextField(
            controller: _exceptionCtrl,
            maxLength: 200,
            maxLines: 2,
            enabled: !_noCounterEvidence,
            decoration: InputDecoration(
              hintText: 'استثنا یا نمونه متفاوت...',
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
          // Field 3: Alternative explanation
          _buildLabel('آیا توضیح دیگری برای موقعیت ممکن است؟'),
          TextField(
            controller: _alternativeCtrl,
            maxLength: 200,
            maxLines: 2,
            enabled: !_noCounterEvidence,
            decoration: InputDecoration(
              hintText: 'توضیح جایگزین...',
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
          // Option: No counter evidence found
          InkWell(
            onTap: () => setState(() {
              _noCounterEvidence = !_noCounterEvidence;
              if (_noCounterEvidence) {
                _contraryCtrl.clear();
                _exceptionCtrl.clear();
                _alternativeCtrl.clear();
              }
            }),
            child: Row(
              children: [
                Checkbox(
                  value: _noCounterEvidence,
                  onChanged: (v) =>
                      setState(() => _noCounterEvidence = v ?? false),
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    'فعلاً اطلاعات تکمیلی پیدا نکردم.',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Message when no counter evidence selected
          if (_noCounterEvidence) ...[
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
                'پیدا نکردن اطلاعات مخالف در اولین تلاش طبیعی است. می\u200cتوانید فعلاً ادامه دهید و بعداً تمرین را مرور کنید.',
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
              onPressed: (_noCounterEvidence || _canSubmit)
                  ? _submitEvidence
                  : null,
              child: const Text('ثبت پاسخ\u200cها'),
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
      dayNumber: 24,
      exerciseType: 'counter_evidence',
      data: {
        'contrary_evidence': _contraryCtrl.text,
        'exception_evidence': _exceptionCtrl.text,
        'alternative_explanation': _alternativeCtrl.text,
        'no_counter_evidence_found': _noCounterEvidence,
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
