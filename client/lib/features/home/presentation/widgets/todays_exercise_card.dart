import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/weekly_media_model.dart';

class TodaysExerciseCard extends StatelessWidget {
  final List<WeeklyMediaModel> mediaList;
  final int currentWeek;
  final int currentDay;
  final VoidCallback? onStartExercise;

  const TodaysExerciseCard({
    super.key,
    required this.mediaList,
    required this.currentWeek,
    required this.currentDay,
    this.onStartExercise,
  });

  @override
  Widget build(BuildContext context) {
    final hasMedia = mediaList.isNotEmpty;
    final media = hasMedia ? mediaList.first : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasMedia ? AppColors.warmGradient : AppColors.coolGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: (hasMedia ? AppColors.secondary : AppColors.primary)
                .withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  '${AppStrings.week} $currentWeek | ${AppStrings.programDay} $currentDay',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),

          Text(
            AppStrings.todaysExercise,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSizes.sm),

          if (hasMedia && media != null) ...[
            Text(
              media.description ?? _getWeekExerciseTitle(currentWeek),
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizes.md),

            Row(
              children: [
                Icon(
                  _getMediaIcon(media.fileType),
                  color: Colors.white,
                  size: AppSizes.iconMd,
                ),
                SizedBox(width: AppSizes.xs),
                Text(
                  _getMediaTypeLabel(media.fileType),
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              _getWeekExerciseTitle(currentWeek),
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizes.md),
            Text(
              AppStrings.noContent,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],

          SizedBox(height: AppSizes.md),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: hasMedia
                    ? AppColors.secondary
                    : AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: Text(
                AppStrings.startExercise,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekExerciseTitle(int week) {
    switch (week) {
      case 1:
        return 'شناخت استرس و ترسیم نقشه واکنش';
      case 2:
        return 'توجه به بدن و تنفس';
      case 3:
        return 'شناخت افکار خودکار و الگوهای فکری';
      case 4:
        return 'بررسی شواهد و ساختن فکر متعادل';
      case 5:
        return 'فعالیت، انرژی و خلق';
      case 6:
        return 'مشاهده افکار و پذیرش هیجان';
      case 7:
        return 'حل مسئله گام‌به‌گام';
      case 8:
        return 'تثبیت مهارت‌ها و برنامه ادامه مسیر';
      default:
        return 'تمرین امروز';
    }
  }

  IconData _getMediaIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'audio':
        return Icons.audiotrack;
      case 'video':
        return Icons.videocam;
      case 'image':
        return Icons.image;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getMediaTypeLabel(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'audio':
        return 'فایل صوتی';
      case 'video':
        return 'ویدئو';
      case 'image':
        return 'تصویر';
      case 'document':
        return 'سند';
      default:
        return 'فایل';
    }
  }
}
