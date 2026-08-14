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

class Day43Screen extends StatefulWidget {
  const Day43Screen({super.key});

  @override
  State<Day43Screen> createState() => _Day43ScreenState();
}

class _Day43ScreenState extends State<Day43Screen> {
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
                  dayNumber: 43,
                  dayTitle: 'آیا این موضوع قابل\u200cحل است؟',
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
                    // D43-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week7ViewModel>().submitExerciseResponse(
                          weekNumber: 7,
                          dayNumber: 43,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D43-02: What is problem solving?
                    TextEducationPage(
                      title:
                          'ابتدا مشخص می\u200cکنیم با چه نوع موضوعی روبه\u200cرو هستیم',
                      bodyText:
                          'حل مسئله زمانی کاربرد دارد که موضوعی نسبتاً مشخص وجود داشته باشد و بتوان برای حداقل بخشی از آن اقدام عملی انجام داد.\n\nبرخی نگرانی\u200cها بیشتر به شکل «اگر اتفاق بدی بیفتد چه؟» ظاهر می\u200cشوند و در حال حاضر اقدام مشخصی برای آن\u200cها وجود ندارد. تلاش مکرر برای حل چنین نگرانی\u200cهایی ممکن است فقط ذهن را درگیرتر کند.',
                      imageWidget: _buildW7Img01(),
                      noteText:
                          'بعضی موضوع\u200cها ترکیبی\u200cاند. ممکن است نتوانید کل موضوع را کنترل کنید، اما بخشی از آن قابل اقدام باشد.',
                      cards: const [
                        InfoCard(
                          title: 'مثال مشکل قابل\u200cحل',
                          text:
                              'برای تکمیل یک کار، اطلاعات یک بخش در اختیار من نیست.\nاقدام ممکن: مشخص\u200cکردن اطلاعات موردنیاز و درخواست آن از مسیر مناسب.',
                        ),
                        InfoCard(
                          title: 'مثال نگرانی فرضی',
                          text:
                              'اگر در آینده هیچ\u200cوقت نتوانم مسئولیت\u200cهایم را درست انجام دهم چه؟',
                        ),
                      ],
                      primaryButtonText: 'موضوع خود را بررسی کنم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D43-03: Problem or worry?
                    _buildProblemOrWorryForm(),
                    // D43-04: Day end
                    DayEndPage(
                      title: 'پایان روز چهل\u200cوسوم',
                      feedbackText:
                          'همه نگرانی\u200cها با حل مسئله پاسخ داده نمی\u200cشوند. امروز فقط بررسی کردید آیا اکنون یک اقدام عملی وجود دارد یا خیر.',
                      missionText:
                          'در صورت تکرار یک نگرانی، از خود بپرسید:\n«آیا اکنون کاری مشخص و قابل انجام وجود دارد؟»',
                      notificationText:
                          'امروز بررسی کنید با یک مشکل قابل\u200cحل روبه\u200cرو هستید یا یک نگرانی فرضی.',
                      buttonText: 'پایان روز چهل\u200cوسوم',
                      onButtonPressed: () {
                        context.read<Week7ViewModel>().completeDay(
                          weekNumber: 7,
                          dayNumber: 43,
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

  // D43-03 form state
  final _quizAnswers = <int, String?>{};
  String? _issueType;
  String? _degreeOfControl;
  String? _issueCategory;

  final _quizQuestions = [
    _QuizQuestionData(
      question: '«برای انجام کار فردا، هنوز زمان دقیق جلسه مشخص نشده است.»',
      options: ['مشکل قابل\u200cحل', 'نگرانی فرضی', 'مطمئن نیستم'],
      correctAnswer: 'مشکل قابل\u200cحل',
      feedback: 'می\u200cتوان زمان جلسه را از مسیر مناسب پیگیری کرد.',
    ),
    _QuizQuestionData(
      question: '«اگر در تمام موقعیت\u200cهای آینده شکست بخورم چه؟»',
      options: ['مشکل قابل\u200cحل', 'نگرانی فرضی', 'مطمئن نیستم'],
      correctAnswer: 'نگرانی فرضی',
      feedback: 'این بیشتر یک نگرانی درباره آینده است تا مشکل مشخص.',
    ),
    _QuizQuestionData(
      question: '«برای پرداخت هزینه این ماه، بخشی از مبلغ را کم دارم.»',
      options: ['مشکل قابل\u200cحل', 'نگرانی فرضی', 'مطمئن نیستم'],
      correctAnswer: 'مشکل قابل\u200cحل',
      feedback:
          'حل این مسئله ممکن است دشوار باشد، اما موضوع مشخص است و می\u200cتوان گزینه\u200cهای عملی را بررسی کرد.',
    ),
  ];

  final _issueTypeOptions = [
    'یک مشکل مشخص و فعلی',
    'نگرانی درباره اتفاق احتمالی آینده',
    'ترکیبی از هر دو',
    'مطمئن نیستم',
    'فعلاً موضوعی ثبت نمی\u200cکنم',
  ];

  final _controlOptions = ['بله', 'تا حدی', 'خیر', 'مطمئن نیستم'];

  final _categoryOptions = [
    'حجم یا زمان کار',
    'کمبود اطلاعات',
    'ارتباط با دیگران',
    'مسئولیت خانوادگی',
    'تصمیم شخصی',
    'سلامت و مراقبت از خود',
    'امور مالی',
    'حوزه دیگر',
    'ترجیح می\u200cدهم پاسخ ندهم',
  ];

  bool get _canSubmitForm {
    if (_issueType == null || _issueType == 'فعلاً موضوعی ثبت نمی\u200cکنم') {
      return _issueType != null;
    }
    return _issueType != null &&
        _degreeOfControl != null &&
        _issueCategory != null;
  }

  Widget _buildProblemOrWorryForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مشکل یا نگرانی؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Educational quiz questions
          ...List.generate(_quizQuestions.length, (qi) {
            final q = _quizQuestions[qi];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سؤال آموزشی ${qi + 1}',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textHint,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  q.question,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                    height: 1.7,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                ...q.options.map((opt) {
                  final isSelected = _quizAnswers[qi] == opt;
                  return Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: AppSizes.xs),
                    child: Material(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      child: InkWell(
                        onTap: () => setState(() => _quizAnswers[qi] = opt),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                            vertical: AppSizes.xs,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
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
                                groupValue: _quizAnswers[qi],
                                onChanged: (v) =>
                                    setState(() => _quizAnswers[qi] = v),
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
                if (_quizAnswers[qi] != null) ...[
                  SizedBox(height: AppSizes.xs),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSizes.sm),
                    decoration: BoxDecoration(
                      color: _quizAnswers[qi] == q.correctAnswer
                          ? AppColors.success.withValues(alpha: 0.08)
                          : AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Text(
                      _quizAnswers[qi] == q.correctAnswer
                          ? 'صحیح! ${q.feedback}'
                          : 'پاسخ پیشنهادی: ${q.correctAnswer}. ${q.feedback}',
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontXs,
                        height: 1.6,
                        color: _quizAnswers[qi] == q.correctAnswer
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: AppSizes.lg),
              ],
            );
          }),
          // Personal exercise
          Text(
            'تمرین شخصی',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'موضوعی که می\u200cخواهید بررسی کنید بیشتر به کدام نوع است؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._issueTypeOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _issueType,
              (v) => setState(() => _issueType = v),
            ),
          ),
          if (_issueType != null &&
              _issueType != 'فعلاً موضوعی ثبت نمی\u200cکنم' &&
              _issueType != 'مطمئن نیستم') ...[
            SizedBox(height: AppSizes.lg),
            Text(
              'آیا بخشی از موضوع تحت کنترل یا تأثیر شماست؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            ..._controlOptions.map(
              (opt) => _buildRadioTile(
                opt,
                _degreeOfControl,
                (v) => setState(() => _degreeOfControl = v),
              ),
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              'موضوع بیشتر به کدام حوزه مربوط است؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            ..._categoryOptions.map(
              (opt) => _buildRadioTile(
                opt,
                _issueCategory,
                (v) => setState(() => _issueCategory = v),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitForm ? _submitForm : null,
              child: const Text('ثبت پاسخ'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
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

  void _submitForm() {
    int quizScore = 0;
    for (int i = 0; i < _quizQuestions.length; i++) {
      if (_quizAnswers[i] == _quizQuestions[i].correctAnswer) quizScore++;
    }
    context.read<Week7ViewModel>().submitExerciseResponse(
      weekNumber: 7,
      dayNumber: 43,
      exerciseType: 'problem_or_worry',
      data: {
        'issue_type': _issueType,
        'degree_of_control': _degreeOfControl,
        'issue_category': _issueCategory,
        'problem_worry_quiz_score': quizScore,
      },
    );
    _goToPage(3);
  }

  Widget _buildW7Img01() {
    return Image.asset(
      'assets/images/week7/w7_img_01.png',
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
            _buildFlowStep('تعریف مشکل'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('تولید راه\u200cحل\u200cها'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('ارزیابی'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('انتخاب و برنامه'),
            const Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColors.textHint,
            ),
            _buildFlowStep('اجرا و مرور'),
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

class _QuizQuestionData {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String feedback;

  const _QuizQuestionData({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.feedback,
  });
}
