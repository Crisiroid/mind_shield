import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../view_models/conflict_exercise_view_model.dart';

class ConflictExerciseScreen extends StatelessWidget {
  const ConflictExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConflictExerciseViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.conflictExerciseTitle)),
      body: vm.finished ? _FinishedView(vm: vm) : _ScenarioView(vm: vm),
    );
  }
}

class _ScenarioView extends StatelessWidget {
  final ConflictExerciseViewModel vm;

  const _ScenarioView({required this.vm});

  @override
  Widget build(BuildContext context) {
    final scenario = vm.currentScenario;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.conflictExerciseSubtitle,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(
                '${AppStrings.conflictSituation} ${vm.currentScenarioIndex + 1} از ${ConflictExerciseViewModel.scenarios.length}',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSizes.md),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.forum_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        scenario.title,
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontLg,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.md),
                Text(
                  scenario.situation,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            AppStrings.chooseResponse,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),

          ...scenario.options.map((option) {
            final isSelected = vm.selectedOption == option;
            return _ResponseOption(
              text: option.text,
              isSelected: isSelected,
              isDisabled: vm.hasAnswered,
              quality: isSelected ? option.qualityScore : null,
              onTap: () => vm.selectOption(option),
            );
          }),

          if (vm.hasAnswered) ...[
            SizedBox(height: AppSizes.lg),
            _FeedbackCard(vm: vm),
            SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => vm.nextScenario(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  vm.isLastScenario
                      ? AppStrings.conflictFinished
                      : AppStrings.nextConflict,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResponseOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isDisabled;
  final int? quality;
  final VoidCallback onTap;

  const _ResponseOption({
    required this.text,
    required this.isSelected,
    required this.isDisabled,
    required this.quality,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    IconData icon;

    if (isSelected) {
      final q = quality ?? 0;
      final accent = q >= 100
          ? AppColors.success
          : q >= 50
          ? AppColors.warning
          : AppColors.error;
      borderColor = accent;
      bgColor = accent.withValues(alpha: 0.08);
      icon = q >= 100
          ? Icons.check_circle
          : q >= 50
          ? Icons.info_outline
          : Icons.cancel;
    } else {
      borderColor = AppColors.divider;
      bgColor = AppColors.surface;
      icon = Icons.chat_bubble_outline;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.sm),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? borderColor : AppColors.textHint,
                  size: 22,
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    text,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final ConflictExerciseViewModel vm;

  const _FeedbackCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final score = vm.performanceScore;
    final accent = score >= 100
        ? AppColors.success
        : score >= 50
        ? AppColors.warning
        : AppColors.error;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.feedback_outlined, color: accent, size: 24),
              SizedBox(width: AppSizes.sm),
              Text(
                '${AppStrings.practiceScore}: ${vm.performanceScore}',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            vm.feedback,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textSecondary,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinishedView extends StatelessWidget {
  final ConflictExerciseViewModel vm;

  const _FinishedView({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: AppSizes.xxl),
          const Icon(Icons.emoji_events, size: 80, color: AppColors.warning),
          SizedBox(height: AppSizes.lg),
          Text(
            AppStrings.conflictFinished,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            AppStrings.conflictExerciseSubtitle,
            textAlign: TextAlign.center,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textSecondary,
              height: 1.8,
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => vm.resetPractice(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              icon: const Icon(Icons.replay, color: Colors.white),
              label: Text(
                AppStrings.practiceAgain,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
