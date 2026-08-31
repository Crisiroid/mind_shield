import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../week1_exercise/presentation/widgets/week1_header.dart';
import '../../../week1_exercise/presentation/widgets/text_education_page.dart';
import '../../../week1_exercise/presentation/widgets/audio_player_page.dart';
import '../../../week1_exercise/presentation/widgets/day_end_page.dart';
import '../../../week1_exercise/presentation/widgets/exit_exercise_dialog.dart';
import '../view_models/week6_view_model.dart';

class Day41Screen extends StatefulWidget {
  const Day41Screen({super.key});

  @override
  State<Day41Screen> createState() => _Day41ScreenState();
}

class _Day41ScreenState extends State<Day41Screen> {
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
                  dayNumber: 41,
                  dayTitle: 'مکث و انتخاب پاسخ',
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
                    // D41-01: Exercise guide
                    TextEducationPage(
                      title: 'میان هیجان و رفتار، یک مکث کوتاه',
                      bodyText:
                          'امروز مهارت\u200cهای هفته را در یک موقعیت واقعی خفیف یا متوسط تمرین می\u200cکنید.\n\nابتدا فکر و هیجان را نام\u200cگذاری می\u200cکنید، سپس میل به عمل را مشاهده می\u200cکنید و پیش از رفتار، یک مکث کوتاه ایجاد می\u200cکنید.',
                      cards: const [
                        InfoCard(
                          title: 'چهار گام ثابت',
                          text:
                              '۱. متوجه می\u200cشوم چه فکری وجود دارد.\n۲. هیجان و بدن را نام\u200cگذاری می\u200cکنم.\n۳. میل به واکنش فوری را مشاهده می\u200cکنم.\n۴. پاسخ مناسب\u200cتر را انتخاب می\u200cکنم.',
                        ),
                      ],
                      helpTitle: 'ایمنی',
                      helpText:
                          'در موقعیت خطر واقعی یا تصمیم فوری ایمنی، از دستورالعمل\u200cهای رسمی پیروی کنید. این تمرین برای موقعیت\u200cهای روزمره و قابل\u200cمدیریت است.',
                      primaryButtonText: 'شروع مکث کوتاه',
                      onPrimaryButton: () => _goToPage(1),
                    ),
                    // D41-02: Audio player
                    AudioPlayerPage(
                      title: 'مکث، مشاهده، انتخاب',
                      instruction:
                          'فایل صوتی زیر حدود ۲ دقیقه است. برای لحظه\u200cای مکث کنید و مراحل را دنبال کنید.',
                      audioAssetPath: 'assets/audio/week6/w6_aud_03.mp3',
                      skipText: 'عبور از تمرین',
                      onSkip: () => _goToPage(2),
                      onSubmit: (status) {
                        context.read<Week6ViewModel>().submitExerciseResponse(
                          weekNumber: 6,
                          dayNumber: 41,
                          exerciseType: 'pause_and_choose',
                          data: {'audio_status': status},
                        );
                        _goToPage(2);
                      },
                    ),
                    // D41-03: Real experience registration
                    _buildRealExperienceForm(),
                    // D41-04: Day end
                    DayEndPage(
                      title: 'پایان روز چهل\u200cویکم',
                      feedbackText:
                          'هدف مکث، حذف هیجان نیست. مکث فرصتی ایجاد می\u200cکند تا رفتار فقط بر اساس اولین میل هیجانی تعیین نشود.',
                      missionText:
                          'در یک موقعیت دیگر، حتی یک مکث چندثانیه\u200cای را امتحان کنید.',
                      notificationText:
                          'امروز میان هیجان و واکنش، یک مکث کوتاه ایجاد کنید.',
                      buttonText: 'پایان روز چهل\u200cویکم',
                      onButtonPressed: () {
                        context.read<Week6ViewModel>().completeDay(
                          weekNumber: 6,
                          dayNumber: 41,
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

  // D41-03 form state
  String? _situationCategory;
  final _thoughtCtrl = TextEditingController();
  String? _realEmotion;
  double _emotionIntensity = 5;
  String? _initialActionUrge;
  String? _chosenResponse;

  final _situationOptions = [
    'فشار زمانی',
    'گفت\u200cوگوی دشوار',
    'دریافت بازخورد',
    'انتظار یا ابهام',
    'مشکل خانوادگی',
    'خستگی',
    'موقعیت دیگر',
  ];

  final _emotionOptions = [
    'اضطراب',
    'نگرانی',
    'خشم',
    'ناراحتی',
    'شرم',
    'احساس گناه',
    'ناامیدی',
    'ترس',
    'سردرگمی',
    'بی\u200cحسی',
    'هیجان دیگر',
    'مطمئن نیستم',
  ];

  final _actionUrgeOptions = [
    'پاسخ سریع',
    'دورشدن یا اجتناب',
    'سکوت',
    'بررسی مکرر',
    'اطمینان\u200cخواهی',
    'تعویق',
    'میل دیگر',
    'مطمئن نیستم',
  ];

  final _responseOptions = [
    'کمی صبر کردم.',
    'اطلاعات بیشتری جمع کردم.',
    'محترمانه پاسخ دادم.',
    'انجام کار را به زمان مناسب منتقل کردم.',
    'کمک یا حمایت خواستم.',
    'از موقعیت نامناسب فاصله گرفتم.',
    'همان واکنش اولیه را انجام دادم.',
    'پاسخ دیگری انتخاب کردم.',
    'هنوز اقدامی انجام نداده\u200cام.',
  ];

  bool get _canSubmit =>
      _situationCategory != null &&
      _realEmotion != null &&
      _initialActionUrge != null &&
      _chosenResponse != null;

  Widget _buildRealExperienceForm() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ثبت تجربه واقعی',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Q1: Situation category
          Text(
            'موقعیت کلی چه بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._situationOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _situationCategory,
              (v) => setState(() => _situationCategory = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q2: Thought (optional text)
          Text(
            'چه فکری متوجه شدید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'متن اختیاری، حداکثر ۱۵۰ کاراکتر',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          TextField(
            controller: _thoughtCtrl,
            maxLength: 150,
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
          SizedBox(height: AppSizes.lg),
          // Q3: Real emotion
          Text(
            'هیجان اصلی چه بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._emotionOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _realEmotion,
              (v) => setState(() => _realEmotion = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4: Emotion intensity slider
          Text(
            'شدت هیجان از صفر تا ده چقدر بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              trackHeight: 6,
            ),
            child: Slider(
              value: _emotionIntensity,
              min: 0,
              max: 10,
              divisions: 10,
              label: _emotionIntensity.toInt().toString(),
              onChanged: (v) => setState(() => _emotionIntensity = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '۰',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _emotionIntensity.toInt().toString(),
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '۱۰',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.lg),
          // Q5: Initial action urge
          Text(
            'میل اولیه شما چه بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._actionUrgeOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _initialActionUrge,
              (v) => setState(() => _initialActionUrge = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q6: Chosen response
          Text(
            'پس از مکث چه پاسخی انتخاب کردید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._responseOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _chosenResponse,
              (v) => setState(() => _chosenResponse = v),
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submitForm : null,
              child: const Text('ثبت تجربه'),
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
    context.read<Week6ViewModel>().submitExerciseResponse(
      weekNumber: 6,
      dayNumber: 41,
      exerciseType: 'real_situation_experience',
      data: {
        'real_situation_category': _situationCategory,
        'optional_real_thought': _thoughtCtrl.text.trim().isNotEmpty
            ? _thoughtCtrl.text.trim()
            : null,
        'real_emotion': _realEmotion,
        'real_emotion_intensity': _emotionIntensity.toInt(),
        'initial_action_urge': _initialActionUrge,
        'chosen_response': _chosenResponse,
      },
    );
    _goToPage(3);
  }
}
