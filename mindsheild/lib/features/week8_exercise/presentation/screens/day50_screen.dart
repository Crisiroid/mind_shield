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
import '../view_models/week8_view_model.dart';

class Day50Screen extends StatefulWidget {
  const Day50Screen({super.key});

  @override
  State<Day50Screen> createState() => _Day50ScreenState();
}

class _Day50ScreenState extends State<Day50Screen> {
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
                  dayNumber: 50,
                  dayTitle: 'مهارت\u200cهای من',
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
                    // D50-01: Stress slider
                    StressSliderPage(
                      title: 'استرس امروز',
                      subtitle: 'میزان استرس کلی امروز از صفر تا ده چقدر است؟',
                      onSubmit: (score) {
                        context.read<Week8ViewModel>().submitExerciseResponse(
                          weekNumber: 8,
                          dayNumber: 50,
                          exerciseType: 'daily_stress',
                          data: {'stress_score': score},
                        );
                        _goToPage(1);
                      },
                      skipText: 'فعلاً ثبت نمی\u200cکنم',
                      onSkip: () => _goToPage(1),
                    ),
                    // D50-02: Review skills
                    TextEducationPage(
                      title: 'مسیر هشت\u200cهفته\u200cای را مرور کنیم',
                      bodyText: null,
                      imageWidget: _buildW8Img01(),
                      noteText:
                          'طبیعی است که بعضی مهارت\u200cها برای شما کاربردی\u200cتر از مهارت\u200cهای دیگر باشند.',
                      cards: const [
                        InfoCard(
                          title: 'شناخت استرس',
                          text:
                              'بررسی فشارها، منابع و ارتباط موقعیت، فکر، هیجان، بدن و رفتار.',
                        ),
                        InfoCard(
                          title: 'بدن و تنفس',
                          text:
                              'مشاهده نشانه\u200cهای بدن، اسکن بدن و توجه به جریان طبیعی تنفس.',
                        ),
                        InfoCard(
                          title: 'افکار خودکار',
                          text:
                              'شناسایی فکرهای سریع و الگوهای فکری تکرارشونده.',
                        ),
                        InfoCard(
                          title: 'بررسی شواهد',
                          text:
                              'بررسی اطلاعات موافق و مخالف و نوشتن فکر متعادل\u200cتر.',
                        ),
                        InfoCard(
                          title: 'فعال\u200cسازی رفتاری',
                          text:
                              'انتخاب و انجام فعالیت\u200cهای کوچک، مفید یا لذت\u200cبخش.',
                        ),
                        InfoCard(
                          title: 'مشاهده و پذیرش',
                          text:
                              'مشاهده فکر و هیجان و ایجاد مکث پیش از واکنش فوری.',
                        ),
                        InfoCard(
                          title: 'حل مسئله',
                          text:
                              'تعریف مشکل، تولید راه\u200cحل و انتخاب یک قدم عملی.',
                        ),
                      ],
                      primaryButtonText: 'مهارت\u200cهای خود را انتخاب کنم',
                      onPrimaryButton: () => _goToPage(2),
                    ),
                    // D50-03: Select personal skills
                    _buildSkillSelectionForm(),
                    // D50-04: Day end
                    DayEndPage(
                      title: 'پایان روز پنجاهم',
                      feedbackText:
                          'جعبه\u200cابزار مؤثر لازم نیست بزرگ باشد. چند مهارت ساده که واقعاً استفاده شوند، از فهرست طولانی مهارت\u200cها کاربردی\u200cترند.',
                      missionText:
                          'امروز یکی از مهارت\u200cهای منتخب خود را در یک موقعیت ساده مرور کنید.',
                      notificationText:
                          'امروز مهارت\u200cهای کاربردی\u200cتر خود را از دوره انتخاب کنید.',
                      buttonText: 'پایان روز پنجاهم',
                      onButtonPressed: () {
                        context.read<Week8ViewModel>().completeDay(
                          weekNumber: 8,
                          dayNumber: 50,
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

  // D50-03 form state
  final Set<String> _selectedSkills = {};
  final Set<String> _selectedContexts = {};
  bool _notSureYet = false;

  final _skillOptions = [
    'بررسی فشارها و منابع',
    'ثبت موقعیت، فکر، هیجان، بدن و رفتار',
    'توقف کوتاه بدن',
    'اسکن بدن',
    'تنفس آگاهانه',
    'شناسایی افکار خودکار',
    'بررسی شواهد',
    'نوشتن فکر متعادل',
    'برنامه\u200cریزی فعالیت',
    'کوچک\u200cکردن فعالیت',
    'مشاهده افکار',
    'پذیرش هیجان',
    'مکث و انتخاب پاسخ',
    'حل مسئله',
    'ارتباط قاطعانه',
  ];

  final _contextOptions = [
    'فشار زمانی',
    'نگرانی درباره آینده',
    'دریافت بازخورد',
    'تنش بدنی',
    'خلق یا انرژی پایین',
    'هیجان شدید',
    'گفت\u200cوگوی دشوار',
    'مشکل قابل\u200cحل',
    'خستگی',
    'موقعیت دیگر',
  ];

  bool get _canSubmitSkills {
    if (_notSureYet) return true;
    return _selectedSkills.isNotEmpty;
  }

  Widget _buildSkillSelectionForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'انتخاب مهارت\u200cهای شخصی',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'کدام سه مهارت برای شما کاربردی\u200cتر بودند؟',
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
          SizedBox(height: AppSizes.sm),
          ..._skillOptions.map(
            (opt) => _buildCheckTile(
              opt,
              _selectedSkills.contains(opt),
              (checked) {
                setState(() {
                  if (checked) {
                    if (_selectedSkills.length < 3) {
                      _selectedSkills.add(opt);
                    }
                  } else {
                    _selectedSkills.remove(opt);
                  }
                });
              },
              enabled:
                  !_notSureYet &&
                  (_selectedSkills.contains(opt) || _selectedSkills.length < 3),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          _buildCheckTile('هنوز مطمئن نیستم', _notSureYet, (checked) {
            setState(() {
              _notSureYet = checked;
              if (checked) _selectedSkills.clear();
            });
          }),
          if (!_notSureYet) ...[
            SizedBox(height: AppSizes.lg),
            Text(
              'بیشتر در چه موقعیت\u200cهایی به این مهارت\u200cها نیاز دارید؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              'حداکثر دو انتخاب',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                color: AppColors.textHint,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            ..._contextOptions.map(
              (opt) => _buildCheckTile(
                opt,
                _selectedContexts.contains(opt),
                (checked) {
                  setState(() {
                    if (checked) {
                      if (_selectedContexts.length < 2) {
                        _selectedContexts.add(opt);
                      }
                    } else {
                      _selectedContexts.remove(opt);
                    }
                  });
                },
                enabled:
                    _selectedContexts.contains(opt) ||
                    _selectedContexts.length < 2,
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitSkills ? _submitSkills : null,
              child: const Text('ثبت مهارت\u200cهای من'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildCheckTile(
    String value,
    bool isChecked,
    ValueChanged<bool> onChanged, {
    bool enabled = true,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSizes.xs),
      child: Material(
        color: enabled
            ? (isChecked
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: enabled ? () => onChanged(!isChecked) : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: isChecked ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    value,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.textHint,
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

  void _submitSkills() {
    context.read<Week8ViewModel>().submitExerciseResponse(
      weekNumber: 8,
      dayNumber: 50,
      exerciseType: 'skill_review',
      data: {
        'top_skills': _notSureYet ? <String>[] : _selectedSkills.toList(),
        'main_skill_contexts': _notSureYet
            ? <String>[]
            : _selectedContexts.toList(),
        'not_sure_yet': _notSureYet,
      },
    );
    _goToPage(3);
  }

  Widget _buildW8Img01() {
    return Image.asset(
      'assets/images/week8/w8_img_01.png',
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
            _buildSkillIcon('شناخت استرس', Icons.warning_amber_outlined),
            _buildSkillIcon('بدن و تنفس', Icons.accessibility_new),
            _buildSkillIcon('افکار خودکار', Icons.psychology_outlined),
            _buildSkillIcon('بررسی شواهد', Icons.balance),
            _buildSkillIcon('فعال\u200cسازی رفتاری', Icons.directions_run),
            _buildSkillIcon('مشاهده و پذیرش', Icons.visibility_outlined),
            _buildSkillIcon('حل مسئله', Icons.handyman_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillIcon(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          SizedBox(width: 6),
          Text(
            label,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
