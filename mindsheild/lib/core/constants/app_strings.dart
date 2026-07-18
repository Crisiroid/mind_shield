/// All hardcoded Persian strings used throughout the application.
///
/// Since the app is Persian-only (no localization), all user-facing
/// text is centralized here for easy maintenance and consistency.
class AppStrings {
  AppStrings._();

  // ─── App ────────────────────────────────────────────────────
  static const String appTitle = 'سپر روان';
  static const String home = 'خانه';
  static const String settings = 'تنظیمات';
  static const String profile = 'پروفایل';
  static const String dashboard = 'داشبورد';

  // ─── Auth ───────────────────────────────────────────────────
  static const String login = 'ورود';
  static const String register = 'ثبت‌نام';
  static const String logout = 'خروج';
  static const String email = 'ایمیل';
  static const String phoneNumber = 'شماره تلفن';
  static const String password = 'رمز عبور';
  static const String confirmPassword = 'تکرار رمز عبور';
  static const String fullName = 'نام و نام خانوادگی';
  static const String forgotPassword = 'فراموشی رمز عبور';
  static const String noAccount = 'حساب کاربری ندارید؟';
  static const String haveAccount = 'حساب کاربری دارید؟';
  static const String createAccount = 'ایجاد حساب';
  static const String loginHere = 'از اینجا وارد شوید';
  static const String registerHere = 'اینجا ثبت‌نام کنید';
  static const String welcomeBack = 'خوش آمدید';
  static const String loginToContinue = 'برای ادامه وارد حساب خود شوید';
  static const String createYourAccount = 'حساب کاربری خود را بسازید';
  static const String logoutConfirm = 'آیا مطمئن هستید که می‌خواهید خارج شوید؟';
  static const String logoutSuccess = 'با موفقیت خارج شدید';

  // ─── Validation ─────────────────────────────────────────────
  static const String phoneRequired = 'شماره تلفن الزامی است';
  static const String phoneInvalid = 'شماره تلفن نامعتبر است';
  static const String passwordRequired = 'رمز عبور الزامی است';
  static const String passwordTooShort = 'رمز عبور باید حداقل ۶ کاراکتر باشد';
  static const String passwordsDoNotMatch = 'رمز عبور و تکرار آن مطابقت ندارند';

  // ─── Splash ─────────────────────────────────────────────────
  static const String splashLoading = 'در حال بارگذاری...';

  // ─── Errors ─────────────────────────────────────────────────
  static const String error = 'خطا';
  static const String unknownError = 'خطای نامشخص رخ داد';
  static const String networkError = 'خطا در اتصال به شبکه';
  static const String serverError = 'خطای سرور، لطفاً بعداً تلاش کنید';
  static const String unauthorized = 'لطفاً وارد حساب کاربری خود شوید';
  static const String forbidden = 'شما دسترسی به این بخش را ندارید';
  static const String notFound = 'مورد درخواستی یافت نشد';
  static const String timeout = 'زمان درخواست به پایان رسید';
  static const String noInternet = 'اتصال به اینترنت برقرار نیست';
  static const String dataSyncFailed = 'همگام‌سازی داده‌ها ناموفق بود';

  // ─── Status ─────────────────────────────────────────────────
  static const String success = 'موفق';
  static const String loading = 'در حال بارگذاری...';
  static const String saving = 'در حال ذخیره...';
  static const String syncing = 'در حال همگام‌سازی...';
  static const String dataSaved = 'اطلاعات با موفقیت ذخیره شد';
  static const String dataSynced = 'اطلاعات با موفقیت همگام‌سازی شد';
  static const String retry = 'تلاش مجدد';
  static const String cancel = 'لغو';
  static const String ok = 'تایید';
  static const String delete = 'حذف';
  static const String edit = 'ویرایش';
  static const String save = 'ذخیره';
  static const String close = 'بستن';

  // ─── Offline ────────────────────────────────────────────────
  static const String offlineMode = 'حالت آفلاین';
  static const String dataWillSync =
      'اطلاعات ذخیره شد و پس از اتصال اینترنت همگام‌سازی می‌شود';
  static const String pendingSync = 'در انتظار همگام‌سازی';
  static const String offlineModeActive =
      'اکنون آفلاین هستید؛ اطلاعات محلی نمایش داده می‌شود';

  // ─── Initial Sync ───────────────────────────────────────────
  static const String initialSyncTitle = 'همگام‌سازی اطلاعات';
  static const String syncCompleted = 'همگام‌سازی کامل شد';
  static const String preparingSpace = 'در حال آماده‌سازی فضای آرامش شما...';

