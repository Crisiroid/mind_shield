import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/stress_slider_page.dart';
import '../../../week1_exercise/presentation/widgets/multi_choice_quiz_page.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week7_view_model.dart';

class Day48Screen extends StatefulWidget {
  const Day48Screen({super.key});

  @override
  State<Day48Screen> createState() => _Day48ScreenState();
}

class _Day48ScreenState extends State<Day48Screen> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalSteps = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _factCtrl.addListener(_updateCombinedSentence);
    _needCtrl.addListener(_updateCombinedSentence);
    _requestCtrl.addListener(_updateCombinedSentence);
  }

  String _combinedSentence = '';

  void _updateCombinedSentence() {
    final fact = _factCtrl.text.trim();
    final need = _needCtrl.text.trim();
    final request = _requestCtrl.text.trim();
    if (fact.isNotEmpty && need.isNotEmpty && request.isNotEmpty) {
      setState(() {
        _combinedSentence =
            'وقتی $fact، $need. درخواست من این است که $request.';
      });
    } else {
      setState(() => _combinedSentence = '');
    }
  }

  @override
  void dispose() {
    _factCtrl.removeListener(_updateCombinedSentence);
    _needCtrl.removeListener(_updateCombinedSentence);
    _requestCtrl.removeListener(_updateCombinedSentence);
    _factCtrl.dispose();
    _needCtrl.dispose();
    _requestCtrl.dispose();
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
                  dayNumber: 48,
                  dayTitle: 'درخواست روشن و محترمانه',
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
                    // D48-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week7ViewModel>().submitExerciseResponse(
                          weekNumber: 7,
                          dayNumber: 48,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D48-02: Three communication styles
                    TextEducationPage(
                      title: 'قاطعانه، نه منفعل و نه پرخاشگرانه',
                      bodyText:
                          'گاهی اجرای راه\u200cحل به مطرح\u200cکردن یک سؤال، نیاز، محدودیت یا درخواست وابسته است.\n\nارتباط قاطعانه یعنی بیان روشن و محترمانه موضوع، بدون نادیده\u200cگرفتن حقوق خود یا دیگری.',
                      cards: const [
                        InfoCard(
                          title: 'انفعالی',
                          text:
                              'موضوع را بیان نمی\u200cکنم، حتی وقتی بیان آن ضروری و مجاز است.',
                        ),
                        InfoCard(
                          title: 'پرخاشگرانه',
                          text:
                              'موضوع را با سرزنش، تهدید، تحقیر یا فشار بیان می\u200cکنم.',
                        ),
                        InfoCard(
                          title: 'قاطعانه',
                          text:
                              'واقعیت را مشخص، اثر آن را کوتاه و درخواست خود را روشن و محترمانه مطرح می\u200cکنم.',
                        ),
                      ],
                      noteText:
                          'در محیط کاری، درخواست باید از مسیر مجاز، با رعایت سلسله\u200cمراتب و بدون افشای اطلاعات محرمانه مطرح شود.',
                      primaryButtonText: 'تمرین کنیم',
                      onPrimaryButton: () => _goToPage(2),
                      imageWidget: _buildCommunicationStylesImage(),
                    ),
                    // D48-03: Assertive communication practice
                    _buildAssertiveForm(),
                    // D48-04: Day end
                    DayEndPage(
                      title: 'پایان روز چهل\u200cوهشتم',
                      feedbackText:
                          'ارتباط قاطعانه احتمال فهم روشن\u200cتر درخواست را افزایش می\u200cدهد، اما موافقت طرف مقابل را تضمین نمی\u200cکند. پس از پاسخ، ممکن است لازم باشد راه\u200cحل یا برنامه خود را اصلاح کنید.',
                      missionText:
                          'پیش از یک گفت\u200cوگوی مجاز و غیرحساس، جمله خود را یک بار آرام مرور کنید.',
                      notificationText:
                          'امروز یک درخواست روشن، محترمانه و واقع\u200cبینانه را تمرین کنید.',
                      buttonText: 'پایان روز چهل\u200cوهشتم',
                      onButtonPressed: () {
                        context.read<Week7ViewModel>().completeDay(
                          weekNumber: 7,
                          dayNumber: 48,
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

  Widget _buildCommunicationStylesImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // W7-IMG-03: Three communication styles
        Image.asset(
          'assets/images/week7/w7_img_03.png',
          height: 180,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(
              'سه سبک ارتباطی: انفعالی، پرخاشگرانه، قاطعانه',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSizes.md),
        _buildStructureCard(),
      ],
    );
  }

  Widget _buildStructureCard() {
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
            'ساختار پیشنهادی',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'وقتی [واقعیت مشخص] اتفاق می\u200cافتد، [پیامد یا نیاز] ایجاد می\u200cشود. درخواست من این است که [درخواست روشن و واقع\u200cبینانه].',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'مثال عمومی:',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'وقتی زمان تحویل تغییر می\u200cکند و اطلاع کافی ندارم، برنامه\u200cریزی کار دشوار می\u200cشود. درخواست من این است که در صورت امکان، زمان جدید مشخص شود.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              height: 1.6,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // D48-03 form state
  String? _communicationTopic;
  final _factCtrl = TextEditingController();
  final _needCtrl = TextEditingController();
  final _requestCtrl = TextEditingController();
  final _checklist = <String>{};

  final _topicOptions = [
    'درخواست اطلاعات',
    'درخواست زمان',
    'روشن\u200cکردن وظیفه',
    'بیان محدودیت',
    'درخواست کمک',
    'مشخص\u200cکردن یک سوءتفاهم',
    'موضوع دیگر',
    'فعلاً جمله شخصی نمی\u200cنویسم',
  ];

  final _checklistItems = [
    'جمله من شامل سرزنش یا توهین نیست.',
    'درخواست من روشن است.',
    'با مقررات و مسیر رسمی هماهنگ است.',
    'ممکن است طرف مقابل درخواست را نپذیرد.',
  ];

  bool get _canSubmitAssertive =>
      _communicationTopic != null &&
      _communicationTopic != 'فعلاً جمله شخصی نمی\u200cنویسم' &&
      _factCtrl.text.trim().isNotEmpty &&
      _needCtrl.text.trim().isNotEmpty &&
      _requestCtrl.text.trim().isNotEmpty;

  Widget _buildAssertiveForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تمرین ارتباط',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Educational quiz
          MultiChoiceQuizPage(
            title: 'آزمون آموزشی',
            questions: const [
              QuizQuestion(
                question: 'کدام جمله پرخاشگرانه\u200cتر است؟',
                options: [
                  'اگر امکان دارد زمان جدید را مشخص کنید.',
                  'شما هیچ\u200cوقت درست اطلاع\u200cرسانی نمی\u200cکنید.',
                  'برای برنامه\u200cریزی به زمان دقیق نیاز دارم.',
                  'آیا می\u200cتوانم درباره زمان تحویل سؤال کنم؟',
                ],
                correctAnswerIndex: 1,
                feedbackCorrect: 'صحیح! این جمله شامل سرزنش و تعمیم است.',
              ),
              QuizQuestion(
                question: 'کدام جمله قاطعانه\u200cتر است؟',
                options: [
                  'هیچ چیز نمی\u200cگویم.',
                  'باید همین الان کاری را که می\u200cگویم انجام دهید.',
                  'برای تکمیل کار به اطلاعات این بخش نیاز دارم؛ آیا امکان دریافت آن تا فردا وجود دارد؟',
                  'شما باعث همه مشکلات شده\u200cاید.',
                ],
                correctAnswerIndex: 2,
                feedbackCorrect:
                    'صحیح! این جمله واقعیت، نیاز و درخواست روشن را بیان می\u200cکند.',
              ),
              QuizQuestion(
                question: 'قاطعانه\u200cبودن به چه معنا نیست؟',
                options: [
                  'بیان روشن درخواست',
                  'رعایت احترام',
                  'تضمین اینکه دیگری حتماً موافقت کند',
                  'مشخص\u200cکردن نیاز',
                ],
                correctAnswerIndex: 2,
                feedbackCorrect:
                    'صحیح! ارتباط قاطعانه تضمینی برای موافقت طرف مقابل ایجاد نمی\u200cکند.',
              ),
            ],
            onCompleted: (score) {
              context.read<Week7ViewModel>().submitExerciseResponse(
                weekNumber: 7,
                dayNumber: 48,
                exerciseType: 'assertive_communication_quiz',
                data: {'assertive_communication_quiz_score': score},
              );
            },
            endMessage: 'آزمون برای مرور محتواست.',
            buttonText: 'ادامه به تمرین شخصی',
          ),
          SizedBox(height: AppSizes.lg),
          // Personal sentence
          Text(
            'جمله شخصی',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'موضوع کلی شما چیست؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._topicOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _communicationTopic,
              (v) => setState(() => _communicationTopic = v),
            ),
          ),
          if (_communicationTopic != null &&
              _communicationTopic != 'فعلاً جمله شخصی نمی\u200cنویسم') ...[
            SizedBox(height: AppSizes.lg),
            Text(
              'واقعیت قابل مشاهده چیست؟',
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
              controller: _factCtrl,
              maxLength: 150,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'واقعیت...',
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
            Text(
              'پیامد یا نیاز شما چیست؟',
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
              controller: _needCtrl,
              maxLength: 150,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'نیاز یا پیامد...',
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
            Text(
              'درخواست روشن و واقع\u200cبینانه شما چیست؟',
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
              controller: _requestCtrl,
              maxLength: 150,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'درخواست...',
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
            // Combined display
            if (_combinedSentence.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(
                  _combinedSentence,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    height: 1.7,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            SizedBox(height: AppSizes.lg),
            // Checklist
            Text(
              'چک\u200cلیست نهایی',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            ..._checklistItems.map((item) {
              final isChecked = _checklist.contains(item);
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: AppSizes.xs),
                child: Material(
                  color: isChecked
                      ? AppColors.success.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isChecked) {
                          _checklist.remove(item);
                        } else {
                          _checklist.add(item);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: Container(
                      padding: EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: isChecked
                              ? AppColors.success
                              : AppColors.divider,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: isChecked,
                              onChanged: null,
                              activeColor: AppColors.success,
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
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitAssertive ? _submitAssertive : null,
              child: const Text('ثبت جمله تمرینی'),
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

  void _submitAssertive() {
    context.read<Week7ViewModel>().submitExerciseResponse(
      weekNumber: 7,
      dayNumber: 48,
      exerciseType: 'assertive_communication',
      data: {
        'communication_topic': _communicationTopic,
        'observable_fact': _factCtrl.text.trim(),
        'need_or_impact': _needCtrl.text.trim(),
        'clear_request': _requestCtrl.text.trim(),
        'assertive_statement': _combinedSentence,
      },
    );
    _goToPage(3);
  }
}
