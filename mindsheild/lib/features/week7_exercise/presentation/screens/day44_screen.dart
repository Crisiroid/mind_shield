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
import '../view_models/week7_view_model.dart';

class Day44Screen extends StatefulWidget {
  const Day44Screen({super.key});

  @override
  State<Day44Screen> createState() => _Day44ScreenState();
}

class _Day44ScreenState extends State<Day44Screen> {
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
                  dayNumber: 44,
                  dayTitle: 'مشکل را روشن و محدود کنیم',
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
                    // D44-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week7ViewModel>().submitExerciseResponse(
                          weekNumber: 7,
                          dayNumber: 44,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D44-02: Characteristics of a precise problem
                    TextEducationPage(
                      title: 'مشکل مبهم، اقدام مبهم ایجاد می\u200cکند',
                      bodyText:
                          'وقتی مشکل بسیار کلی تعریف شود، پیداکردن راه\u200cحل دشوارتر می\u200cشود. تعریف دقیق باید مشخص کند اکنون چه اتفاقی افتاده، چه چیزی موردنیاز است و کدام بخش قابل تغییر است.',
                      cards: const [
                        InfoCard(
                          title: 'مثال مبهم',
                          text: 'اوضاع کار خیلی بد است.',
                        ),
                        InfoCard(
                          title: 'مثال دقیق\u200cتر',
                          text:
                              'برای تکمیل گزارش تا پایان فردا، اطلاعات دو بخش را هنوز دریافت نکرده\u200cام.',
                        ),
                        InfoCard(
                          title: 'مثال مبهم',
                          text: 'هیچ\u200cوقت نمی\u200cتوانم به کارهایم برسم.',
                        ),
                        InfoCard(
                          title: 'مثال دقیق\u200cتر',
                          text:
                              'در سه روز گذشته، دو کار غیرضروری را به\u200cدلیل خستگی به تعویق انداخته\u200cام.',
                        ),
                      ],
                      noteText: null,
                      primaryButtonText: 'مشکل خود را تعریف کنم',
                      onPrimaryButton: () => _goToPage(2),
                      imageWidget: _buildCharacteristicsCard(),
                    ),
                    // D44-03: Problem definition form
                    _buildProblemDefinitionForm(),
                    // D44-04: Day end
                    _buildDayEnd(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacteristicsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'چهار ویژگی تعریف دقیق',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          ...[
            'مشخص',
            'مربوط به زمان حال',
            'بدون برچسب\u200cزدن به خود یا دیگران',
            'دارای حداقل یک بخش قابل اقدام',
          ].map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.xs),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppColors.success),
                  SizedBox(width: AppSizes.xs),
                  Text(
                    item,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // D44-03 form state
  final _problemDescCtrl = TextEditingController();
  String? _problemImpact;
  final _desiredOutcomeCtrl = TextEditingController();
  final _controllableCtrl = TextEditingController();
  final _uncontrollableCtrl = TextEditingController();
  String? _selfReviewAnswer;

  final _impactOptions = [
    'تأخیر در انجام کار',
    'افزایش فشار',
    'تعارض یا سوءتفاهم',
    'کاهش تمرکز',
    'هزینه یا محدودیت مالی',
    'مشکل در برنامه روزانه',
    'پیامد دیگر',
    'مطمئن نیستم',
  ];

  final _selfReviewOptions = ['خیر', 'بله', 'مطمئن نیستم'];

  bool get _canSubmitForm =>
      _problemDescCtrl.text.trim().isNotEmpty &&
      _problemImpact != null &&
      _desiredOutcomeCtrl.text.trim().isNotEmpty &&
      _controllableCtrl.text.trim().isNotEmpty &&
      _selfReviewAnswer != null;

  Widget _buildProblemDefinitionForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تعریف مشکل',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Text(
              'شرح کلی کافی است. اطلاعات هویتی یا سازمانی وارد نکنید.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                height: 1.6,
                color: AppColors.info,
              ),
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Q1
          Text(
            'اکنون دقیقاً چه اتفاقی افتاده است؟',
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
            controller: _problemDescCtrl,
            maxLength: 200,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'فقط واقعیت\u200cهای اصلی و قابل مشاهده را بنویسید.',
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
          SizedBox(height: AppSizes.lg),
          // Q2
          Text(
            'این موضوع چه پیامدی برای شما ایجاد کرده است؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._impactOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _problemImpact,
              (v) => setState(() => _problemImpact = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3
          Text(
            'چه نتیجه مشخص و واقع\u200cبینانه\u200cای می\u200cخواهید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'حداکثر ۱۵۰ کاراکتر. مثال: اطلاعات لازم را تا فردا دریافت کنم.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: _desiredOutcomeCtrl,
            maxLength: 150,
            maxLines: 2,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'نتیجه موردنظر...',
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
          SizedBox(height: AppSizes.lg),
          // Q4
          Text(
            'کدام بخش تحت کنترل یا تأثیر شماست؟',
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
            controller: _controllableCtrl,
            maxLength: 150,
            maxLines: 2,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'بخش قابل کنترل...',
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
          SizedBox(height: AppSizes.lg),
          // Q5
          Text(
            'کدام بخش خارج از کنترل مستقیم شماست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'حداکثر ۱۵۰ کاراکتر، اختیاری',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: _uncontrollableCtrl,
            maxLength: 150,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'بخش خارج از کنترل...',
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
          SizedBox(height: AppSizes.lg),
          // Self-review
          Text(
            'آیا تعریف شما شامل واژه\u200cهای کلی مانند «همیشه»، «هیچ\u200cوقت»، «همه\u200cچیز» یا یک برچسب درباره خود و دیگران است؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._selfReviewOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _selfReviewAnswer,
              (v) => setState(() => _selfReviewAnswer = v),
            ),
          ),
          if (_selfReviewAnswer == 'بله') ...[
            SizedBox(height: AppSizes.md),
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
                'تلاش کنید فقط موقعیت فعلی و رفتار یا اتفاق مشخص را توصیف کنید.',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitForm ? _submitForm : null,
              child: const Text('ثبت تعریف مشکل'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildDayEnd() {
    final vm = context.read<Week7ViewModel>();
    final problem = vm.problemDefinition;
    return DayEndPage(
      title: 'پایان روز چهل\u200cوچهارم',
      feedbackText: problem != null
          ? 'مشکل: ${problem['problem_description']}\nنتیجه موردنظر: ${problem['desired_outcome']}\n\nتعریف دقیق مشکل، بخشی از حل آن است. امروز هنوز لازم نیست راه\u200cحل نهایی پیدا کنید.'
          : 'تعریف دقیق مشکل، بخشی از حل آن است. امروز هنوز لازم نیست راه\u200cحل نهایی پیدا کنید.',
      missionText:
          'بررسی کنید آیا نتیجه موردنظر شما مشخص، واقع\u200cبینانه و تا حدی قابل تأثیر است.',
      notificationText:
          'امروز یک مشکل مبهم را به شکل دقیق و قابل اقدام تعریف کنید.',
      buttonText: 'پایان روز چهل\u200cوچهارم',
      onButtonPressed: () {
        vm.completeDay(weekNumber: 7, dayNumber: 44);
        Navigator.of(context).pop();
      },
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

  void _submitForm() {
    context.read<Week7ViewModel>().submitExerciseResponse(
      weekNumber: 7,
      dayNumber: 44,
      exerciseType: 'problem_definition',
      data: {
        'problem_description': _problemDescCtrl.text.trim(),
        'problem_impact': _problemImpact,
        'desired_outcome': _desiredOutcomeCtrl.text.trim(),
        'controllable_part': _controllableCtrl.text.trim(),
        'uncontrollable_part': _uncontrollableCtrl.text.trim().isNotEmpty
            ? _uncontrollableCtrl.text.trim()
            : null,
      },
    );
    _goToPage(3);
  }
}