  /// Calm, non-repetitive remarks shown during the initial pull sync.
  static const List<String> syncRemarks = [
    'در حال آماده‌سازی فضای آرامش شما...',
    'داده‌هایت را با امنیت همگام می‌کنیم...',
    'یک لحظه صبر کن، ذهن‌ها هم به استراحت نیاز دارند...',
    'در حال هماهنگ‌کردن تجربه‌های تو...',
    'نفس عمیق بکش، تقریباً آماده‌ست...',
    'آرام‌آرام همه‌چیز را مرتب می‌کنیم...',
  ];

  /// Calm remarks that rotate on the generic loading dialog.
  static const List<String> loadingRemarks = [
    'یک لحظه صبر کن...',
    'نفس عمیق بکش، تقریباً آماده‌ست...',
    'در حال آماده‌سازی...',
    'آرامش خودت را حفظ کن، همین حالا آماده می‌شود...',
  ];

  // ─── Onboarding ────────────────────────────────────────────────
  static const String welcomeTitle = 'به سپر روان خوش آمدید';
  static const String welcomeSubtitle =
      'همراه شما در مسیر ۵۶ روزه بازیابی سیستم عصبی';
  static const String agreementTitle = 'میثاق‌نامه دیجیتال درمانی';
  static const String agreementText =
      'من متعهد می‌شوم که تمرینات این برنامه را با صداقت و تمام توجه انجام دهم. '
      'می‌دانم که این یک فرآیند تدریجی است و نتایج نیازمند صبر و استمرار است. '
      'متعهد می‌شوم که حداقل یک بار در روز تمرینات را انجام دهم و پیشرفت خود را ثبت کنم.';
  static const String agreementWarning =
      '⚠ این اپلیکیشن جایگزین روانشناس یا روانپزشک نیست. '
      'در صورت داشتن افکار خودکشی یا بحران روانی، لطفاً با شماره ۱۲۳ (اورژانس اجتماعی) تماس بگیرید.';
  static const String agreeAndContinue = 'می‌پذیرم و ادامه می‌دهم';
  static const String iAgree = 'میثاق‌نامه را مطالعه کردم و می‌پذیرم';

  // ─── Roadmap ──────────────────────────────────────────────────
  static const String roadmapTitle = 'مسیر ۵۶ روزه';
  static const String roadmapSubtitle = '۸ هفته برای بازسازی سیستم عصبی';
  static const String startJourney = 'شروع سفر';
  static const String week = 'هفته';
  static const String day = 'روز';
  static const String weekOne = 'آشنایی و مثلث هیجان';
  static const String weekTwo = 'تنفس و آگاهی بدنی';
  static const String weekThree = 'خطاهای شناختی';
  static const String weekFour = 'رادار افکار منفی';
  static const String weekFive = 'دادگاه ذهن';
  static const String weekSix = 'تمرین تعارض';
  static const String weekSeven = 'خلق و فعالیت';
  static const String weekEight = 'تعادل نقش و آسمان افکار';
  static const String weekOneDesc = 'مثلث هیجان، نقشه تنش بدنی، ثبت استرس';
  static const String weekTwoDesc = 'تنفس آگاهانه، انعطاف‌پذیری روانی';
  static const String weekThreeDesc = 'شناسایی خطاهای شناختی، بایدهای ذهنی';
  static const String weekFourDesc = 'ردیابی افکار منفی، سنجش اثر';
  static const String weekFiveDesc = 'شواهد مثبت و منفی، فکر جایگزین';
  static const String weekSixDesc = 'شبیه‌سازی تعارض در محیط کار';
  static const String weekSevenDesc = 'فعالیت‌های خرد، ردیاب خلق';
  static const String weekEightDesc = 'تعادل نقش‌ها، آسمان افکار';

  // ─── Home Dashboard ───────────────────────────────────────────
  static const String weeklyProgress = 'پیشرفت هفتگی';
  static const String overallProgress = 'پیشرفت کلی';
  static const String currentWeekLabel = 'هفته جاری';
  static const String programDay = 'روز برنامه';
  static const String todaysExercise = 'تمرین امروز';
  static const String todaysContent = 'محتوای اختصاصی امروز';
  static const String viewAll = 'مشاهده همه';
  static const String tools = 'ابزارها';
  static const String permanentTools = 'ابزارهای دائمی';
  static const String calendar56Days = 'تقویم ۵۶ روزه';
  static const String completedDays = 'روزهای تکمیل شده';
  static const String startExercise = 'شروع تمرین';
  static const String noContent = 'محتوایی برای امروز وجود ندارد';
  static const String weekTools = 'ابزارهای هفته';
  static const String emotionTriangle = 'مثلث هیجان';
  static const String bodyTension = 'نقشه تنش بدنی';
  static const String stressRegistration = 'ثبت استرس شغلی';
  static const String mindfulBreathing = 'تنفس آگاهانه';
  static const String cognitiveErrors = 'خطاهای شناختی';
  static const String mentalMusts = 'بایدهای ذهنی';
  static const String negativeThoughtRadar = 'رادار افکار منفی';
  static const String mindCourt = 'دادگاه ذهن';
  static const String conflictExercise = 'تمرین تعارض';
  static const String moodTracker = 'ردیاب خلق';
  static const String roleBalance = 'تعادل نقش‌ها';
  static const String skyOfThoughts = 'آسمان افکار';
  static const String mindfulTimer = 'تایمر آگاهانه';
  static const String weeklyReport = 'گزارش هفتگی';

