import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../../core/services/token_service.dart';

class WeeklyReportSheet extends StatelessWidget {
  final int currentWeek;
  final int currentDay;
  final double progress;

  const WeeklyReportSheet({
    super.key,
    required this.currentWeek,
    required this.currentDay,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    final weeklyProgress = WeekCalculator.weeklyProgressFraction(
      registrationDate,
    );
    final daysCompleted = currentDay - 1;
    final daysRemaining = 56 - currentDay;
    final weekProgressPercent = (weeklyProgress * 100).toInt();
    final overallPercent = (progress * 100).toInt();

    return Container(
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),

          Row(
            children: [
              const Icon(Icons.assessment_outlined, color: AppColors.primary),
              SizedBox(width: AppSizes.sm),
              Text(
                AppStrings.weeklyReport,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.xl),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'روزهای گذشته',
                  value: '$daysCompleted',
                  subtitle: 'از ۵۶ روز',
                  color: AppColors.success,
                  icon: Icons.check_circle_outline,
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: _StatCard(
                  label: 'روزهای باقی‌مانده',
                  value: '$daysRemaining',
                  subtitle: 'روز',
                  color: AppColors.info,
                  icon: Icons.hourglass_bottom,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),

          _buildProgressSection(
            title: 'پیشرفت کلی برنامه',
            value: overallPercent,
            color: AppColors.primary,
          ),
          SizedBox(height: AppSizes.md),

          _buildProgressSection(
            title: 'پیشرفت هفته $currentWeek',
            value: weekProgressPercent,
            color: AppColors.secondary,
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            'جزئیات هفتگی',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          _buildWeekBreakdown(currentWeek),
          SizedBox(height: AppSizes.lg),

          _buildMotivationalMessage(overallPercent),
          SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }

  Widget _buildProgressSection({
    required String title,
    required int value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$value٪',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekBreakdown(int currentWeek) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: List.generate(8, (index) {
          final weekNum = index + 1;
          final isCurrentWeek = weekNum == currentWeek;
          final isPast = weekNum < currentWeek;
          final isFuture = weekNum > currentWeek;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isPast
                        ? AppColors.success.withValues(alpha: 0.15)
                        : isCurrentWeek
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isPast
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.success,
                          )
                        : Text(
                            '$weekNum',
                            style: PersianFonts.Vazir.copyWith(
                              fontSize: AppSizes.fontXs,
                              fontWeight: isCurrentWeek
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrentWeek
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    _getWeekName(weekNum),
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      fontWeight: isCurrentWeek
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isFuture
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isCurrentWeek)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      'فعال',
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isPast)
                  Text(
                    'تکمیل شده',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontXs,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMotivationalMessage(int percent) {
    String message;
    IconData icon;
    Color color;

    if (percent >= 80) {
      message = 'تقریباً به پایان مسیر رسیدی! همینطور ادامه بده.';
      icon = Icons.emoji_events_outlined;
      color = AppColors.warning;
    } else if (percent >= 50) {
      message = 'نیمی از مسیر را طی کردی. هر روز یک قدم جلوتر هستی.';
      icon = Icons.trending_up;
      color = AppColors.success;
    } else if (percent >= 20) {
      message = 'شروع خوبی داشتی. ادامه بده، هر روز مهم است.';
      icon = Icons.self_improvement_outlined;
      color = AppColors.primary;
    } else {
      message = 'تازه شروع کردی. مهم‌ترین قدم، همان قدم اول است.';
      icon = Icons.flag_outlined;
      color = AppColors.info;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppSizes.iconLg),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              message,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekName(int week) {
    switch (week) {
      case 1:
        return 'آشنایی و مثلث هیجان';
      case 2:
        return 'تنفس و آگاهی بدنی';
      case 3:
        return 'خطاهای شناختی';
      case 4:
        return 'رادار افکار منفی';
      case 5:
        return 'دادگاه ذهن';
      case 6:
        return 'تمرین تعارض';
      case 7:
        return 'خلق و فعالیت';
      case 8:
        return 'تعادل نقش و آسمان افکار';
      default:
        return '';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppSizes.iconMd),
          SizedBox(height: AppSizes.sm),
          Text(
            value,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXxl,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            label,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
