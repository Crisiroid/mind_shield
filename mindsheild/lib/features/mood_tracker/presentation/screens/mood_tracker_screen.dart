import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/mood_tracker_model.dart';
import '../view_models/mood_tracker_view_model.dart';

/// Mood Tracker screen (Week 7) — guides the user through a before/after
/// mood measurement around a chosen micro-activity, then persists the record
/// and shows the delta plus recent history as proof that activity lifts mood.
class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  @override
  void initState() {
    super.initState();
    // Preload history for the trend/proof section.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodTrackerViewModel>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MoodTrackerViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.moodTrackerTitle)),
      body: SingleChildScrollView(
        padding: AppSizes.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.moodTrackerSubtitle,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
                height: 1.8,
              ),
            ),
            SizedBox(height: AppSizes.lg),

            if (vm.selectedActivity == null)
              _ActivityPicker(vm: vm)
            else ...[
              _SelectedActivityBanner(vm: vm),
              SizedBox(height: AppSizes.lg),
              _PhaseContent(vm: vm),
            ],

            SizedBox(height: AppSizes.xl),
            _HistorySection(vm: vm),
          ],
        ),
      ),
    );
  }
}

/// Inline picker shown when the screen is opened without a pre-selected
/// activity (e.g. directly from the home quick-access tools).
class _ActivityPicker extends StatelessWidget {
  final MoodTrackerViewModel vm;

  const _ActivityPicker({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.chooseActivityFirst,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.md),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: MoodTrackerViewModel.activities.map((activity) {
            return ActionChip(
              avatar: Icon(activity.icon, color: activity.color, size: 20),
              label: Text(
                activity.name,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textPrimary,
                ),
              ),
              onPressed: () => vm.selectActivity(activity),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Banner showing the currently selected activity.
class _SelectedActivityBanner extends StatelessWidget {
  final MoodTrackerViewModel vm;

  const _SelectedActivityBanner({required this.vm});

  @override
  Widget build(BuildContext context) {
    final activity = vm.selectedActivity!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: activity.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: activity.color),
      ),
      child: Row(
        children: [
          Icon(activity.icon, color: activity.color, size: 28),
          SizedBox(width: AppSizes.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.selectedActivityLabel,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                activity.name,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () => vm.reset(),
            child: Text(
              AppStrings.trackAnotherActivity,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                color: activity.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders the UI for the current phase of the before/after flow.
class _PhaseContent extends StatelessWidget {
  final MoodTrackerViewModel vm;

  const _PhaseContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    switch (vm.phase) {
      case MoodPhase.before:
        return _MoodStep(
          label: AppStrings.moodBeforeLabel,
          value: vm.moodBefore,
          onChanged: vm.setMoodBefore,
          buttonText: AppStrings.startActivityButton,
          buttonIcon: Icons.play_arrow,
          onPressed: vm.startActivity,
        );
      case MoodPhase.doing:
        return _DoingStep(vm: vm);
      case MoodPhase.after:
        return _MoodStep(
          label: AppStrings.moodAfterLabel,
          value: vm.moodAfter,
          onChanged: vm.setMoodAfter,
          buttonText: AppStrings.submitMood,
          buttonIcon: Icons.check,
          isBusy: vm.isSaving,
          onPressed: vm.submit,
        );
      case MoodPhase.done:
        return _ResultStep(vm: vm);
    }
  }
}

/// A mood measurement step with a 1-10 slider and a primary action button.
class _MoodStep extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final String buttonText;
  final IconData buttonIcon;
  final bool isBusy;
  final VoidCallback onPressed;

  const _MoodStep({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.buttonText,
    required this.buttonIcon,
    required this.onPressed,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.lg),
        Center(
          child: Text(
            '$value',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontHeadline,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '$value',
          activeColor: AppColors.primary,
          onChanged: (v) => onChanged(v.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '۱',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textHint,
              ),
            ),
            Text(
              '۱۰',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isBusy ? null : onPressed,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            icon: isBusy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(buttonIcon, color: Colors.white),
            label: Text(
              buttonText,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The "performing the activity" step, prompting the user to finish.
class _DoingStep extends StatelessWidget {
  final MoodTrackerViewModel vm;

  const _DoingStep({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: AppSizes.md),
        Icon(vm.selectedActivity!.icon, size: 72, color: AppColors.primary),
        SizedBox(height: AppSizes.md),
        Text(
          vm.selectedActivity!.description,
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
            onPressed: vm.finishActivity,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            icon: const Icon(Icons.done_all, color: Colors.white),
            label: Text(
              AppStrings.moodAfterLabel,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The result step showing the mood delta and an encouraging message.
class _ResultStep extends StatelessWidget {
  final MoodTrackerViewModel vm;

  const _ResultStep({required this.vm});

  @override
  Widget build(BuildContext context) {
    final delta = vm.moodDelta;
    final accent = delta > 0
        ? AppColors.success
        : delta == 0
        ? AppColors.warning
        : AppColors.info;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: accent),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MoodStat(label: AppStrings.moodBefore, value: '${vm.moodBefore}'),
              Icon(Icons.arrow_back, color: accent),
              _MoodStat(label: AppStrings.moodAfter, value: '${vm.moodAfter}'),
              _MoodStat(
                label: AppStrings.moodDelta,
                value: delta > 0 ? '+$delta' : '$delta',
                color: accent,
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          Text(
            vm.resultMessage,
            textAlign: TextAlign.center,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textPrimary,
              height: 1.8,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => vm.reset(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              icon: const Icon(Icons.replay, color: Colors.white),
              label: Text(
                AppStrings.trackAnotherActivity,
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

/// A small labelled statistic used in the result summary.
class _MoodStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MoodStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.xs),
        Text(
          label,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontXs,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// The recent history / trend section shown below the flow.
class _HistorySection extends StatelessWidget {
  final MoodTrackerViewModel vm;

  const _HistorySection({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.moodHistoryTitle,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.md),
        if (vm.isLoadingHistory)
          const Center(child: CircularProgressIndicator())
        else if (vm.history.isEmpty)
          Text(
            AppStrings.noMoodHistory,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: AppColors.textHint,
            ),
          )
        else
          ...vm.history.map((record) => _HistoryRow(record: record)),
      ],
    );
  }
}

/// A single history row rendering an activity's before/after delta.
class _HistoryRow extends StatelessWidget {
  final MoodTrackerModel record;

  const _HistoryRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final delta = record.delta;
    final accent = delta > 0
        ? AppColors.success
        : delta == 0
        ? AppColors.warning
        : AppColors.info;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.sm),
      child: Container(
        padding: EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                record.activityName ?? AppStrings.moodTrackerTitle,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '${record.moodBefore} ← ${record.moodAfter}',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(width: AppSizes.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(
                delta > 0 ? '+$delta' : '$delta',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