  // ─── Splash ───────────────────────────────────────────────────
  static const String lastLogin = 'آخرین ورود';
  static const String permissionRequest = 'لطفاً مجوزهای لازم را اعطا کنید';
  static const String notificationPermission = 'مجوز اعلان‌ها';
  static const String notificationPermissionDesc =
      'برای یادآوری تمرینات روزانه نیاز به ارسال نوتیفیکیشن داریم';
  static const String storagePermission = 'مجوز ذخیره‌سازی';
  static const String storagePermissionDesc =
      'برای ذخیره تصاویر و محتوای آموزشی به این مجوز نیاز داریم';

  // ─── Emotion Triangle ─────────────────────────────────────────
  static const String emotionTriangleTitle = 'مثلث هیجان';
  static const String emotionTriangleSubtitle =
      'هر ضلع مثلث را لمس کنید تا با یکی از ابعاد تجربه هیجانی آشنا شوید';
  static const String thoughtSide = 'فکر';
  static const String bodySide = 'بدن';
  static const String behaviorSide = 'رفتار';
  static const String thoughtDescription =
      'افکار ما تأثیر مستقیم بر احساسات و رفتار ما دارند. با شناسایی الگوهای فکری، می‌توانیم واکنش‌های بهتری انتخاب کنیم.';
  static const String bodyDescription =
      'بدن ما اولین نشانه‌های استرس و هیجان را نشان می‌دهد. با آگاهی از تنش‌های بدنی، می‌توانیم قبل از تشدید واکنش عمل کنیم.';
  static const String behaviorDescription =
      'رفتارهای ما نتیجه فکر و احساس ما هستند. با تغییر الگوهای رفتاری، می‌توانیم چرخه‌های ناسالم را بشکنیم.';
  static const String interactionSaved = 'تعامل هیجانی ثبت شد';
  static const String tapTriangleSide = 'یکی از اضلاع مثلث را لمس کنید';

  // ─── Body Tension Map ──────────────────────────────────────────
  static const String bodyTensionMapTitle = 'نقشه تنش بدنی';
  static const String bodyTensionMapSubtitle =
      'نواحی از بدن که تنش را احساس می‌کنید لمس کنید';
  static const String overallIntensity = 'شدت کلی';
  static const String intensityLevel = 'سطح شدت';
  static const String selectBodyRegions = 'نواحی بدن را انتخاب کنید';
  static const String tensionSaved = 'نقشه تنش بدنی ثبت شد';
  static const String tensionHistory = 'تاریخچه تنش بدنی';
  static const String noTensionHistory = 'هنوز ثبتی ندارید';
  static const String bodyRegionHead = 'سر';
  static const String bodyRegionNeck = 'گردن';
  static const String bodyRegionShoulders = 'شانه‌ها';
  static const String bodyRegionChest = 'قفسه سینه';
  static const String bodyRegionBack = 'پشت';
  static const String bodyRegionArms = 'دست‌ها';
  static const String bodyRegionAbdomen = 'شکم';
  static const String bodyRegionLegs = 'پاها';
  static const String lowIntensity = 'کم';
  static const String highIntensity = 'شدید';
  static const String addNote = 'یادداشت (اختیاری)';
  static const String saveTensionMap = 'ذخیره نقشه تنش';

  // ─── Stress Registration ───────────────────────────────────────
  static const String stressRegistrationTitle = 'ثبت استرس شغلی';
  static const String stressRegistrationSubtitle =
      'موقعیت استرس‌زای شغلی خود را انتخاب کنید';
  static const String stressSituationDeadline = 'فشار ددلاین';
  static const String stressSituationConflict = 'تعارض با همکار';
  static const String stressSituationWorkload = 'حجم کار زیاد';
  static const String stressSituationMeeting = 'جلسات پرفشار';
  static const String stressSituationSupervisor = 'فشار مدیر';
  static const String stressSituationUncertainty = 'عدم اطمینان شغلی';
  static const String stressSituationOvertime = 'اضافه‌کاری';
  static const String stressSituationResponsibility = 'مسئولیت بیش از حد';
  static const String stressDescriptionHint = 'توضیح بیشتری بدهید (اختیاری)';
  static const String stressIntensityLabel = 'شدت استرس را مشخص کنید';
  static const String submitStress = 'ثبت استرس';
  static const String stressSaved = 'رویداد استرس ثبت شد';
  static const String selectSituation = 'لطفاً یک موقعیت را انتخاب کنید';

