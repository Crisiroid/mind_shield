# سپر روان — ساختار پروژه و قوانین توسعه

## نمای کلی پروژه

اپلیکیشن فلاتر برای روان‌شناسی و سلامت روان. تمام رابط کاربری فارسی و راست‌چین (RTL) است و هیچ سیستم زبان‌بندی یا تعویض زبان در پروژه وجود ندارد.

---

## ساختار پوشه‌ها

```
lib/
├── main.dart                          # نقطه ورود — مقداردهی اولیه سرویس‌ها
├── app.dart                           # ویجت ریشه — تنظیم Provider، تم، مسیرها
├── core/
│   ├── config/
│   │   └── app_config.dart            # تنظیمات محیطی (debug/production)
│   ├── constants/
│   │   ├── api_constants.dart         # آدرس‌های API و تایم‌اوت‌ها
│   │   ├── app_colors.dart            # پالت رنگ‌های متمرکز
│   │   ├── app_sizes.dart             # فاصله‌ها، اندازه‌ها، مقیاس پاسخگو
│   │   └── app_strings.dart           # تمام متن‌های فارسی (بدون localization)
│   ├── errors/
│   │   ├── exceptions.dart            # کلاس‌های استثنای تایپ‌شده
│   │   └── failures.dart              # کلاس‌های Failure برای الگوی Either
│   ├── network/
│   │   ├── dio_client.dart            # تنظیم Dio و NetworkInfo
│   │   └── api_interceptor.dart       # اینترسپتر — تبدیل خطاهای HTTP به Exception
│   ├── providers/
│   │   └── app_provider.dart          # وضعیت اتصال و همگام‌سازی
│   ├── services/
│   │   ├── dialog_service.dart        # نمایش دیالوگ (خطا، موفقیت، لودینگ، تایید)
│   │   ├── storage_service.dart       # دیتابیس محلی SQLite
│   │   └── sync_service.dart          # صف همگام‌سازی آفلاین → سرور
│   ├── theme/
│   │   └── app_theme.dart             # تم کامل با فونت فارسی وزیرمتن
│   └── utils/
│       └── responsive_utils.dart      # محاسبه مقیاس برای اندازه‌های مختلف صفحه
├── features/
│   ├── auth/
│   │   ├── data/repositories/
│   │   │   └── auth_repository.dart   # مخزن احراز هویت
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── login_screen.dart  # صفحه ورود
│   │       └── view_models/
│   │           └── auth_view_model.dart
│   └── home/
│       └── presentation/
│           └── screens/
│               └── home_screen.dart   # صفحه اصلی
└── shared/
    └── widgets/
        └── app_loading_indicator.dart # ویجت‌های مشترک (لودینگ، خطا، خالی)
```

---

## پکیج‌های استفاده‌شده

| پکیج | کاربرد |
|---|---|
| `provider` | مدیریت وضعیت (State Management) |
| `dio` | کلاینت HTTP با پشتیبانی از اینترسپتر |
| `internet_connection_checker_plus` | بررسی وضعیت اتصال اینترنت |
| `sqflite` | دیتابیس محلی SQLite برای ذخیره آفلاین |
| `path_provider` | مسیر فایل‌های محلی |
| `shared_preferences` | ذخیره تنظیمات ساده |
| `dartz` | الگوی Either برای مدیریت خطای تایپ‌شده |
| `persian_fonts` | فونت فارسی وزیرمتن (نسخه 1.0.6) |
| `cupertino_icons` | آیکون‌های iOS |

---

## قوانین و اصول توسعه

### ۱. زبان فارسی — بدون localization

- تمام متن‌های رابط کاربری فارسی هستند.
- هیچ سیستم localization یا فایل ARB وجود ندارد.
- تمام رشته‌ها در `core/constants/app_strings.dart` تعریف می‌شوند.
- جهت صفحه به صورت دستی RTL تنظیم شده (`locale: Locale('fa')`).
- فونت تمام ویجت‌ها از طریق `PersianFonts.vazirmatnTextStyle()` تنظیم می‌شود.

### ۲. مدیریت خطا — فقط دیالوگ

- تمام پیام‌های خطا و وضعیت از طریق `DialogService` نمایش داده می‌شوند.
- استفاده از SnackBar ممنوع است.
- انواع دیالوگ: خطا، موفقیت، تایید، لودینگ، آفلاین.
- پیام‌های خطا به فارسی هستند — هرگز رشته خام سرور نمایش داده نمی‌شود.

