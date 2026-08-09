import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../view_models/week1_view_model.dart';
import '../widgets/week1_header.dart';
import '../widgets/text_education_page.dart';
import '../widgets/stress_slider_page.dart';
import '../widgets/body_sign_form_page.dart';
import '../widgets/audio_player_page.dart';
import '../widgets/checklist_page.dart';
import '../widgets/day_end_page.dart';
import '../widgets/exit_exercise_dialog.dart';

class Day5Screen extends StatefulWidget {
  const Day5Screen({super.key});

  @override
  State<Day5Screen> createState() => _Day5ScreenState();
}

class _Day5ScreenState extends State<Day5Screen> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalSteps = 6;

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
                  dayNumber: 5,
                  dayTitle: 'بدن و رفتار چه می\u200cگویند؟',
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
                    // D5-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week1ViewModel>().submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 5,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D5-02: Education - body and behavior signs
                    TextEducationPage(
                      title: 'استرس در بدن و رفتار',
                      bodyText:
                          'بدن و رفتار ممکن است پیش از آنکه بتوانیم استرس خود را با کلمات توضیح دهیم، نشانه\u200cهایی ایجاد کنند.',
                      customChildren: [
                        SizedBox(height: AppSizes.md),
                        _buildSectionTitle('نشانه\u200cهای بدنی'),
                        SizedBox(height: AppSizes.sm),
                        _buildBulletList([
                          'انقباض عضلات',
                          'سردرد',
                          'تپش قلب',
                          'تغییر تنفس',
                          'ناراحتی معده',
                          'گرما یا تعریق',
                          'لرزش',
                          'خستگی',
                        ]),
                        SizedBox(height: AppSizes.md),
                        _buildSectionTitle('نشانه\u200cهای رفتاری'),
                        SizedBox(height: AppSizes.sm),
                        _buildBulletList([
                          'عجله',
                          'تعلل',
                          'اجتناب',
                          'سکوت یا کناره\u200cگیری',
                          'تحریک\u200cپذیری',
                          'بررسی مکرر',
                          'کاهش تمرکز',
                          'تغییر خواب یا اشتها',
                        ]),
                      ],
                      noteText:
                          'هیچ\u200cیک از این نشانه\u200cها به\u200cتنهایی بیانگر تشخیص روان\u200cشناختی نیستند. هدف، شناخت الگوی شخصی شماست.',
                      primaryButtonText: 'نشانه\u200cهای خود را بررسی کنم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D5-03: Body sign form
                    BodySignFormPage(
                      onSubmit: (data) {
                        context.read<Week1ViewModel>().submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 5,
                          exerciseType: 'body_sign',
                          data: data,
                        );
                        _goToPage(3);
                      },
                    ),
                    // D5-04: Audio player - 60 second observation
                    AudioPlayerPage(
                      title: 'مشاهده کوتاه بدن',
                      instruction:
                          'لازم نیست بدن یا تنفس خود را تغییر دهید. فقط آنچه اکنون وجود دارد مشاهده کنید.',
                      audioAssetPath: 'assets/audio/week1/body_observation.mp3',
                      skipText: 'عبور از تمرین',
                      onSkip: () => _goToPage(5),
                      onSubmit: (status) {
                        context.read<Week1ViewModel>().submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 5,
                          exerciseType: 'brief_observation',
                          data: {'status': status},
                        );
                        _goToPage(4);
                      },
                    ),
                    // D5-05: Behavioral checklist
                    ChecklistPage(
                      title: 'نشانه رفتاری من',
                      subtitle:
                          'هنگام استرس، کدام تغییر رفتاری را زودتر مشاهده می\u200cکنید؟ (حداکثر دو انتخاب)',
                      items: const [
                        'سریع\u200cتر صحبت می\u200cکنم.',
                        'ساکت یا منزوی می\u200cشوم.',
                        'کار را به تعویق می\u200cاندازم.',
                        'بیش از حد بررسی می\u200cکنم.',
                        'تحریک\u200cپذیر می\u200cشوم.',
                        'تمرکزم کاهش می\u200cیابد.',
                        'خواب یا اشتهایم تغییر می\u200cکند.',
                        'رفتار دیگری دارم.',
                        'نشانه مشخصی شناسایی نکردم.',
                      ],
                      maxSelections: 2,
                      onSubmit: (selected) {
                        context.read<Week1ViewModel>().submitExerciseResponse(
                          weekNumber: 1,
                          dayNumber: 5,
                          exerciseType: 'behavioral_signs',
                          data: {'signs': selected},
                        );
                        _goToPage(5);
                      },
                    ),
                    // D5-06: Day end
                    DayEndPage(
                      title: 'پایان روز پنجم',
                      missionText:
                          'نشانه\u200cهای بدنی و رفتاری می\u200cتوانند پیام\u200cهای اولیه\u200cای باشند که نشان می\u200cدهند لازم است وضعیت خود را بررسی کنید.\n\nامروز فقط توجه کنید: استرس ابتدا در بدن شما ظاهر می\u200cشود یا در رفتارتان؟',
                      notificationText:
                          'چند لحظه به نشانه\u200cهای بدنی و رفتاری خود توجه کنید.',
                      buttonText: 'پایان روز پنجم',
                      onButtonPressed: () {
                        context.read<Week1ViewModel>().completeDay(
                          weekNumber: 1,
                          dayNumber: 5,
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

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: PersianFonts.Vazir.copyWith(
        fontSize: AppSizes.fontMd,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: AppSizes.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        item,
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontSm,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
