import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../view_models/week1_view_model.dart';
import '../widgets/week1_header.dart';
import '../widgets/text_education_page.dart';
import '../widgets/goal_form_page.dart';
import '../widgets/reminder_setup_page.dart';
import '../widgets/day_end_page.dart';
import '../widgets/exit_exercise_dialog.dart';

class Day1Screen extends StatefulWidget {
  const Day1Screen({super.key});

  @override
  State<Day1Screen> createState() => _Day1ScreenState();
}

class _Day1ScreenState extends State<Day1Screen> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalSteps = 5;

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
          if (shouldExit && context.mounted) {
            Navigator.of(context).pop();
          }
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
                  dayNumber: 1,
                  dayTitle: 'شروع مسیر',
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
                    // D1-01: Welcome
                    TextEducationPage(
                      title: 'به سپر روان خوش آمدید',
                      bodyText:
                          '«سپر روان» یک برنامه هشت‌هفته‌ای برای یادگیری و تمرین مهارت‌های شناختی‌ـ‌رفتاری و ذهن‌آگاهی است.\n\nدر طول برنامه، یاد می‌گیرید الگوهای استرس، افکار، هیجانات و رفتارهای خود را بهتر بشناسید و در موقعیت‌های دشوار، پاسخ‌های مؤثرتری انتخاب کنید.',
                      imageWidget: Image.asset(
                        'assets/images/week1/w1_img_01.png',
                        height: 180,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                          child: Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      noteText:
                          'بیشتر تمرین‌ها کوتاه‌اند و می‌توانید آن‌ها را در زمان مناسب خود انجام دهید.',
                      primaryButtonText: 'آشنایی با برنامه',
                      onPrimaryButton: () => _goToPage(1),
                    ),
                    // D1-02: Program structure
                    TextEducationPage(
                      title: 'برنامه چگونه پیش می‌رود؟',
                      cards: const [
                        InfoCard(
                          title: 'هشت هفته، هشت موضوع',
                          text: 'هر هفته بر یک مهارت اصلی تمرکز دارد.',
                        ),
                        InfoCard(
                          title: 'تمرین کوتاه روزانه',
                          text:
                              'بیشتر تمرین‌ها حدود پنج تا ده دقیقه زمان می‌برند.',
                        ),
                        InfoCard(
                          title: 'استفاده مستقل',
                          text:
                              'برنامه به\u200cصورت خودیار و غیرهم\u200cزمان ارائه می\u200cشود و برای انجام تمرین\u200cها به ارتباط زنده با درمانگر نیاز ندارید.',
                        ),
                      ],
                      bottomText:
                          'لازم نیست تمام مهارت\u200cها را از ابتدا بلد باشید. محتوا به\u200cصورت تدریجی ارائه می\u200cشود.',
                      primaryButtonText: 'ادامه',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D1-03: Scope and privacy
                    _D1Page03(onContinue: () => _goToPage(3)),
                    // D1-04: Personal goal
                    GoalFormPage(
                      skipText: 'فقط حوزه هدف را ثبت می\u200cکنم',
                      onSubmit: (data) {
                        final vm = context.read<Week1ViewModel>();
                        vm.submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 1,
                          exerciseType: 'goal',
                          data: data,
                        );
                        _goToPage(4);
                      },
                    ),
                    // D1-05: Reminder + Day end
                    _D1Page05(
                      onComplete: () {
                        final vm = context.read<Week1ViewModel>();
                        vm.completeDay(weekNumber: 1, dayNumber: 1);
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
}

// D1-03: Privacy with checkbox
class _D1Page03 extends StatefulWidget {
  final VoidCallback onContinue;
  const _D1Page03({required this.onContinue});

  @override
  State<_D1Page03> createState() => _D1Page03State();
}

class _D1Page03State extends State<_D1Page03> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return TextEducationPage(
      title: 'پیش از شروع',
      bodyText:
          'سپر روان یک برنامه خودیار آموزشی و تمرینی است. این برنامه جایگزین ارزیابی، تشخیص یا درمان فردی توسط روان\u200cشناس یا روان\u200cپزشک نیست.',
      helpTitle: 'در صورت نیاز به کمک',
      helpText:
          'اگر احساس می\u200cکنید در وضعیت بحرانی قرار دارید، از بخش «راهنما و کمک» استفاده کنید و با خدمات حرفه\u200cای تعیین\u200cشده در پژوهش تماس بگیرید.',
      showCheckbox: true,
      checkboxText: 'مطالب این صفحه را مطالعه کردم.',
      checkboxValue: _checked,
      onCheckboxChanged: (v) => setState(() => _checked = v),
      primaryButtonText: 'ادامه',
      onPrimaryButton: widget.onContinue,
    );
  }
}

// D1-05: Reminder + Day end
class _D1Page05 extends StatefulWidget {
  final VoidCallback onComplete;
  const _D1Page05({required this.onComplete});

  @override
  State<_D1Page05> createState() => _D1Page05State();
}

class _D1Page05State extends State<_D1Page05> {
  @override
  Widget build(BuildContext context) {
    return ReminderSetupPage(
      onDone: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            content: DayEndPage(
              title: 'پایان روز اول',
              missionText:
                  'روز اول به پایان رسید.\nدر این هفته قرار نیست همه مشکلات را فوراً تغییر دهید. ابتدا الگوی استرس خود را بهتر خواهید شناخت.',
              feedbackText: null,
              notificationText: 'تمرین امروز سپر روان آماده است.',
              buttonText: 'پایان روز اول',
              onButtonPressed: () {
                Navigator.of(context).pop();
                widget.onComplete();
              },
            ),
          ),
        );
      },
    );
  }
}
