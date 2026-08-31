import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../view_models/week1_view_model.dart';
import '../widgets/week1_header.dart';
import '../widgets/text_education_page.dart';
import '../widgets/stress_slider_page.dart';
import '../widgets/slider_form_page.dart';
import '../widgets/day_end_page.dart';
import '../widgets/exit_exercise_dialog.dart';

class Day2Screen extends StatefulWidget {
  const Day2Screen({super.key});

  @override
  State<Day2Screen> createState() => _Day2ScreenState();
}

class _Day2ScreenState extends State<Day2Screen> {
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
                  dayNumber: 2,
                  dayTitle: 'استرس چگونه شکل می\u200cگیرد؟',
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
                    // D2-01: Stress slider
                    StressSliderPage(
                      title: 'امروز چه میزان استرس تجربه کرده\u200cاید؟',
                      subtitle:
                          'عددی را انتخاب کنید که بیشترین شباهت را به تجربه کلی امروز شما دارد.',
                      rightLabel: 'بیشترین استرس امروز',
                      onSubmit: (score) {
                        final vm = context.read<Week1ViewModel>();
                        vm.submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 2,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D2-02: Education - pressures and resources
                    TextEducationPage(
                      title: 'استرس فقط به موقعیت وابسته نیست',
                      bodyText:
                          'استرس زمانی بیشتر می\u200cشود که احساس کنیم فشارها یا خواسته\u200cهای یک موقعیت، از منابعی که برای مدیریت آن در اختیار داریم بیشتر است.\n\nمنابع می\u200cتوانند شامل زمان، اطلاعات، تجربه، مهارت، حمایت دیگران، استراحت، امکانات یا اختیار تصمیم\u200cگیری باشند.\n\nدو نفر ممکن است در یک موقعیت مشابه، میزان متفاوتی از استرس تجربه کنند؛ زیرا ارزیابی آن\u200cها از دشواری موقعیت و منابع موجود یکسان نیست.',
                      imageWidget: Image.asset(
                        'assets/images/week1/w1_img_02.png',
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
                            Icons.balance,
                            size: 48,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      noteText:
                          'این موضوع به معنای خیالی\u200cبودن استرس نیست. موقعیت\u200cهای دشوار واقعی\u200cاند؛ اما نحوه ارزیابی آن\u200cها نیز بر واکنش ما اثر دارد.',
                      primaryButtonText: 'تمرین کنیم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D2-03: Slider form exercise
                    SliderFormPage(
                      title: 'یک موقعیت اخیر را بررسی کنید',
                      subtitle:
                          'یک موقعیت ساده و غیرمحرمانه را در نظر بگیرید. لازم نیست آن را به\u200cصورت متنی توضیح دهید.',
                      firstSliderLabel: 'فشار این موقعیت چقدر بود؟',
                      firstSliderLeftLabel: 'بدون فشار',
                      firstSliderRightLabel: 'فشار بسیار زیاد',
                      secondSliderLabel:
                          'احساس می\u200cکردید چه میزان منابع برای مدیریت آن در اختیار دارید؟',
                      secondSliderLeftLabel: 'منابع بسیار کم',
                      secondSliderRightLabel: 'منابع کاملاً کافی',
                      dropdownLabel: 'بیشتر به کدام منبع نیاز داشتید؟',
                      dropdownOptions: const [
                        'زمان',
                        'اطلاعات روشن\u200cتر',
                        'مهارت یا تجربه',
                        'حمایت دیگران',
                        'استراحت',
                        'اختیار تصمیم\u200cگیری',
                        'امکانات',
                        'مورد دیگر',
                        'مطمئن نیستم',
                      ],
                      onSubmit: (data) {
                        final vm = context.read<Week1ViewModel>();
                        vm.submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 2,
                          exerciseType: 'stress_demand_resources',
                          data: data,
                        );
                        _goToPage(3);
                      },
                    ),
                    // D2-04: Day end
                    DayEndPage(
                      title: 'جمع\u200cبندی روز دوم',
                      missionText:
                          'همیشه نمی\u200cتوان فشار موقعیت را کاهش داد؛ اما می\u200cتوان منابع موجود، منابع مورد نیاز و نحوه ارزیابی موقعیت را دقیق\u200cتر شناخت.\n\nامروز یک بار از خود بپرسید:\n«فشار موقعیت زیاد است یا منابع من در این لحظه کم به نظر می\u200cرسند؟»',
                      feedbackText:
                          'هدف این سؤال قضاوت\u200cکردن خود نیست؛ فقط می\u200cخواهیم عوامل مؤثر بر استرس را بهتر ببینیم.',
                      notificationText:
                          'چند دقیقه برای بررسی فشارها و منابع خود در نظر بگیرید.',
                      buttonText: 'پایان روز دوم',
                      onButtonPressed: () {
                        final vm = context.read<Week1ViewModel>();
                        vm.completeDay(weekNumber: 1, dayNumber: 2);
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