### ۳. اینترسپتر HTTP

- `ApiInterceptor` تمام خطاهای HTTP را به `AppException` تایپ‌شده تبدیل می‌کند.
- کدهای وضعیت: 400 (bad request)، 401 (unauthorized)، 403 (forbidden)، 404 (not found)، 500/502/503 (server error).
- کد فراموشی: هیچ‌جا مستقیماً با DioException کار نمی‌کنیم — فقط با `AppException`.
- `LoggingInterceptor` فقط در حالت debug فعال است.

### ۴. ذخیره‌سازی آفلاین و همگام‌سازی

- داده‌ها ابتدا در `sqflite` ذخیره می‌شوند.
- اگر اینترنت قطع باشد، درخواست‌ها در جدول `pending_sync` صف‌بندی می‌شوند.
- `SyncService` به محض برقراری اتصال، صف را پردازش می‌کند.
- حداکثر ۳ بار تلاش مجدد برای هر درخواست.
- `AppProvider` تغییرات اتصال را گوش می‌دهد و همگام‌سازی را خودکار آغاز می‌کند.

### ۵. مدیریت وضعیت — Provider

- از `provider` برای state management استفاده می‌شود.
- هر فیچر `ChangeNotifier` (ViewModel) خود را دارد.
- `MultiProvider` در `app.dart` تمام provider‌ها را تزریق می‌کند.
- برای دسترسی: `context.read<T>()` برای یک‌بار مصرف، `Consumer<T>` برای واکنش‌گرا.

### ۶. اصول SOLID

| اصل | نحوه اعمال |
|---|---|
| Single Responsibility | هر کلاس یک وظیفه دارد (DioClient فقط HTTP، StorageService فقط DB، DialogService فقط دیالوگ) |
| Open/Closed | تم‌ها، رنگ‌ها و اندازه‌ها قابل گسترش بدون تغییر کد موجود |
| Liskov Substitution | تمام Exceptionها از `AppException` ارث می‌برند |
| Interface Segregation | `NetworkInfo` فقط متد `isConnected` را در اختیار مصرف‌کننده قرار می‌دهد |
| Dependency Inversion | لایه‌ها به abstraction وابسته‌اند نه implementation (Repository pattern + dartz Either) |

### ۷. طراحی پاسخگو (Responsive)

- `ResponsiveUtils` مقیاس صفحه را بر اساس عرض طراحی (375dp) محاسبه می‌کند.
- `AppSizes.scale` در شروع برنامه تنظیم می‌شود.
- تمام فاصله‌ها، اندازه فونت‌ها، آیکون‌ها و ارتفاع دکمه‌ها بر اساس مقیاس تنظیم می‌شوند.
- متدهای `isTablet()` و `isDesktop()` برای تشخیص نوع دستگاه.

### ۸. ساختار فیچر‌محور

- هر فیچر شامل: `data/` (repositories, models)، `domain/` (entities, usecases)، `presentation/` (screens, view_models).
- مخازن (repositories) از الگوی `Either<Failure, T>` استفاده می‌کنند.
- ویجت‌های مشترک در `shared/widgets/` قرار دارند.

### ۹. تم و رنگ‌بندی

- تمام رنگ‌ها در `AppColors` تعریف شده‌اند.
- گرادیانت‌های اصلی: `primaryGradient` (بنفش → صورتی)، `warmGradient`، `coolGradient`.
- فونت: وزیرمتن از `persian_fonts: ^1.0.6`.
- تم Material 3 فعال است.

---

## شروع کار

```bash
# نصب پکیج‌ها
flutter pub get

# اجرای پروژه
flutter run

# ساخت APK
flutter build apk
```

---

## نکات مهم

- آدرس سرور در `ApiConstants.baseUrl` تنظیم شده (پیش‌فرض: `http://10.0.2.2:8080` برای شبیه‌ساز اندروید).
- برای دستگاه فیزیکی، آدرس IP سرور را جایگزین کنید.
- `AppConfig.isDebug` را برای نسخه production به `false` تغییر دهید.
- توکن احراز هویت باید از طریق secure storage خوانده و در `ApiInterceptor.onRequest` اضافه شود.
