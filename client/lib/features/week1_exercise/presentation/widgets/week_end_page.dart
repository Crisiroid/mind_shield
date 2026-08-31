import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class WeekEndPage extends StatelessWidget {
  final VoidCallback onFinish;
  final VoidCallback? onReviewSummary;
  final String finishText;
  final String reviewText;

  const WeekEndPage({
    super.key,
    required this.onFinish,
    this.onReviewSummary,
    this.finishText = 'پایان هفته اول',
    this.reviewText = 'مرور دوباره خلاصه',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Center(
            child: Text(
              'هفته اول به پایان رسید',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'شما در این هفته با ساختار استرس آشنا شدید و یاد گرفتید یک تجربه را به موقعیت، فکر، هیجان، بدن و رفتار تقسیم کنید.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'در هفته دوم، توجه به بدن و تنفس را به\u200cصورت دقیق\u200cتر تمرین خواهید کرد.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Reminder box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 22,
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'لازم نیست همه تمرین\u200cها کامل یا بی\u200cنقص انجام شده باشند. هدف، تمرین تدریجی مهارت\u200cهاست.',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      height: 1.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: onFinish, child: Text(finishText)),
          ),
          if (onReviewSummary != null) ...[
            SizedBox(height: AppSizes.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onReviewSummary,
                child: Text(
                  reviewText,
                  style: PersianFonts.Vazir.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}
