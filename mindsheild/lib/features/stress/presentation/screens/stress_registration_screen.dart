import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../view_models/stress_view_model.dart';

class StressRegistrationScreen extends StatefulWidget {
  const StressRegistrationScreen({super.key});

  @override
  State<StressRegistrationScreen> createState() =>
      _StressRegistrationScreenState();
}

class _StressRegistrationScreenState extends State<StressRegistrationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<_StressSituation> _situations = [
    _StressSituation(
      type: 'deadline_pressure',
      label: AppStrings.stressSituationDeadline,
      icon: Icons.timer,
      color: Colors.red,
    ),
    _StressSituation(
      type: 'colleague_conflict',
      label: AppStrings.stressSituationConflict,
      icon: Icons.people,
      color: Colors.orange,
    ),
    _StressSituation(
      type: 'heavy_workload',
      label: AppStrings.stressSituationWorkload,
      icon: Icons.work,
      color: Colors.amber,
    ),
    _StressSituation(
      type: 'stressful_meeting',
      label: AppStrings.stressSituationMeeting,
      icon: Icons.meeting_room,
      color: Colors.purple,
    ),
    _StressSituation(
      type: 'supervisor_pressure',
      label: AppStrings.stressSituationSupervisor,
      icon: Icons.person_outline,
      color: Colors.blue,
    ),
    _StressSituation(
      type: 'job_uncertainty',
      label: AppStrings.stressSituationUncertainty,
      icon: Icons.help_outline,
      color: Colors.teal,
    ),
    _StressSituation(
      type: 'overtime',
      label: AppStrings.stressSituationOvertime,
      icon: Icons.schedule,
      color: Colors.indigo,
    ),
    _StressSituation(
      type: 'excess_responsibility',
      label: AppStrings.stressSituationResponsibility,
      icon: Icons.assignment,
      color: Colors.brown,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StressViewModel>().init();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StressViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.stressRegistrationTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.stressRegistrationTitle),
            Tab(text: AppStrings.history),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRegistrationTab(vm), _buildHistoryTab(vm)],
      ),
    );
  }

  Widget _buildRegistrationTab(StressViewModel vm) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.stressRegistrationSubtitle,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            'موقعیت استرس‌زا:',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppSizes.sm,
            crossAxisSpacing: AppSizes.sm,
            childAspectRatio: 1.6,
            children: _situations.map((situation) {
              final isSelected = vm.selectedSituation == situation.type;
              return _SituationButton(
                situation: situation,
                isSelected: isSelected,
                onTap: () => vm.selectSituation(situation.type),
              );
            }).toList(),
          ),

          SizedBox(height: AppSizes.lg),

          Text(
            'توضیحات:',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: AppStrings.stressDescriptionHint,
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textHint,
              ),
              prefixIcon: const Icon(
                Icons.notes,
                color: AppColors.textSecondary,
              ),
            ),
            onChanged: vm.setDescription,
          ),

          SizedBox(height: AppSizes.lg),

          Text(
            AppStrings.stressIntensityLabel,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          _buildIntensitySlider(vm),

          SizedBox(height: AppSizes.xl),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.isSaving ? null : () => vm.submitStress(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
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
                  : Text(AppStrings.submitStress),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensitySlider(StressViewModel vm) {
    Color intensityColor;
    if (vm.intensityLevel <= 3) {
      intensityColor = Colors.green;
    } else if (vm.intensityLevel <= 6) {
      intensityColor = Colors.orange;
    } else {
      intensityColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Text(
            '۱',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: Colors.green,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: intensityColor,
                inactiveTrackColor: intensityColor.withValues(alpha: 0.2),
                thumbColor: intensityColor,
                overlayColor: intensityColor.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: vm.intensityLevel.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (value) => vm.setIntensityLevel(value.toInt()),
              ),
            ),
          ),
          Text(
            '۱۰',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: Colors.red,
            ),
          ),
          SizedBox(width: AppSizes.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: intensityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(
              '${vm.intensityLevel}',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.bold,
                color: intensityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(StressViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (vm.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.textHint),
            SizedBox(height: AppSizes.md),
            Text(
              AppStrings.noHistory,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSizes.paddingScreen,
      itemCount: vm.history.length,
      itemBuilder: (context, index) {
        final entry = vm.history[index];
        return _StressHistoryCard(entry: entry);
      },
    );
  }
}

class _StressSituation {
  final String type;
  final String label;
  final IconData icon;
  final Color color;

  const _StressSituation({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _SituationButton extends StatelessWidget {
  final _StressSituation situation;
  final bool isSelected;
  final VoidCallback onTap;

  const _SituationButton({
    required this.situation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? situation.color.withValues(alpha: 0.15)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isSelected ? situation.color : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                situation.icon,
                color: isSelected ? situation.color : AppColors.textSecondary,
                size: 24,
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                situation.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? situation.color : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StressHistoryCard extends StatelessWidget {
  final dynamic entry;

  const _StressHistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final intensity = entry.intensityLevel as int;
    final date = entry.eventTimestamp as DateTime;
    final situation = entry.situationType as String;
    final description = entry.situationDescription as String?;

    String situationLabel = situation;
    for (final s in _StressRegistrationScreenState._situations) {
      if (s.type == situation) {
        situationLabel = s.label;
        break;
      }
    }

    Color intensityColor;
    if (intensity <= 3) {
      intensityColor = Colors.green;
    } else if (intensity <= 6) {
      intensityColor = Colors.orange;
    } else {
      intensityColor = Colors.red;
    }

    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.md),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    situationLabel,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: intensityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    'شدت: $intensity',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontXs,
                      fontWeight: FontWeight.bold,
                      color: intensityColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              PersianDateFormatter.dateTime(date),
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                color: AppColors.textHint,
              ),
            ),
            if (description != null && description.isNotEmpty) ...[
              SizedBox(height: AppSizes.sm),
              Text(
                description,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
