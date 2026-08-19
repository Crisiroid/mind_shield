import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../view_models/week3_view_model.dart';
import 'day15_screen.dart';
import 'day16_screen.dart';
import 'day17_screen.dart';
import 'day18_screen.dart';
import 'day19_screen.dart';
import 'day20_screen.dart';
import 'day21_screen.dart';

class Week3HomeScreen extends StatefulWidget {
  const Week3HomeScreen({super.key});

  @override
  State<Week3HomeScreen> createState() => _Week3HomeScreenState();
}

class _Week3HomeScreenState extends State<Week3HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Week3ViewModel>().loadData();
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
          'هفته سوم: شناخت افکار خودکار',
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<Week3ViewModel>(
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
            if (pd >= 15 && pd <= 21 && !vm.isDayCompleted(pd)) {
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
                  final dayNum = i + 15;
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

  Widget _buildTodayCard(Week3ViewModel vm) {
    int todayDay = 15;
    for (int i = 15; i <= 21; i++) {
      if (!vm.isDayCompleted(i)) {
        todayDay = i;
        break;
      }
      if (i == 21) todayDay = 21;
    }

    final allComplete = List.generate(
      7,
      (i) => i + 15,
    ).every(vm.isDayCompleted);
    final titles = [
      'فکرهای سریع ذهن',
      'فکر چه اثری دارد؟',
      'همه یا هیچ',
      'پیش‌بینی منفی',
      'ذهن‌خوانی و بایدهای ذهنی',
      'ثبت فکر خودکار',
      'مرور هفته سوم',
    ];
    final durations = [6, 6, 7, 7, 7, 6, 8];

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
                : 'روز $todayDay: ${titles[todayDay - 15]}',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          if (!allComplete) ...[
            SizedBox(height: AppSizes.xs),
            Text(
              'حدود ${durations[todayDay - 15]} دقیقه',
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

  Widget _buildDayTile(Week3ViewModel vm, int dayNumber) {
    final titles = [
      'فکرهای سریع ذهن',
      'فکر چه اثری دارد؟',
      'همه یا هیچ',
      'پیش‌بینی منفی',
      'ذهن‌خوانی و بایدهای ذهنی',
      'ثبت فکر خودکار',
      'مرور هفته سوم',
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
                        'روز $dayNumber: ${titles[dayNumber - 15]}',
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
      const Day15Screen(),
      const Day16Screen(),
      const Day17Screen(),
      const Day18Screen(),
      const Day19Screen(),
      const Day20Screen(),
      const Day21Screen(),
    ];

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => screens[dayNumber - 15]));
  }
}
