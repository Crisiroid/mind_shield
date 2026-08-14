import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week3_view_model.dart';

class Day18Screen extends StatefulWidget {
  const Day18Screen({super.key});

  @override
  State<Day18Screen> createState() => _Day18ScreenState();
}

class _Day18ScreenState extends State<Day18Screen> {
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
    _optionalTextCtrl.dispose();
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
                  dayNumber: 18,
                  dayTitle: 'پیش\u200cبینی منفی',
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
                    // D18-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week3ViewModel>().submitExerciseResponse(
                          weekNumber: 3,
                          dayNumber: 18,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D18-02: Negative prediction
                    TextEducationPage(
                      title: 'نتیجه\u200cگیری درباره آینده بدون اطلاعات کافی',
                      bodyText:
                          'در پیش\u200cبینی منفی، ذهن نتیجه نامطلوبی را برای آینده تقریباً قطعی در نظر می\u200cگیرد؛ در حالی که هنوز اطلاعات کافی وجود ندارد.',
                      cards: const [
                        InfoCard(
                          title: 'مثال',
                          text: '«حتماً جلسه بد پیش می\u200cرود.»',
                        ),
                        InfoCard(
                          title: 'مثال',
                          text: '«مطمئنم نمی\u200cتوانم این کار را تمام کنم.»',
                        ),
                      ],
                      noteText:
                          'پیش\u200cبینی ممکن است درست یا نادرست باشد؛ مسئله اصلی، قطعی\u200cدانستن نتیجه بدون بررسی اطلاعات است.',
                      primaryButtonText: 'ادامه',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D18-03: Catastrophizing
                    TextEducationPage(
                      title:
                          'وقتی بدترین پیامد، تنها پیامد ممکن به نظر می\u200cرسد',
                      bodyText:
                          'در فاجعه\u200cسازی، ذهن احتمال یا پیامد یک اتفاق منفی را بسیار بزرگ می\u200cبیند و توانایی مقابله با آن را کم\u200cارزیابی می\u200cکند.',
                      cards: const [
                        InfoCard(
                          title: 'مثال',
                          text:
                              '«اگر در جلسه اشتباه کنم، همه\u200cچیز از بین می\u200cرود و دیگر نمی\u200cتوانم آن را جبران کنم.»',
                        ),
                        InfoCard(
                          title: 'فکر دشوار اما دقیق\u200cتر',
                          text:
                              '«اشتباه در جلسه ناخوشایند است و ممکن است پیامدی داشته باشد؛ اما احتمالاً راه\u200cهایی برای اصلاح یا توضیح آن وجود دارد.»',
                        ),
                      ],
                      noteText:
                          'در این هفته هنوز قرار نیست فکر جایگزین بنویسید. فقط الگو را شناسایی می\u200cکنیم.',
                      primaryButtonText: 'ادامه',
                      onPrimaryButton: () => _goToPage(3),
                    ),
                    // D18-04: Quiz + personal exercise + end
                    _buildExerciseAndEnd(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _q1Answer;
  int? _q2Answer;
  String? _hasNegativePrediction;
  final _optionalTextCtrl = TextEditingController();

  Widget _buildExerciseAndEnd() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تمرین شخصی',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q1
          Text(
            'سؤال ۱: کدام جمله نمونه پیش\u200cبینی منفی است؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ...[
            'جلسه فردا ساعت ده برگزار می\u200cشود.',
            'حتماً جلسه فردا بد پیش می\u200cرود.',
            'من درباره جلسه نگرانم.',
            'ضربان قلبم افزایش یافته است.',
          ].asMap().entries.map(
            (e) => _buildRadioOption(
              e.value,
              _q1Answer == e.key ? e.value : null,
              (_) => setState(() => _q1Answer = e.key),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2
          Text(
            'سؤال ۲: کدام جمله بیشتر به فاجعه\u200cسازی شباهت دارد؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ...[
            'این اشتباه نیاز به اصلاح دارد.',
            'اگر اشتباه کنم، همه\u200cچیز نابود می\u200cشود.',
            'ممکن است بازخورد منفی دریافت کنم.',
            'درباره نتیجه مطمئن نیستم.',
          ].asMap().entries.map(
            (e) => _buildRadioOption(
              e.value,
              _q2Answer == e.key ? e.value : null,
              (_) => setState(() => _q2Answer = e.key),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3 - Optional personal
          Text(
            'سؤال ۳: آیا امروز یا اخیراً یک پیش\u200cبینی منفی متوجه شده\u200cاید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ...['بله', 'خیر', 'مطمئن نیستم'].map(
            (opt) => _buildRadioOption(
              opt,
              _hasNegativePrediction,
              (v) => setState(() => _hasNegativePrediction = v),
            ),
          ),
          if (_hasNegativePrediction == 'بله') ...[
            SizedBox(height: AppSizes.md),
            Text(
              'فکر را کوتاه بنویسید (حداکثر ۲۰۰ کاراکتر):',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSizes.xs),
            TextField(
              controller: _optionalTextCtrl,
              maxLength: 200,
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
            ),
          ],
          SizedBox(height: AppSizes.lg),
          // End message
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              'ذهن هنگام فشار ممکن است آینده را قطعی و تهدیدآمیز ببیند. شناسایی این الگو، اولین قدم برای بررسی دقیق\u200cتر آن است.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit() ? _submitAndComplete : null,
              child: const Text('پایان روز هجدهم'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  bool _canSubmit() =>
      _q1Answer != null && _q2Answer != null && _hasNegativePrediction != null;

  void _submitAndComplete() {
    int score = 0;
    if (_q1Answer == 1) score++;
    if (_q2Answer == 1) score++;

    context.read<Week3ViewModel>().submitExerciseResponse(
      weekNumber: 3,
      dayNumber: 18,
      exerciseType: 'negative_prediction_catastrophizing',
      data: {
        'score': score,
        'total': 2,
        'has_negative_prediction': _hasNegativePrediction,
        'optional_text': _optionalTextCtrl.text.isNotEmpty
            ? _optionalTextCtrl.text
            : null,
      },
    );

    context.read<Week3ViewModel>().completeDay(weekNumber: 3, dayNumber: 18);
    Navigator.of(context).pop();
  }

  Widget _buildRadioOption(
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
}
