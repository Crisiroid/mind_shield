import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../../core/services/token_service.dart';
import '../../../auth/presentation/view_models/auth_view_model.dart';
import '../view_models/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasAutoNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeVM = context.read<HomeViewModel>();
      await homeVM.init();

      // Auto-navigate to today's exercise if not yet completed
      if (!_hasAutoNavigated && !homeVM.isTodayExerciseDone) {
        _hasAutoNavigated = true;
        final route = homeVM.getStartExerciseRoute();
        if (route != null && mounted) {
          Navigator.of(context).pushNamed(route);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.home),
        actions: [
          Consumer<AppProvider>(
            builder: (context, app, _) {
              return Padding(
                padding: EdgeInsets.only(left: AppSizes.md),
                child: Row(
                  children: [
                    Icon(
                      app.isOnline ? Icons.wifi : Icons.wifi_off,
                      color: app.isOnline ? AppColors.success : AppColors.error,
                      size: AppSizes.iconMd,
                    ),
                    if (app.isSyncing) ...[
                      SizedBox(width: AppSizes.xs),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          SizedBox(width: AppSizes.sm),
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.info),
            tooltip: AppStrings.help,
            onPressed: () => Navigator.of(context).pushNamed('/help'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            tooltip: AppStrings.profile,
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: AppStrings.logout,
            onPressed: () => _onLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => homeVM.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSizes.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressCalendarCard(homeVM),

              SizedBox(height: AppSizes.xl),

              Text(
                '${AppStrings.weekTools} ${homeVM.currentWeek}',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSizes.md),
              _buildToolsGrid(homeVM.getCurrentWeekTools(context)),

              SizedBox(height: AppSizes.xl),

              Text(
                AppStrings.permanentTools,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSizes.md),
              _buildToolsGrid(homeVM.getPermanentTools(context)),

              SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCalendarCard(HomeViewModel homeVM) {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    final currentDayIndex = WeekCalculator.currentDayIndex(registrationDate);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress header
          Text(
            AppStrings.weeklyProgress,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${homeVM.currentWeek}',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8, right: 4),
                child: Text(
                  '${AppStrings.week} از ۸',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: Colors.white70,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${AppStrings.programDay} ${homeVM.currentDay}',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'از ۵۶ روز',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: LinearProgressIndicator(
              value: homeVM.progress,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            '${(homeVM.progress * 100).toInt()}٪ ${AppStrings.overallProgress}',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: Colors.white70,
            ),
          ),

          // Calendar section
          SizedBox(height: AppSizes.lg),
          Divider(color: Colors.white.withValues(alpha: 0.3), height: 1),
          SizedBox(height: AppSizes.md),
          Text(
            AppStrings.calendar56Days,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSizes.sm),

          // Day headers (1-7)
          Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  AppStrings.week,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontXs,
                    color: Colors.white60,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    7,
                    (i) => Expanded(
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: PersianFonts.Vazir.copyWith(
                            fontSize: AppSizes.fontXs,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.xs),

          // 8 weeks x 7 days grid
          ...List.generate(8, (weekIndex) {
            return Padding(
              padding: EdgeInsets.only(bottom: weekIndex < 7 ? 3 : 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${weekIndex + 1}',
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontXs,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (dayIndex) {
                        final dayNumber = weekIndex * 7 + dayIndex;
                        final isCurrent = dayNumber == currentDayIndex;
                        final isPast = dayNumber < currentDayIndex;

                        return Expanded(
                          child: Center(
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? Colors.white
                                    : isPast
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(5),
                                border: isCurrent
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: isPast
                                    ? Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      )
                                    : Text(
                                        '${dayNumber + 1}',
                                        style: PersianFonts.Vazir.copyWith(
                                          fontSize: AppSizes.fontXs,
                                          fontWeight: isCurrent
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isCurrent
                                              ? AppColors.primary
                                              : Colors.white.withValues(
                                                  alpha: isPast ? 1.0 : 0.7,
                                                ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(List<ToolItem> tools) {
    if (tools.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Center(
          child: Text(
            AppStrings.noContent,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSizes.md,
      crossAxisSpacing: AppSizes.md,
      childAspectRatio: 1.1,
      children: tools
          .map(
            (tool) => _ToolCard(
              icon: tool.icon,
              label: tool.label,
              color: tool.color,
              onTap: tool.onTap ?? () {},
            ),
          )
          .toList(),
    );
  }

  Future<void> _onLogout(BuildContext context) async {
    final confirmed = await DialogService.showConfirm(
      title: AppStrings.logout,
      message: AppStrings.logoutConfirm,
    );
    if (!confirmed) return;

    final navContext = DialogService.navigatorKey?.currentContext;
    if (navContext != null) {
      final auth = navContext.read<AuthViewModel>();
      await auth.logout();
      if (navContext.mounted) {
        Navigator.of(navContext).pushReplacementNamed('/login');
      }
    }
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.divider),
          ),
          padding: EdgeInsets.all(AppSizes.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(height: AppSizes.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