  // ─── Breathing ─────────────────────────────────────────────────
  static const String breathingTitle = 'تنفس آگاهانه';
  static const String breathingSubtitle = 'با هر نفس، به لحظه حال بازگردید';
  static const String inhale = 'دم';
  static const String hold = 'نگه دارید';
  static const String exhale = 'بازدم';
  static const String breathingPattern = 'الگوی تنفس';
  static const String boxBreathing = 'تنفس جعبه‌ای';
  static const String boxBreathingDesc = '۴ ثانیه دم، ۴ نگه، ۴ بازدم، ۴ نگه';
  static const String deepBreathing = 'تنفس عمیق';
  static const String deepBreathingDesc = '۴ ثانیه دم، ۷ نگه، ۸ بازدم';
  static const String startBreathing = 'شروع تنفس';
  static const String stopBreathing = 'پایان تنفس';
  static const String sessionDuration = 'مدت جلسه';
  static const String sessionSaved = 'جلسه تنفس ثبت شد';
  static const String breathingCount = 'تعداد نفس';

  // ─── Resilience Education ──────────────────────────────────────
  static const String resilienceTitle = 'انعطاف‌پذیری روانی';
  static const String resilienceSubtitle = 'ستون بتنی در برابر نخل میلگرد';
  static const String concreteColumnTitle = 'ستون بتنی';
  static const String concreteColumnDesc =
      'بتن سخت و صلب است اما در برابر فشار زیاد می‌شکند. انسان هم اگر فقط سخت و انعطاف‌ناپذیر باشد، در برابر استرس می‌شکند.';
  static const String steelPalmTitle = 'نخل میلگرد';
  static const String steelPalmDesc =
      'نخل میلگرد در برابر باد خم می‌شود اما نمی‌شکند. انعطاف‌پذیری روانی یعنی توانایی سازگاری با شرایط سخت بدون شکستن درونی.';
  static const String resilienceLesson =
      'درس کلیدی: تاب‌آوری به معنای سخت بودن نیست، بلکه به معنای انعطاف‌پذیر بودن است. مانند نخل میلگرد، با تغییر شرایط سازگار شوید بدون اینکه اصول خود را رها کنید.';

  // ─── Common Actions ────────────────────────────────────────────
  static const String submit = 'ثبت';
  static const String history = 'تاریخچه';
  static const String back = 'بازگشت';
  static const String next = 'بعدی';
  static const String viewHistory = 'مشاهده تاریخچه';
  static const String noHistory = 'هنوز سابقه‌ای ثبت نشده';
  static const String featureLocked = 'این بخش در هفته فعلی فعال نیست';

  // ─── Cognitive Errors Game ─────────────────────────────────────
  static const String cognitiveGameTitle = 'بازی تشخیص خطای شناختی';
  static const String cognitiveGameSubtitle =
      'خطاهای شناختی را در موقعیت‌های کاری شناسایی کنید';
  static const String scenario = 'موقعیت';
  static const String dragErrorsHere = 'خطاهای شناختی را اینجا بکشید';
  static const String correctAnswer = 'پاسخ صحیح';
  static const String wrongAnswer = 'پاسخ نادرست';
  static const String yourScore = 'امتیاز شما';
  static const String gameResult = 'نتیجه بازی';
  static const String playAgain = 'بازی مجدد';
  static const String nextScenario = 'موقعیت بعدی';
  static const String scenarioOf = 'موقعیت';
  static const String cognitiveErrorTypes = 'انواع خطای شناختی';
  static const String allOrNothing = 'تفکر همه یا هیچ';
  static const String catastrophizing = 'فاجعه‌سازی';
  static const String mentalFilter = 'فیلتر ذهنی';
  static const String overgeneralization = 'تعمیم بیش از حد';
  static const String personalization = 'شخصی‌سازی';
  static const String blaming = 'سرزنش‌گری';
  static const String shouldStatements = 'بایدها و نبایدها';
  static const String emotionalReasoning = 'استدلال احساسی';
  static const String labeling = 'برچسب‌زنی';
  static const String fortuneTelling = 'پیش‌گویی منفی';
  static const String mindReading = 'ذهن‌خوانی';
  static const String discountingPositives = 'نادیده گرفتن مثبت‌ها';

  // ─── Cognitive Game Scenarios ──────────────────────────────────
  static const String scenario1Title = 'جلسه ارزیابی عملکرد';
  static const String scenario1Description =
      'در جلسه ارزیابی عملکرد، مدیرتان فقط به یک نکته منفی کوچک در گزارش شما اشاره می‌کند. بقیه گزارش عالی بوده اما شما فقط همان یک نقد کوچک را به خاطر می‌سپارید و فکر می‌کنید عملکردتان ضعیف بوده.';
  static const String scenario1Answer = 'فیلتر ذهنی';

