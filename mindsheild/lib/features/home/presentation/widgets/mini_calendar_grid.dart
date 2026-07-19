import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../../core/services/token_service.dart';

class MiniCalendarGrid extends StatelessWidget {
  const MiniCalendarGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    final currentDayIndex = WeekCalculator.currentDayIndex(registrationDate);
    final currentWeekIndex = WeekCalculator.currentWeekIndex(registrationDate);

    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.calendar56Days,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${AppStrings.week} ${currentWeekIndex + 1} | ${AppStrings.programDay} ${currentDayIndex + 1}',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),

          Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  AppStrings.week,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textHint,
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
                            color: AppColors.textHint,
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

          ...List.generate(8, (weekIndex) {
            return Padding(
              padding: EdgeInsets.only(bottom: weekIndex < 7 ? 4 : 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${weekIndex + 1}',
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.textHint,
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
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppColors.primary
                                    : isPast
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(6),
                                border: isCurrent
                                    ? Border.all(
                                        color: AppColors.primary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: isPast
                                    ? Icon(
                                        Icons.check,
                                        size: 14,
                                        color: AppColors.success,
                                      )
                                    : Text(
                                        '${dayNumber + 1}',
                                        style: PersianFonts.Vazir.copyWith(
                                          fontSize: AppSizes.fontXs,
                                          fontWeight: isCurrent
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isCurrent
                                              ? Colors.white
                                              : AppColors.textPrimary,
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
}
