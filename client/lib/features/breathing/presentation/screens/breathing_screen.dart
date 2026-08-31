import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../view_models/breathing_view_model.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BreathingViewModel>();

    if (vm.isActive) {
      final durations = vm.patternDurations;
      final phaseDuration = durations[vm.currentPhase.name] ?? 4;

      _animationController.duration = Duration(seconds: phaseDuration);

      if (vm.currentPhase == BreathingPhase.inhale) {
        _animationController.forward(from: 0.0);
      } else if (vm.currentPhase == BreathingPhase.exhale) {
        _animationController.reverse(from: 1.0);
      }
    } else {
      _animationController.reset();
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.breathingTitle)),
      body: SingleChildScrollView(
        padding: AppSizes.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppStrings.breathingSubtitle,
              textAlign: TextAlign.center,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSizes.xl),

            if (!vm.isActive) ...[
              _buildPatternSelector(vm),
              SizedBox(height: AppSizes.xl),
            ],

            _buildBreathingCircle(vm),

            SizedBox(height: AppSizes.lg),

            if (vm.isActive)
              Text(
                vm.currentPhaseLabel,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXxl,
                  fontWeight: FontWeight.bold,
                  color: _getPhaseColor(vm.currentPhase),
                ),
              ),

            SizedBox(height: AppSizes.md),

            if (vm.isActive) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatChip(
                    icon: Icons.timer,
                    label: AppStrings.sessionDuration,
                    value: vm.formattedElapsed,
                  ),
                  SizedBox(width: AppSizes.md),
                  _buildStatChip(
                    icon: Icons.air,
                    label: AppStrings.breathingCount,
                    value: '${vm.breathCount}',
                  ),
                ],
              ),
            ],

            SizedBox(height: AppSizes.xl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isSaving
                    ? null
                    : () {
                        if (vm.isActive) {
                          vm.stopSession();
                        } else {
                          vm.startSession();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: vm.isActive
                      ? AppColors.error
                      : AppColors.primary,
                  disabledBackgroundColor: AppColors.textHint,
                ),
                child: vm.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        vm.isActive
                            ? AppStrings.stopBreathing
                            : AppStrings.startBreathing,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternSelector(BreathingViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.breathingPattern,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _PatternCard(
                title: AppStrings.boxBreathing,
                description: AppStrings.boxBreathingDesc,
                isSelected: vm.selectedPattern == 'box',
                onTap: () => vm.selectPattern('box'),
              ),
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: _PatternCard(
                title: AppStrings.deepBreathing,
                description: AppStrings.deepBreathingDesc,
                isSelected: vm.selectedPattern == 'deep',
                onTap: () => vm.selectPattern('deep'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreathingCircle(BreathingViewModel vm) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scale = 0.5 + (_animationController.value * 0.5);
        final phaseColor = _getPhaseColor(vm.currentPhase);

        return Container(
          width: 250,
          height: 250,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 250 * scale,
                height: 250 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: phaseColor.withValues(alpha: 0.1),
                ),
              ),
              Container(
                width: 200 * scale,
                height: 200 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: phaseColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: phaseColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 150 * scale,
                height: 150 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      phaseColor.withValues(alpha: 0.3),
                      phaseColor.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(color: phaseColor, width: 3),
                ),
                child: Center(
                  child: vm.isActive
                      ? Icon(Icons.air, color: phaseColor, size: 40 * scale)
                      : const Icon(
                          Icons.air,
                          color: AppColors.primary,
                          size: 40,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          SizedBox(width: AppSizes.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textHint,
                ),
              ),
              Text(
                value,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPhaseColor(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return AppColors.primary;
      case BreathingPhase.hold:
        return AppColors.info;
      case BreathingPhase.exhale:
        return AppColors.success;
      case BreathingPhase.holdAfter:
        return AppColors.warning;
    }
  }
}

class _PatternCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _PatternCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.air,
                    size: 20,
                    color: isSelected ? AppColors.primary : AppColors.textHint,
                  ),
                  SizedBox(width: AppSizes.xs),
                  Expanded(
                    child: Text(
                      title,
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                description,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