  static const String scenario2Title = 'پروژه تیمی ناموفق';
  static const String scenario2Description =
      'پروژه تیمی به نتیجه نرسیده و شما بلافاصله فکر می‌کنید: «همیشه شکست می‌خورم، من اصلاً توانایی انجام کارهای بزرگ را ندارم.» در حالی که تا الان پروژه‌های موفقی هم داشته‌اید.';
  static const String scenario2Answer = 'تعمیم بیش از حد';

  static const String scenario3Title = 'بازخورد از همکار';
  static const String scenario3Description =
      'همکارتان می‌گوید ارائه شما می‌توانست بهتر باشد. شما بلافاصله نتیجه می‌گیرید: «او از من خوشش نمی‌آید و حتماً قصد دارد مرا خراب کند.» بدون اینکه شواهد دیگری بررسی کنید.';
  static const String scenario3Answer = 'ذهن‌خوانی';

  // ─── Mental Musts ──────────────────────────────────────────────
  static const String mentalMustTitle = 'کوله‌پشتی بایدهای ذهنی';
  static const String mentalMustSubtitle =
      'بایدهای ذهنی خود را بنویسید و یاد بگیرید آنها را رها کنید';
  static const String mentalMustInputHint =
      'یک «باید ذهنی» که همراه دارید بنویسید...';
  static const String mentalMustBackpackDesc =
      'هر سنگ در کوله‌پشتی نشان‌دهنده یک «باید ذهنی» است که شما همراه خود حمل می‌کنید. این بایدها مانند سنگ‌هایی سنگین، حرکت آزاد شما را محدود می‌کنند.';
  static const String addMentalMust = 'افزودن باید ذهنی';
  static const String releaseMust = 'رها کردن';
  static const String releasedMusts = 'بایدهای رها شده';
  static const String activeMusts = 'بایدهای فعال';
  static const String mustAdded = 'باید ذهنی ثبت شد';
  static const String mustReleased = 'باید ذهنی رها شد';
  static const String noMustsYet = 'هنوز باید ذهنی ثبت نکرده‌اید';
  static const String enterMustText = 'لطفاً متن باید ذهنی را وارد کنید';
  static const String backpackStones = 'سنگ‌های کوله‌پشتی';
  static const String releasedStones = 'سنگ‌های رها شده';

  // ─── Negative Thought Radar ────────────────────────────────────
  static const String negativeThoughtRadarTitle = 'رادار افکار منفی';
  static const String negativeThoughtRadarSubtitle =
      'افکار منفی خود را شناسایی، ثبت و مدیریت کنید';
  static const String instantReport = 'ثبت فوری';
  static const String instantReportSubtitle =
      'یک فکر منفی را همین الان ثبت کنید';
  static const String situationLabel = 'موقعیت';
  static const String situationHint = 'چه اتفاقی افتاد؟';
  static const String thoughtLabel = 'فکر منفی';
  static const String thoughtHint = 'چه فکری به ذهنتان آمد؟';
  static const String errorTypeLabel = 'نوع خطای شناختی';
  static const String selectErrorType = 'انتخاب نوع خطا';
  static const String thoughtRecorded = 'فکر منفی ثبت شد';
  static const String enterThought = 'لطفاً فکر منفی را وارد کنید';
  static const String enterSituation = 'لطفاً موقعیت را وارد کنید';

  // ─── Termite Animation ─────────────────────────────────────────
  static const String termiteAnimationTitle = 'موریانه‌های ذهن';
  static const String termiteAnimationSubtitle =
      'افکار منفی مانند موریانه‌ها سازه روانی شما را تخریب می‌کنند';
  static const String termiteEducationText =
      'همان‌طور که موریانه‌ها به آرامی و بدون سر و صدا یک سازه محکم را از درون تخریب می‌کنند، افکار منفی خودکار نیز ذهن و روان ما را فرسایش می‌دهند. اگر آنها را شناسایی نکنیم، به مرور زمان اعتماد به نفس، انگیزه و سلامت روان ما را از بین می‌برند.';
  static const String termiteKeyLesson =
      'درس کلیدی: با شناسایی و ثبت افکار منفی، مانند یک بازرس موریانه، جلوی تخریب درونی را بگیرید.';
  static const String buildingHealth = 'سلامت سازه';

  // ─── Thought Impact Assessment ─────────────────────────────────
  static const String thoughtImpactTitle = 'سنجش اثر فکر';
  static const String thoughtImpactSubtitle =
      'میزان تأثیر فکر منفی بر عملکردتان را بسنجید';
  static const String impactLevel = 'میزان تأثیر';
  static const String lowImpact = 'تأثیر کم';
  static const String highImpact = 'تأثیر زیاد';
  static const String impactSaved = 'سنجش اثر فکر ثبت شد';
  static const String thoughtImpactDesc =
      'یک فکر منفی را وارد کنید و مشخص کنید این فکر چقدر بر عملکرد روزانه شما تأثیر گذاشته است.';

