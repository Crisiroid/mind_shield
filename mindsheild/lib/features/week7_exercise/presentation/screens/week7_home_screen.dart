import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../view_models/week7_view_model.dart';
import 'day43_screen.dart';
import 'day44_screen.dart';
import 'day45_screen.dart';
import 'day46_screen.dart';
import 'day47_screen.dart';
import 'day48_screen.dart';
import 'day49_screen.dart';

class Week7HomeScreen extends StatefulWidget {
  const Week7HomeScreen({super.key});

  @override
  State<Week7HomeScreen> createState() => _Week7HomeScreenState();
}

class _Week7HomeScreenState extends State<Week7HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Week7ViewModel>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'هفته هفتم: حل مسئله گام\u200cبه\u200cگام',
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<Week7ViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Auto-navigate to today's exercise if not yet completed and unlocked.
          // Uses the VM's flag so auto-nav only fires once per data-load cycle,
          // not again when the user pops back from a day screen.
          // Only run this check after data is fully loaded to avoid race conditions.
          if (!vm.hasAutoNavigated && vm.isDataLoaded) {
            vm.markAutoNavigated();
            final pd = vm.currentProgramDay;
            if (pd >= 43 && pd <= 49 && !vm.isDayCompleted(pd)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _navigateToDay(pd);
              });
            }
          }

          return SingleChildScrollView(
            padding: AppSizes.paddingScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today card
                _buildTodayCard(vm),
                SizedBox(height: AppSizes.lg),
                // Day list
                Text(
                  'روزهای هفته',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSizes.md),
                ...List.generate(7, (i) {
                  final dayNum = i + 43;
                  return _buildDayTile(vm, dayNum);
                }),
                SizedBox(height: AppSizes.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayCard(Week7ViewModel vm) {
    int todayDay = 43;
    for (int i = 43; i <= 49; i++) {
      if (!vm.isDayCompleted(i)) {
        todayDay = i;
        break;
      }
      if (i == 49) todayDay = 49;
    }

    final allComplete = List.generate(
      7,
      (i) => i + 43,
    ).every(vm.isDayCompleted);
    final titles = [
      'آیا این موضوع قابل\u200cحل است؟',
      'مشکل را روشن و محدود کنیم',
      'چند راه ممکن',
      'ارزیابی راه\u200cحل\u200cها',
      'برنامه اقدام',
      'درخواست روشن و محترمانه',
      'مرور نتیجه',
    ];
    final durations = [7, 8, 7, 8, 8, 8, 10];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            allComplete ? 'تبریک!' : 'تمرین امروز',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: AppColors.textOnPrimary.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            allComplete
                ? 'تمرین امروز تکمیل شد.'
                : 'روز $todayDay: ${titles[todayDay - 43]}',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          if (!allComplete) ...[
            SizedBox(height: AppSizes.xs),
            Text(
              'حدود ${durations[todayDay - 43]} دقیقه',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textOnPrimary.withValues(alpha: 0.7),
              ),
            ),
          ],
          SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textOnPrimary,
                foregroundColor: AppColors.primary,
              ),
              onPressed: () => _navigateToDay(todayDay),
              child: Text(
                allComplete ? 'مرور محتوا' : 'شروع تمرین',
                style: PersianFonts.Vazir.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTile(Week7ViewModel vm, int dayNumber) {
    final titles = [
      'آیا این موضوع قابل\u200cحل است؟',
      'مشکل را روشن و محدود کنیم',
      'چند راه ممکن',
      'ارزیابی راه\u200cحل\u200cها',
      'برنامه اقدام',
      'درخواست روشن و محترمانه',
      'مرور نتیجه',
    ];

    final isCompleted = vm.isDayCompleted(dayNumber);
    final isUnlocked = vm.isDayUnlocked(dayNumber);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSizes.sm),
      child: Material(
        color: isUnlocked ? AppColors.surface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: isUnlocked ? () => _navigateToDay(dayNumber) : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: isCompleted
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success.withValues(alpha: 0.1)
                        : isUnlocked
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : isUnlocked
                        ? Icons.play_circle_outline
                        : Icons.lock_outline,
                    color: isCompleted
                        ? AppColors.success
                        : isUnlocked
                        ? AppColors.primary
                        : AppColors.textHint,
                    size: 22,
                  ),
                ),
                SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'روز $dayNumber: ${titles[dayNumber - 43]}',
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                      if (isCompleted)
                        Text(
                          'تکمیل شده',
                          style: PersianFonts.Vazir.copyWith(
                            fontSize: AppSizes.fontXs,
                            color: AppColors.success,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isUnlocked)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textHint,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDay(int dayNumber) {
    final screens = [
      const Day43Screen(),
      const Day44Screen(),
      const Day45Screen(),
      const Day46Screen(),
      const Day47Screen(),
      const Day48Screen(),
      const Day49Screen(),
    ];

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => screens[dayNumber - 43]));
  }
}
