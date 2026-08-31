import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../view_models/week1_view_model.dart';
import '../widgets/week1_header.dart';
import '../widgets/text_education_page.dart';
import '../widgets/five_part_form_page.dart';
import '../widgets/day_end_page.dart';
import '../widgets/exit_exercise_dialog.dart';

class Day6Screen extends StatefulWidget {
  const Day6Screen({super.key});

  @override
  State<Day6Screen> createState() => _Day6ScreenState();
}

class _Day6ScreenState extends State<Day6Screen> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalSteps = 3;

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
                  dayNumber: 6,
                  dayTitle: 'ثبت یک تجربه واقعی',
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
                    // D6-01: Mission
                    TextEducationPage(
                      title: 'مأموریت امروز',
                      bodyText:
                          'امروز یک موقعیت با استرس خفیف یا متوسط را ثبت کنید.\n\nلازم نیست شدیدترین، خصوصی\u200cترین یا مهم\u200cترین تجربه خود را انتخاب کنید.',
                      helpTitle: 'محرمانگی',
                      helpText:
                          'شرح کلی موقعیت کافی است. اطلاعات هویتی، سازمانی یا مأموریتی ثبت نکنید.',
                      primaryButtonText: 'شروع ثبت',
                      onPrimaryButton: () => _goToPage(1),
                      secondaryButtonText: 'امروز انجام نمی\u200cدهم',
                      onSecondaryButton: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusLg,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'می\u200cتوانید فردا طبق برنامه ادامه دهید. انجام\u200cندادن این تمرین مانع ورود به روز بعد نمی\u200cشود.',
                                  style: PersianFonts.Vazir.copyWith(
                                    fontSize: AppSizes.fontMd,
                                    height: 1.8,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: AppSizes.lg),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      context
                                          .read<Week1ViewModel>()
                                          .completeDay(
                                            weekNumber: 1,
                                            dayNumber: 6,
                                          );
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('ادامه'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // D6-02: Five-part form (real event)
                    FivePartFormPage(
                      title: 'ثبت یک رخداد واقعی',
                      guideText: null,
                      submitText: 'ثبت رخداد',
                      onSubmit: (data) {
                        context.read<Week1ViewModel>().submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 6,
                          exerciseType: 'real_event_record',
                          data: data,
                        );
                        _goToPage(2);
                      },
                    ),
                    // D6-03: Day end
                    DayEndPage(
                      title: 'پایان روز ششم',
                      missionText:
                          'هدف امروز حل\u200cکردن موقعیت نبود. شما زنجیره واکنش خود را مشاهده و ثبت کردید.\n\nدر هفته\u200cهای بعد یاد می\u200cگیرید چگونه افکار، هیجان\u200cها و رفتارهای ثبت\u200cشده را دقیق\u200cتر بررسی کنید.',
                      notificationText:
                          'یک موقعیت خفیف یا متوسط برای تمرین امروز کافی است.',
                      buttonText: 'پایان روز ششم',
                      onButtonPressed: () {
                        context.read<Week1ViewModel>().completeDay(
                          weekNumber: 1,
                          dayNumber: 6,
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
}