  // ─── Mind Court (Week 5) ───────────────────────────────────────
  static const String mindCourtTitle = 'دادگاه ذهن';
  static const String mindCourtSubtitle =
      'فکر منفی را روی ترازوی شواهد بگذارید و آن را به محاکمه بکشید';
  static const String mindCourtBalanceTab = 'ترازوی شواهد';
  static const String mindCourtAlternativeTab = 'فکر جایگزین';
  static const String selectThoughtOnTrial = 'فکری که می‌خواهید محاکمه کنید';
  static const String selectThoughtHint = 'یک فکر منفی را انتخاب کنید';
  static const String supportingEvidenceLabel = 'شواهد تأییدکننده';
  static const String supportingEvidenceHint =
      'چه شواهدی این فکر را تأیید می‌کند؟';
  static const String contradictingEvidenceLabel = 'شواهد ردکننده';
  static const String contradictingEvidenceHint =
      'چه شواهدی — حتی کوچک — این فکر را رد می‌کند؟';
  static const String guideHelper = 'کمک راهنما';
  static const String guideHelperExamples =
      'نمونه پرسش‌ها برای یافتن شواهد:\n'
      '• آیا در گذشته خلاف این فکر ثابت شده است؟\n'
      '• یک دوست در این موقعیت چه می‌گفت؟\n'
      '• آیا واقعیت دیگری هست که این فکر آن را نادیده می‌گیرد؟\n'
      '• بدترین، بهترین و محتمل‌ترین حالت چیست؟';
  static const String alternativeThoughtLabel = 'فکر جایگزین منطقی';
  static const String alternativeThoughtHint =
      'با توجه به شواهد، یک فکر واقع‌بینانه و متعادل بنویسید...';
  static const String alternativeThoughtDesc =
      'حالا بر اساس شواهد دو طرف ترازو، یک فکر جایگزین منطقی و همخوان با واقعیت بسازید. این مسیر تازه‌ای در نقشه راه شماست.';
  static const String submitVerdict = 'ثبت حکم دادگاه';
  static const String mindCourtSaved = 'حکم دادگاه ذهن ثبت شد';
  static const String selectThoughtFirst = 'لطفاً ابتدا یک فکر را انتخاب کنید';
  static const String enterAlternativeThought =
      'لطفاً فکر جایگزین را وارد کنید';
  static const String noThoughtsToTrial =
      'هنوز فکر منفی‌ای ثبت نکرده‌اید. ابتدا در «رادار افکار منفی» یک فکر ثبت کنید.';
  static const String goToRadar = 'رفتن به رادار افکار منفی';

  // ─── Conflict Practice (Week 6) ────────────────────────────────
  static const String conflictExerciseTitle = 'تمرین تعارض';
  static const String conflictExerciseSubtitle =
      'در موقعیت‌های تعارض محیط کار، بهترین پاسخ را تمرین کنید';
  static const String conflictSituation = 'موقعیت تعارض';
  static const String chooseResponse = 'پاسخ خود را انتخاب کنید';
  static const String conflictFeedback = 'بازخورد';
  static const String practiceScore = 'امتیاز تمرین';
  static const String practiceAgain = 'تمرین مجدد';
  static const String nextConflict = 'موقعیت بعدی';
  static const String conflictFinished = 'تمرین به پایان رسید';
  static const String conflictSaved = 'تمرین تعارض ثبت شد';

  static const String conflictScenario1Title = 'انتقاد در جمع';
  static const String conflictScenario1Situation =
      'در جلسه تیمی، همکارتان جلوی بقیه از کیفیت کار شما انتقاد تندی می‌کند. چه واکنشی نشان می‌دهید؟';
  static const String conflictScenario1Best =
      'با آرامش می‌گویم بازخوردت را می‌شنوم و پیشنهاد می‌کنم بعد از جلسه جزئیات را بررسی کنیم';
  static const String conflictScenario1Option2 =
      'بلافاصله و با لحن تند از خودم دفاع می‌کنم و او را مقصر می‌دانم';
  static const String conflictScenario1Option3 =
      'سکوت می‌کنم، چیزی نمی‌گویم اما تا مدت‌ها دلخور می‌مانم';

  static const String conflictScenario2Title = 'اختلاف بر سر مسئولیت';
  static const String conflictScenario2Situation =
      'یک کار مشترک به تعویق افتاده و همکارتان تقصیر را گردن شما می‌اندازد. بهترین پاسخ کدام است؟';
  static const String conflictScenario2Best =
      'پیشنهاد می‌کنم با هم مرور کنیم هر کدام چه بخشی را بر عهده داشتیم تا راه‌حل پیدا کنیم';
  static const String conflictScenario2Option2 =
      'داد می‌زنم که اصلاً تقصیر من نبوده و همه‌اش کار او بوده است';
  static const String conflictScenario2Option3 =
      'برای پایان دادن به بحث، مسئولیت کامل را می‌پذیرم حتی اگر منصفانه نباشد';

