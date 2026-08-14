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
import '../view_models/week5_view_model.dart';

class Day29Screen extends StatefulWidget {
  const Day29Screen({super.key});

  @override
  State<Day29Screen> createState() => _Day29ScreenState();
}

class _Day29ScreenState extends State<Day29Screen> {
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
                  dayNumber: 29,
                  dayTitle: 'فعالیت چه اثری دارد؟',
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
                    // D29-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week5ViewModel>().submitExerciseResponse(
                          weekNumber: 5,
                          dayNumber: 29,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D29-02: Activity-mood cycle education
                    TextEducationPage(
                      title: 'وقتی حال یا انرژی پایین است',
                      bodyText:
                          'هنگامی که خلق یا انرژی کاهش پیدا می\u200cکند، طبیعی است که فرد برخی فعالیت\u200cها را کمتر انجام دهد، کارها را به تعویق بیندازد یا از دیگران فاصله بگیرد.\n\nاین کاهش فعالیت ممکن است در کوتاه\u200cمدت فشار را کمتر کند؛ اما اگر ادامه پیدا کند، فرصت تجربه لذت، ارتباط، پیشرفت و احساس توانمندی نیز کاهش می\u200cیابد. در نتیجه، خلق و انرژی ممکن است پایین\u200cتر بماند.',
                      imageWidget: _buildW5Img01(),
                      noteText:
                          'فعال\u200cسازی رفتاری به معنای پرکردن تمام زمان یا مجبورکردن خود به فعالیت زیاد نیست. هدف، افزودن تدریجی فعالیت\u200cهای کوچک و قابل اجراست.',
                      cards: const [
                        InfoCard(
                          title: 'مهم',
                          text:
                              'گاهی لازم نیست انگیزه پیش از فعالیت ایجاد شود؛ ممکن است انگیزه پس از شروع یک قدم کوچک افزایش یابد.',
                        ),
                      ],
                      primaryButtonText: 'الگوی خود را بررسی کنم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D29-03: Behavior pattern checklist
                    _buildBehaviorPatternForm(),
                    // D29-04: Day end
                    DayEndPage(
                      title: 'پایان روز بیست\u200cونهم',
                      feedbackText:
                          'شناخت چرخه فعالیت و خلق، مقدمه تغییر آن است. هدف امروز سرزنش\u200cکردن خود نبود؛ فقط الگوی رفتاری را مشاهده کردید.',
                      missionText:
                          'امروز توجه کنید آیا کاری را فقط به دلیل نداشتن انگیزه به تعویق می\u200cاندازید.',
                      notificationText:
                          'امروز ارتباط میان فعالیت، انرژی و خلق را بررسی کنید.',
                      buttonText: 'پایان روز بیست\u200cونهم',
                      onButtonPressed: () {
                        context.read<Week5ViewModel>().completeDay(
                          weekNumber: 5,
                          dayNumber: 29,
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

  // D29-03 form state
  final Set<String> _selectedPatterns = {};
  final _otherPatternCtrl = TextEditingController();
  String? _patternEffect;

  final _behaviorOptions = [
    'کارها را به تعویق می\u200cاندازم.',
    'فقط کارهای کاملاً ضروری را انجام می\u200cدهم.',
    'از دیگران فاصله می\u200cگیرم.',
    'مدت زیادی در تلفن همراه یا فضای مجازی می\u200cمانم.',
    'بیشتر دراز می\u200cکشم یا می\u200cخوابم.',
    'فعالیت\u200cهای لذت\u200cبخش را کنار می\u200cگذارم.',
    'در شروع کارها مشکل پیدا می\u200cکنم.',
    'کارها را شروع می\u200cکنم، اما زود رها می\u200cکنم.',
    'تحریک\u200cپذیرتر می\u200cشوم.',
    'تغییر مشخصی متوجه نشده\u200cام.',
    'الگوی دیگری دارم.',
  ];

  final _effectOptions = [
    'موقتاً فشار را کمتر می\u200cکند.',
    'حال یا انرژی را پایین\u200cتر می\u200cآورد.',
    'ابتدا کمک می\u200cکند، اما بعد مشکل ایجاد می\u200cکند.',
    'اثر مشخصی متوجه نشده\u200cام.',
    'مطمئن نیستم.',
  ];

  bool get _hasOtherPattern => _selectedPatterns.contains('الگوی دیگری دارم.');

  bool get _canSubmitPatterns =>
      _selectedPatterns.isNotEmpty && _patternEffect != null;

  Widget _buildBehaviorPatternForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الگوی من هنگام کاهش انرژی',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'وقتی خلق یا انرژی شما پایین است، بیشتر چه تغییری در رفتارتان ایجاد می\u200cشود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'حداکثر سه انتخاب',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.md),
          ..._behaviorOptions.map((item) {
            final isSelected = _selectedPatterns.contains(item);
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
                        _selectedPatterns.remove(item);
                      } else if (_selectedPatterns.length < 3) {
                        _selectedPatterns.add(item);
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
          // Other pattern text field
          if (_hasOtherPattern) ...[
            SizedBox(height: AppSizes.md),
            Text(
              'الگوی خود را کوتاه بنویسید:',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.xs),
            TextField(
              controller: _otherPatternCtrl,
              maxLength: 150,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'الگوی خود را بنویسید...',
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
          // Second question: pattern effect
          Text(
            'این الگو معمولاً چه اثری بر حال شما دارد؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._effectOptions.map((opt) {
            final isSelected = _patternEffect == opt;
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.xs),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: () => setState(() => _patternEffect = opt),
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
                          groupValue: _patternEffect,
                          onChanged: (v) => setState(() => _patternEffect = v),
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
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitPatterns ? _submitPatterns : null,
              child: const Text('ثبت پاسخ'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _submitPatterns() {
    context.read<Week5ViewModel>().submitExerciseResponse(
      weekNumber: 5,
      dayNumber: 29,
      exerciseType: 'activity_mood_cycle',
      data: {
        'low_mood_behavior_patterns': _selectedPatterns.toList(),
        'perceived_pattern_effect': _patternEffect,
        'other_pattern_text': _hasOtherPattern ? _otherPatternCtrl.text : null,
      },
    );
    _goToPage(3);
  }

  Widget _buildW5Img01() {
    return Image.asset(
      'assets/images/week5/w5_img_01.png',
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
            _buildFlowStep('خلق و انرژی پایین'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('کاهش فعالیت و کناره\u200cگیری'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('کاهش تجربه لذت و پیشرفت'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('خلق و انرژی پایین\u200cتر'),
            SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_upward, size: 16, color: AppColors.success),
                  SizedBox(width: 4),
                  Text(
                    'یک فعالیت کوچک و برنامه\u200cریزی\u200cشده',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontXs,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStep(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: PersianFonts.Vazir.copyWith(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
