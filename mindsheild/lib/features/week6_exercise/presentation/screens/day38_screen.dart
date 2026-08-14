import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week6_view_model.dart';

class Day38Screen extends StatefulWidget {
  const Day38Screen({super.key});

  @override
  State<Day38Screen> createState() => _Day38ScreenState();
}

class _Day38ScreenState extends State<Day38Screen> {
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
                  dayNumber: 38,
                  dayTitle: 'متوجه می\u200cشوم که...',
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
                    // D38-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week6ViewModel>().submitExerciseResponse(
                          weekNumber: 6,
                          dayNumber: 38,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D38-02: Naming thoughts education
                    TextEducationPage(
                      title: 'یک تغییر کوچک در جمله',
                      bodyText:
                          'بعضی افکار به\u200cصورت حقیقت قطعی بیان می\u200cشوند:\n«من نمی\u200cتوانم این موقعیت را مدیریت کنم.»\n\nبرای ایجاد فاصله کوتاه می\u200cتوانیم جمله را این\u200cگونه بیان کنیم:\n«متوجه می\u200cشوم که این فکر را دارم که نمی\u200cتوانم این موقعیت را مدیریت کنم.»',
                      cards: const [
                        InfoCard(
                          title: 'مهم',
                          text:
                              'این تغییر جمله، فکر را درست یا نادرست اعلام نمی\u200cکند. فقط یادآوری می\u200cکند که اکنون با یک فکر روبه\u200cرو هستیم.',
                        ),
                        InfoCard(
                          title: 'مثال دوم',
                          text:
                              'فکر اولیه: «حتماً اتفاق بدی می\u200cافتد.»\nعبارت فاصله\u200cگذار: «متوجه می\u200cشوم که ذهن من پیش\u200cبینی می\u200cکند اتفاق بدی می\u200cافتد.»',
                        ),
                      ],
                      primaryButtonText: 'تمرین کنیم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D38-03: Personal practice form
                    _buildPersonalPracticeForm(),
                    // D38-04: Day end
                    DayEndPage(
                      title: 'پایان روز سی\u200cوهشتم',
                      missionText:
                          'امروز هنگام ظاهرشدن یک فکر تکراری، جمله را با این عبارت آغاز کنید:\n«متوجه می\u200cشوم که این فکر را دارم که...»',
                      notificationText:
                          'امروز یک فکر را با عبارت «متوجه می\u200cشوم...» نام\u200cگذاری کنید.',
                      buttonText: 'پایان روز سی\u200cوهشتم',
                      onButtonPressed: () {
                        context.read<Week6ViewModel>().completeDay(
                          weekNumber: 6,
                          dayNumber: 38,
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

  // D38-03 form state
  String? _thoughtCategory;
  final _thoughtTextCtrl = TextEditingController();
  String? _distancingExperience;
  bool _showDistancingPhrase = false;

  final _categoryOptions = [
    'نگرانی درباره آینده',
    'خودانتقادی',
    'فکر مربوط به اشتباه',
    'فکر درباره نظر دیگران',
    'باید یا نباید ذهنی',
    'فکر دیگری',
    'فعلاً فکری ثبت نمی\u200cکنم',
  ];

  final _experienceOptions = [
    'کمی فاصله ایجاد شد.',
    'تفاوتی متوجه نشدم.',
    'فکر همچنان بسیار واقعی بود.',
    'ناراحتی بیشتر شد.',
    'مطمئن نیستم.',
  ];

  bool get _canSubmitPractice =>
      _thoughtCategory != null && _distancingExperience != null;

  String get _distancingPhrase {
    final text = _thoughtTextCtrl.text.trim();
    if (text.isEmpty) return '';
    if (text.startsWith('من...') || text.startsWith('من ')) {
      return 'متوجه می\u200cشوم که این فکر را دارم که: «$text»';
    }
    return 'متوجه می\u200cشوم که این فکر را دارم که: «$text»';
  }

  Widget _buildPersonalPracticeForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Safety text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'یک فکر خفیف یا متوسط و غیرمحرمانه انتخاب کنید.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q1: Thought category
          Text(
            'کدام نوع فکر را متوجه شده\u200cاید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._categoryOptions.map((opt) {
            final isSelected = _thoughtCategory == opt;
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.xs),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: () => setState(() => _thoughtCategory = opt),
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
                          groupValue: _thoughtCategory,
                          onChanged: (v) =>
                              setState(() => _thoughtCategory = v),
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
          SizedBox(height: AppSizes.lg),
          // Q2: Thought text (optional)
          if (_thoughtCategory != null &&
              _thoughtCategory != 'فعلاً فکری ثبت نمی\u200cکنم') ...[
            Text(
              'فکر را کوتاه بنویسید:',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              'حداکثر ۱۵۰ کاراکتر',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                color: AppColors.textHint,
              ),
            ),
            SizedBox(height: AppSizes.xs),
            TextField(
              controller: _thoughtTextCtrl,
              maxLength: 150,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'فکر خود را بنویسید...',
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
              onChanged: (_) => setState(() {}),
            ),
            // Auto-display distancing phrase
            if (_thoughtTextCtrl.text.trim().isNotEmpty) ...[
              SizedBox(height: AppSizes.md),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عبارت فاصله\u200cگذار:',
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontXs,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(height: AppSizes.xs),
                    Text(
                      _distancingPhrase,
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontSm,
                        height: 1.7,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: AppSizes.lg),
          ],
          // Q3: Distancing experience
          Text(
            'پس از خواندن جمله دوم، چه تغییری متوجه شدید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._experienceOptions.map((opt) {
            final isSelected = _distancingExperience == opt;
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.xs),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: () => setState(() => _distancingExperience = opt),
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
                          groupValue: _distancingExperience,
                          onChanged: (v) =>
                              setState(() => _distancingExperience = v),
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
          SizedBox(height: AppSizes.md),
          // Message
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              'هدف، ازبین\u200cبردن فکر یا کاهش فوری ناراحتی نیست. حتی یادآوری اینکه «این یک فکر است» می\u200cتواند بخشی از تمرین باشد.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitPractice ? _submitPractice : null,
              child: const Text('ثبت و ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _submitPractice() {
    context.read<Week6ViewModel>().submitExerciseResponse(
      weekNumber: 6,
      dayNumber: 38,
      exerciseType: 'thought_labeling',
      data: {
        'thought_category': _thoughtCategory,
        'optional_thought_text':
            _thoughtCategory != 'فعلاً فکری ثبت نمی\u200cکنم'
            ? _thoughtTextCtrl.text.trim()
            : null,
        'distancing_experience': _distancingExperience,
      },
    );
    _goToPage(3);
  }
}
