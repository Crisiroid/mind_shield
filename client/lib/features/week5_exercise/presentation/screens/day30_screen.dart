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

class Day30Screen extends StatefulWidget {
  const Day30Screen({super.key});

  @override
  State<Day30Screen> createState() => _Day30ScreenState();
}

class _Day30ScreenState extends State<Day30Screen> {
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
                  dayNumber: 30,
                  dayTitle: 'فعالیت کوچک انتخاب کنیم',
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
                    // D30-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week5ViewModel>().submitExerciseResponse(
                          weekNumber: 5,
                          dayNumber: 30,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D30-02: Activity types education
                    TextEducationPage(
                      title: 'همه فعالیت\u200cهای مفید یکسان نیستند',
                      bodyText:
                          'بعضی فعالیت\u200cها لذت کوچکی ایجاد می\u200cکنند، بعضی احساس پیشرفت یا انجام وظیفه، بعضی ارتباط با دیگران و بعضی احساس معنا و هماهنگی با موضوعات مهم زندگی.\n\nیک برنامه متعادل می\u200cتواند از چند نوع فعالیت تشکیل شود.',
                      imageWidget: _buildW5Img02(),
                      cards: const [
                        InfoCard(
                          title: 'فعالیت لذت\u200cبخش',
                          text:
                              'برای مثال نوشیدن یک نوشیدنی با توجه، گوش\u200cدادن به موسیقی یا پیاده\u200cروی کوتاه.',
                        ),
                        InfoCard(
                          title: 'فعالیت مفید یا پیش\u200cبرنده',
                          text:
                              'برای مثال مرتب\u200cکردن یک بخش کوچک، پاسخ\u200cدادن به یک پیام ضروری یا انجام بخشی از یک کار عقب\u200cافتاده.',
                        ),
                        InfoCard(
                          title: 'فعالیت ارتباطی',
                          text:
                              'برای مثال تماس کوتاه با یکی از نزدیکان یا گفت\u200cوگوی کوتاه با فرد حمایتگر.',
                        ),
                        InfoCard(
                          title: 'فعالیت معنادار',
                          text:
                              'فعالیتی هماهنگ با موضوعات مهمی مانند خانواده، یادگیری، سلامت یا کمک به دیگران.',
                        ),
                      ],
                      noteText:
                          'فعالیت لازم نیست بزرگ، جدید یا هیجان\u200cانگیز باشد. کوچک و قابل اجرا بودن مهم\u200cتر است.',
                      primaryButtonText: 'انتخاب فعالیت\u200cها',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D30-03: Activity selection checklist
                    _buildActivitySelectionForm(),
                    // D30-04: Day end
                    DayEndPage(
                      title: 'پایان روز سی\u200cام',
                      feedbackText:
                          'سه فعالیت کوچک برای این هفته انتخاب شد. لازم نیست همه را هم\u200cزمان انجام دهید.',
                      missionText:
                          'فقط بررسی کنید کدام فعالیت کمترین مانع را برای شروع دارد.',
                      notificationText:
                          'امروز چند فعالیت کوچک و قابل اجرا انتخاب کنید.',
                      buttonText: 'پایان روز سی\u200cام',
                      onButtonPressed: () {
                        context.read<Week5ViewModel>().completeDay(
                          weekNumber: 5,
                          dayNumber: 30,
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

  // D30-03 form state
  final Set<String> _selectedActivities = {};
  final _customActivityCtrl = TextEditingController();

  final Map<String, List<String>> _activityGroups = {
    'لذت\u200cبخش': [
      'نوشیدن چای یا قهوه با توجه کامل',
      'گوش\u200cدادن به موسیقی یا پادکست',
      'دیدن یا خواندن محتوای کوتاه مورد علاقه',
      'دوش\u200cگرفتن یا رسیدگی شخصی',
      'حضور کوتاه در فضای باز',
      'فعالیت لذت\u200cبخش دیگر',
    ],
    'مفید یا پیش\u200cبرنده': [
      'مرتب\u200cکردن یک سطح یا بخش کوچک',
      'انجام پنج دقیقه از یک کار عقب\u200cافتاده',
      'آماده\u200cکردن وسایل لازم برای فردا',
      'پاسخ\u200cدادن به یک پیام یا درخواست ضروری',
      'نوشتن فهرست کوتاه کارها',
      'فعالیت مفید دیگر',
    ],
    'ارتباطی': [
      'تماس کوتاه با خانواده یا دوست',
      'ارسال یک پیام کوتاه',
      'گفت\u200cوگوی کوتاه با فرد حمایتگر',
      'صرف چند دقیقه با اعضای خانواده',
      'فعالیت ارتباطی دیگر',
    ],
    'سلامت و حرکت': [
      'پیاده\u200cروی کوتاه',
      'حرکت کششی سبک',
      'نوشیدن آب',
      'آماده\u200cکردن غذای ساده و مناسب',
      'تنظیم زمان خواب',
      'فعالیت دیگر متناسب با توان جسمانی',
    ],
  };

  bool get _hasCustomActivity =>
      _selectedActivities.contains('فعالیت لذت\u200cبخش دیگر') ||
      _selectedActivities.contains('فعالیت مفید دیگر') ||
      _selectedActivities.contains('فعالیت ارتباطی دیگر') ||
      _selectedActivities.contains('فعالیت دیگر متناسب با توان جسمانی');

  bool get _canSubmitActivities =>
      _selectedActivities.isNotEmpty && _selectedActivities.length <= 3;

  Widget _buildActivitySelectionForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سه فعالیت کوچک انتخاب کنید',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'فعالیت\u200cهایی را انتخاب کنید که در شرایط فعلی واقعاً امکان انجام آن\u200cها وجود دارد.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'حداقل یک و حداکثر سه فعالیت (${_selectedActivities.length} انتخاب شده)',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Safety notice
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              'فعالیت جسمانی را متناسب با وضعیت سلامت و شرایط محیطی خود انتخاب کنید.',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Activity groups
          ..._activityGroups.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'گروه ${entry.key}',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                ...entry.value.map((item) {
                  final isSelected = _selectedActivities.contains(item);
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
                              _selectedActivities.remove(item);
                            } else if (_selectedActivities.length < 3) {
                              _selectedActivities.add(item);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        child: Container(
                          padding: EdgeInsets.all(AppSizes.md),
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
                SizedBox(height: AppSizes.sm),
              ],
            );
          }),
          // Custom activity field
          if (_hasCustomActivity) ...[
            SizedBox(height: AppSizes.md),
            Text(
              'فعالیت دیگر را بنویسید:',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.xs),
            TextField(
              controller: _customActivityCtrl,
              maxLength: 100,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'فعالیت مورد نظر...',
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
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitActivities ? _submitActivities : null,
              child: const Text('ثبت فعالیت\u200cها'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _submitActivities() {
    context.read<Week5ViewModel>().submitExerciseResponse(
      weekNumber: 5,
      dayNumber: 30,
      exerciseType: 'activity_selection',
      data: {
        'selected_activities': _selectedActivities.toList(),
        'custom_activity_text': _hasCustomActivity
            ? _customActivityCtrl.text
            : null,
      },
    );
    _goToPage(3);
  }

  Widget _buildW5Img02() {
    return Image.asset(
      'assets/images/week5/w5_img_02.png',
      height: 160,
      errorBuilder: (_, __, ___) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          children: [
            _buildTypeCard(
              'لذت\u200cبخش',
              Icons.favorite_border,
              'فعالیتی که می\u200cتواند تجربه خوشایند کوچکی ایجاد کند.',
            ),
            SizedBox(height: AppSizes.xs),
            _buildTypeCard(
              'مفید یا پیش\u200cبرنده',
              Icons.check_circle_outline,
              'فعالیتی که احساس انجام\u200cدادن یا پیشرفت ایجاد می\u200cکند.',
            ),
            SizedBox(height: AppSizes.xs),
            _buildTypeCard(
              'ارتباطی',
              Icons.people_outline,
              'فعالیتی که ارتباط سالم با دیگران را افزایش می\u200cدهد.',
            ),
            SizedBox(height: AppSizes.xs),
            _buildTypeCard(
              'معنادار',
              Icons.star_border,
              'فعالیتی که با موضوعات مهم زندگی یا نقش\u200cهای شخصی هماهنگ است.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(String title, IconData icon, String desc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontXs,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  desc,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