  static const String conflictScenario3Title = 'درخواست غیرمنتظره مدیر';
  static const String conflictScenario3Situation =
      'مدیرتان در پایان روز کاری، کار فوری جدیدی می‌خواهد در حالی که برنامه شخصی دارید. چطور پاسخ می‌دهید؟';
  static const String conflictScenario3Best =
      'اهمیت کار را می‌پذیرم و شفاف می‌گویم امروز محدودیت زمانی دارم و پیشنهاد زمان‌بندی جایگزین می‌دهم';
  static const String conflictScenario3Option2 =
      'بدون هیچ حرفی می‌پذیرم و برنامه شخصی‌ام را کنسل می‌کنم و ناراحت می‌شوم';
  static const String conflictScenario3Option3 =
      'با عصبانیت می‌گویم این کار به من ربطی ندارد و بیرون می‌روم';

  static const String conflictFeedbackBest =
      'عالی! این پاسخ قاطعانه و محترمانه است — هم به نیاز خودتان توجه دارد و هم به رابطه.';
  static const String conflictFeedbackMedium =
      'این پاسخ تنش را کم نمی‌کند. تلاش کنید نیازتان را محترمانه اما شفاف بیان کنید.';
  static const String conflictFeedbackLow =
      'این پاسخ ممکن است تعارض را تشدید کند یا نیاز شما را نادیده بگیرد. پاسخ قاطعانه‌تری را تمرین کنید.';

  // ─── Mood & Activity (Week 7) ──────────────────────────────────
  // Isolation cycle animation
  static const String isolationCycleTitle = 'چرخه انزوا';
  static const String isolationCycleSubtitle =
      'وقتی فشار کار زیاد می‌شود، بدون آنکه متوجه شویم وارد یک چرخه نزولی می‌شویم. با شکستن این چرخه، خلق دوباره بالا می‌آید.';
  static const String isolationStagePressure = 'فشار کار';
  static const String isolationStageLessActivity = 'کاهش فعالیت';
  static const String isolationStageLowMood = 'کاهش خلق';
  static const String isolationStageIsolation = 'انزوای بیشتر';
  static const String isolationBreakCta = 'شکستن چرخه با یک فعالیت خرد';
  static const String isolationCycleMessage =
      'یک قدم کوچک کافی است تا مسیر برعکس شود: فعالیت خرد → خلق بهتر → ارتباط بیشتر.';

  // Micro activities menu
  static const String microActivitiesTitle = 'فعالیت‌های خرد';
  static const String microActivitiesSubtitle =
      'یک فعالیت کوچک انتخاب کنید و اثر آن را بر خلق خود بسنجید.';
  static const String microActivityCallFriend = 'تماس با دوست';
  static const String microActivityCallFriendDesc =
      'یک تماس کوتاه با کسی که دوستش دارید';
  static const String microActivityReading = 'مطالعه غیرکاری';
  static const String microActivityReadingDesc =
      'چند صفحه از یک کتاب یا مطلب دلخواه';
  static const String microActivityTea = 'دم کردن چای با تمرکز';
  static const String microActivityTeaDesc =
      'یک فنجان چای را با حضور کامل ذهن آماده کنید';
  static const String microActivityExercise = 'ورزش خرد';
  static const String microActivityExerciseDesc =
      'چند حرکت کششی یا پیاده‌روی کوتاه';
  static const String microActivityMusic = 'موسیقی';
  static const String microActivityMusicDesc =
      'گوش دادن به یک قطعه موسیقی آرامش‌بخش';
  static const String startActivityTracking = 'شروع و پیگیری';

  // Mood tracker
  static const String moodTrackerTitle = 'ردیاب خلق';
  static const String moodTrackerSubtitle =
      'خلق خود را قبل و بعد از فعالیت بسنجید تا اثر حرکت را ببینید.';
  static const String selectedActivityLabel = 'فعالیت انتخاب‌شده';
  static const String chooseActivityFirst = 'ابتدا یک فعالیت انتخاب کنید';
  static const String moodBeforeLabel = 'خلق شما پیش از فعالیت چطور است؟';
  static const String moodAfterLabel = 'خلق شما پس از فعالیت چطور است؟';
  static const String startActivityButton = 'فعالیت را شروع کردم';
  static const String submitMood = 'ثبت خلق';
  static const String moodBefore = 'خلق قبل';
  static const String moodAfter = 'خلق بعد';
  static const String moodDelta = 'تغییر خلق';
  static const String moodTrackerSaved = 'ردیاب خلق ثبت شد';
  static const String moodImprovedMessage =
      'حرکت کوچک شما خلق‌تان را بهتر کرد. همین اثبات می‌کند فعالیت مؤثر است.';
  static const String moodSameMessage =
      'خلق شما ثابت ماند؛ تکرار فعالیت‌های خرد در طول روز اثر خود را نشان می‌دهد.';
  static const String moodLowerMessage =
      'گاهی خلق بلافاصله بهتر نمی‌شود؛ اما تداوم فعالیت، چرخه انزوا را می‌شکند.';
  static const String moodHistoryTitle = 'روند خلق شما';
  static const String noMoodHistory = 'هنوز رکوردی ثبت نشده است';
  static const String trackAnotherActivity = 'فعالیت دیگری را پیگیری کنید';

