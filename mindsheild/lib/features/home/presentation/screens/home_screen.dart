import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../auth/presentation/view_models/auth_view_model.dart';
import '../view_models/home_view_model.dart';
import '../widgets/mini_calendar_grid.dart';
import '../widgets/todays_exercise_card.dart';

/// Home screen — main dashboard after authentication.
///
/// Shows:
/// - Weekly progress bar and current week/day info (calculated locally)
/// - 56-day calendar with current day indicator
/// - Today's exercise content (from weekly media)
/// - Quick access tools for current week
/// - Permanent tools available throughout the program
/// - Connectivity status
/// - Logout action
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().init();
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
              // ─── Progress Card ──────────────────────────────────
              _buildProgressCard(homeVM),

              SizedBox(height: AppSizes.xl),

              // ─── Today's Exercise ───────────────────────────────
              Text(
                AppStrings.todaysContent,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSizes.md),
              TodaysExerciseCard(
                mediaList: homeVM.weeklyMedia,
                currentWeek: homeVM.currentWeek,
                currentDay: homeVM.currentDay,
                onStartExercise: () {
                  final route = homeVM.getStartExerciseRoute();
                  if (route != null) {
                    Navigator.of(context).pushNamed(route);
                  }
                },
              ),

              SizedBox(height: AppSizes.xl),

              // ─── 56-Day Calendar ────────────────────────────────
              const MiniCalendarGrid(),

              SizedBox(height: AppSizes.xl),

              // ─── Current Week Tools ─────────────────────────────
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

              // ─── Permanent Tools ────────────────────────────────
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

  Widget _buildProgressCard(HomeViewModel homeVM) {
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
      // ignore: use_build_context_synchronously
      final auth = navContext.read<AuthViewModel>();
      await auth.logout();
      if (navContext.mounted) {
        Navigator.of(navContext).pushReplacementNamed('/login');
      }
    }
  }
}

/// Quick-access tool card widget.
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
