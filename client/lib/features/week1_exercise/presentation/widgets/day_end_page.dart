import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class DayEndPage extends StatelessWidget {
  final String title;
  final String missionText;
  final String? feedbackText;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String? notificationText;

  const DayEndPage({
    super.key,
    required this.title,
    required this.missionText,
    this.feedbackText,
    required this.buttonText,
    required this.onButtonPressed,
    this.notificationText,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مأموریت امروز',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  missionText,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    height: 1.8,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (feedbackText != null) ...[
            SizedBox(height: AppSizes.lg),
            Text(
              feedbackText!,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (notificationText != null) ...[
            SizedBox(height: AppSizes.lg),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: AppColors.info,
                    size: 20,
                  ),
                  SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      notificationText!,
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              child: Text(buttonText),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}
