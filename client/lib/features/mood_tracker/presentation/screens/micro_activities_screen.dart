import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../view_models/mood_tracker_view_model.dart';

class MicroActivitiesScreen extends StatelessWidget {
  const MicroActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<MoodTrackerViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.microActivitiesTitle)),
      body: SingleChildScrollView(
        padding: AppSizes.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.microActivitiesSubtitle,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
                height: 1.8,
              ),
            ),
            SizedBox(height: AppSizes.lg),
            ...MoodTrackerViewModel.activities.map(
              (activity) => _ActivityCard(
                activity: activity,
                onTap: () {
                  vm.selectActivity(activity);
                  Navigator.of(context).pushNamed('/mood-tracker');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final MicroActivity activity;
  final VoidCallback onTap;

  const _ActivityCard({required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.md),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Container(
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: activity.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(activity.icon, color: activity.color, size: 28),
                ),
                SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name,
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontLg,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSizes.xs),
                      Text(
                        activity.description,
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontSm,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left, color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