  // ─── Role Balance & Thought Sky (Week 8) ───────────────────────
  // Role balance
  static const String roleBalanceTitle = 'تعادل نقش‌ها';
  static const String roleBalanceSubtitle =
      'نقش سازمانی و ارزش‌های فردی خود را کنار هم ببینید و برای تعادل میان آن‌ها بکوشید.';
  static const String organizationalRole = 'نقش سازمانی';
  static const String personalValues = 'ارزش‌های فردی';
  static const String addRoleHint = 'مثلاً: مدیر پروژه، کارشناس فروش';
  static const String addValueHint = 'مثلاً: پدر بودن، همسر مهربان، دوست خوب';
  static const String addRoleButton = 'افزودن نقش';
  static const String addValueButton = 'افزودن ارزش';
  static const String roleValueSaved = 'ثبت شد';
  static const String enterTextFirst = 'لطفاً متن را وارد کنید';
  static const String noRolesYet = 'هنوز نقشی ثبت نشده است';
  static const String noValuesYet = 'هنوز ارزشی ثبت نشده است';
  static const String roleBalanceTensionMessage =
      'تنش میان نقش کاری و ارزش‌های شخصی طبیعی است؛ آگاهی از آن، اولین گام برای ایجاد تعادل است.';

  // Thought sky
  static const String thoughtSkyTitle = 'آسمان افکار';
  static const String thoughtSkySubtitle =
      'افکار منفی را بنویسید تا به ابر تبدیل شوند، سپس با یک سوایپ آن‌ها را از آسمان ذهن‌تان عبور دهید.';
  static const String thoughtSkyInputHint = 'یک فکر منفی را اینجا بنویسید...';
  static const String releaseThought = 'رها کردن به آسمان';
  static const String thoughtSkyMantra = 'من آسمانم، ابرها در حال عبورند';
  static const String swipeToPass = 'برای عبور ابر، آن را بکشید';
  static const String thoughtReleased = 'فکر رها شد';
  static const String skyEmptyMessage =
      'آسمان ذهن شما صاف است. هر فکری که آمد، آن را به ابری بسپارید.';

  // ─── Profile ─────────────────────────────────────────────────────
  static const String profileTitle = 'پروفایل من';
  static const String accountInfo = 'اطلاعات حساب';
  static const String phoneNumberLabel = 'شماره تلفن';
  static const String registrationDateLabel = 'تاریخ ثبت‌نام';
  static const String lastLoginLabel = 'آخرین ورود';
  static const String loginCountLabel = 'تعداد ورودها';
  static const String agreementStatusLabel = 'وضعیت میثاق‌نامه';
  static const String agreementAccepted = 'پذیرفته شده';
  static const String agreementNotAccepted = 'هنوز نپذیرفته‌اید';
  static const String appSettings = 'تنظیمات برنامه';
  static const String cloudSyncLabel = 'همگام‌سازی ابری';
  static const String cloudSyncDesc =
      'ذخیره و همگام‌سازی خودکار داده‌ها در فضای ابری';
  static const String doNotDisturbLabel = 'حالت مزاحم نشوید';
  static const String doNotDisturbDesc =
      'غیرفعال‌سازی اعلان‌ها در بازه زمانی مشخص';
  static const String dndStartTime = 'ساعت شروع';
  static const String dndEndTime = 'ساعت پایان';
  static const String securitySection = 'امنیت';
  static const String changePassword = 'تغییر رمز عبور';
  static const String currentPassword = 'رمز عبور فعلی';
  static const String newPassword = 'رمز عبور جدید';
  static const String passwordChanged = 'رمز عبور با موفقیت تغییر کرد';
  static const String deviceInfo = 'اطلاعات دستگاه';
  static const String androidVersionLabel = 'نسخه اندروید';
  static const String appVersionLabel = 'نسخه برنامه';
  static const String profileUpdated = 'پروفایل با موفقیت بروزرسانی شد';
  static const String notAvailable = 'نامشخص';
  static const String timeFormat = 'HH:mm';
}
