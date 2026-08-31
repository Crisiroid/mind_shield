import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../view_models/week5_view_model.dart';
import 'day29_screen.dart';
import 'day30_screen.dart';
import 'day31_screen.dart';
import 'day32_screen.dart';
import 'day33_screen.dart';
import 'day34_screen.dart';
import 'day35_screen.dart';

class Week5HomeScreen extends StatefulWidget {
  const Week5HomeScreen({super.key});

  @override
  State<Week5HomeScreen> createState() => _Week5HomeScreenState();
}

class _Week5HomeScreenState extends State<Week5HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Week5ViewModel>().loadData();
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
          'هفته پنجم: فعالیت، انرژی و خلق',
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<Week5ViewModel>(
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
            if (pd >= 29 && pd <= 35 && !vm.isDayCompleted(pd)) {
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
                  final dayNum = i + 29;
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

  Widget _buildTodayCard(Week5ViewModel vm) {
    int todayDay = 29;
    for (int i = 29; i <= 35; i++) {
      if (!vm.isDayCompleted(i)) {
        todayDay = i;
        break;
      }
      if (i == 35) todayDay = 35;
    }

    final allComplete = List.generate(
      7,
      (i) => i + 29,
    ).every(vm.isDayCompleted);
    final titles = [
      'فعالیت چه اثری دارد؟',
      'فعالیت کوچک انتخاب کنیم',
      'برنامه\u200cریزی فعالیت',
      'انجام فعالیت',
      'لذت و احساس پیشرفت',
      'موانع و قدم\u200cهای کوچک',
      'برنامه شخصی فعالیت',
    ];
    final durations = [6, 7, 7, 5, 6, 7, 10];

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
                : 'روز $todayDay: ${titles[todayDay - 29]}',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          if (!allComplete) ...[
            SizedBox(height: AppSizes.xs),
            Text(
              'حدود ${durations[todayDay - 29]} دقیقه',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textOnPrimary.withValues(alpha: 0.7),
              ),
            ),
            if (todayDay == 32) ...[
              SizedBox(height: AppSizes.xs),
              Text(
                'زمان انجام فعالیت جداگانه است.',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textOnPrimary.withValues(alpha: 0.6),
                ),
              ),
            ],
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

  Widget _buildDayTile(Week5ViewModel vm, int dayNumber) {
    final titles = [
      'فعالیت چه اثری دارد؟',
      'فعالیت کوچک انتخاب کنیم',
      'برنامه\u200cریزی فعالیت',
      'انجام فعالیت',
      'لذت و احساس پیشرفت',
      'موانع و قدم\u200cهای کوچک',
      'برنامه شخصی فعالیت',
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
                        'روز $dayNumber: ${titles[dayNumber - 29]}',
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
      const Day29Screen(),
      const Day30Screen(),
      const Day31Screen(),
      const Day32Screen(),
      const Day33Screen(),
      const Day34Screen(),
      const Day35Screen(),
    ];

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => screens[dayNumber - 29]));
  }
}
