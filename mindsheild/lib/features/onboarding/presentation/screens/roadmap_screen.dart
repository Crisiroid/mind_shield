import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../view_models/onboarding_view_model.dart';

/// 56-Day Roadmap Infographic Screen (Screen 3 of Phase Zero).
///
/// Displays the 8-week journey overview with visual indicators:
/// - Week-by-week content descriptions
/// - Current week is visually highlighted using stored registration date
/// - "Start" button to enter the main app
///
/// Only shown once after first successful registration/login.
class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  // ─── Week Data ────────────────────────────────────────────
  static const List<_WeekData> _weeks = [
    _WeekData(
      1,
      AppStrings.weekOne,
      AppStrings.weekOneDesc,
      Icons.change_history,
    ),
    _WeekData(2, AppStrings.weekTwo, AppStrings.weekTwoDesc, Icons.ac_unit),
    _WeekData(
      3,
      AppStrings.weekThree,
      AppStrings.weekThreeDesc,
      Icons.psychology_outlined,
    ),
    _WeekData(4, AppStrings.weekFour, AppStrings.weekFourDesc, Icons.radar),
    _WeekData(5, AppStrings.weekFive, AppStrings.weekFiveDesc, Icons.gavel),
    _WeekData(6, AppStrings.weekSix, AppStrings.weekSixDesc, Icons.forum),
    _WeekData(
      7,
      AppStrings.weekSeven,
      AppStrings.weekSevenDesc,
      Icons.mood_outlined,
    ),
    _WeekData(
      8,
      AppStrings.weekEight,
      AppStrings.weekEightDesc,
      Icons.cloud_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingViewModel>();
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    final currentWeek = WeekCalculator.currentWeekIndex(registrationDate);
    final currentDay = WeekCalculator.currentDayNumber(registrationDate);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.xl,
                AppSizes.md,
                AppSizes.md,
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.explore_outlined,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: AppSizes.md),
                  Text(
                    AppStrings.roadmapTitle,
                    textAlign: TextAlign.center,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontTitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    '${AppStrings.roadmapSubtitle} | $currentDay ${AppStrings.programDay}',
                    textAlign: TextAlign.center,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Week List ──────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                itemCount: _weeks.length,
                separatorBuilder: (_, __) => SizedBox(height: AppSizes.sm),
                itemBuilder: (context, index) {
                  final week = _weeks[index];
                  final isLast = index == _weeks.length - 1;
                  final isCurrent = index == currentWeek;
                  final isPast = index < currentWeek;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ─── Timeline Indicator ──────────────────
                        SizedBox(
                          width: 44,
                          child: Column(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: isCurrent
                                      ? const LinearGradient(
                                          colors: AppColors.primaryGradient,
                                        )
                                      : isPast
                                      ? const LinearGradient(
                                          colors: [
                                            AppColors.success,
                                            AppColors.success,
                                          ],
                                        )
                                      : LinearGradient(
                                          colors: index < 4
                                              ? AppColors.coolGradient
                                              : AppColors.warmGradient,
                                        ).withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isPast
                                      ? const Icon(
                                          Icons.check,
                                          size: 18,
                                          color: Colors.white,
                                        )
                                      : Text(
                                          '${week.number}',
                                          style: PersianFonts.Vazir.copyWith(
                                            fontSize: AppSizes.fontSm,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: isPast
                                        ? AppColors.success.withValues(
                                            alpha: 0.5,
                                          )
                                        : AppColors.divider,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppSizes.sm),

                        // ─── Week Card ───────────────────────────
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(bottom: isLast ? 0 : 4),
                            padding: EdgeInsets.all(AppSizes.md),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppColors.primary.withValues(alpha: 0.05)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                              border: Border.all(
                                color: isCurrent
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.divider,
                                width: isCurrent ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${AppStrings.week} ${week.number}',
                                            style: PersianFonts.Vazir.copyWith(
                                              fontSize: AppSizes.fontMd,
                                              fontWeight: FontWeight.bold,
                                              color: isCurrent
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          if (isCurrent) ...[
                                            SizedBox(width: AppSizes.sm),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: AppSizes.xs,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                AppStrings.currentWeekLabel,
                                                style:
                                                    PersianFonts.Vazir.copyWith(
                                                      fontSize: AppSizes.fontXs,
                                                      color: Colors.white,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        week.title,
                                        style: PersianFonts.Vazir.copyWith(
                                          fontSize: AppSizes.fontSm,
                                          color: isPast
                                              ? AppColors.textHint
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        week.description,
                                        style: PersianFonts.Vazir.copyWith(
                                          fontSize: AppSizes.fontXs,
                                          color: isPast
                                              ? AppColors.textHint.withValues(
                                                  alpha: 0.7,
                                                )
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: AppSizes.sm),
                                Icon(
                                  week.icon,
                                  color: isPast
                                      ? AppColors.success
                                      : isCurrent
                                      ? AppColors.primary
                                      : index < 4
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                  size: AppSizes.iconMd,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ─── Start Button ───────────────────────────────────
            Padding(
              padding: EdgeInsets.all(AppSizes.md),
              child: SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: onboarding.isLoading
                      ? null
                      : () => _onStart(context),
                  child: Text(AppStrings.startJourney),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStart(BuildContext context) {
    final onboarding = context.read<OnboardingViewModel>();
    onboarding.completeOnboarding().then((_) {
      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }
}

/// Internal data class for week information.
class _WeekData {
  final int number;
  final String title;
  final String description;
  final IconData icon;

  const _WeekData(this.number, this.title, this.description, this.icon);
}
