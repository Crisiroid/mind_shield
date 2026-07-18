import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../view_models/body_tension_view_model.dart';

/// Body Tension Map screen — anatomical body figure for tension tracking.
///
/// User taps body regions to mark tension areas, selects intensity
/// on a slider (1-10), and saves the entry. Color-coded feedback
/// from yellow (low) to dark red (high intensity).
class BodyTensionMapScreen extends StatefulWidget {
  const BodyTensionMapScreen({super.key});

  @override
  State<BodyTensionMapScreen> createState() => _BodyTensionMapScreenState();
}

class _BodyTensionMapScreenState extends State<BodyTensionMapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BodyTensionViewModel>().init();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BodyTensionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.bodyTensionMapTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.bodyTensionMapTitle),
            Tab(text: AppStrings.history),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMapTab(vm), _buildHistoryTab(vm)],
      ),
    );
  }

  Widget _buildMapTab(BodyTensionViewModel vm) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Subtitle
          Text(
            AppStrings.bodyTensionMapSubtitle,
            textAlign: TextAlign.center,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),

          // Body figure
          _BodyFigureWidget(
            selectedRegions: vm.selectedRegions,
            onRegionTapped: (region) => vm.toggleRegion(region),
          ),

          SizedBox(height: AppSizes.lg),

          // Intensity slider
          _buildIntensitySlider(vm),

          SizedBox(height: AppSizes.md),

          // Notes field
          _buildNotesField(vm),

          SizedBox(height: AppSizes.lg),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.isSaving ? null : () => vm.saveBodyTension(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
                  : Text(AppStrings.saveTensionMap),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensitySlider(BodyTensionViewModel vm) {
    // Get color based on intensity
    Color intensityColor;
    if (vm.intensity <= 3) {
      intensityColor = Colors.yellow.shade700;
    } else if (vm.intensity <= 6) {
      intensityColor = Colors.orange;
    } else {
      intensityColor = Colors.red.shade800;
    }

    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.intensityLevel,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
                  '${vm.intensity}',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.bold,
                    color: intensityColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Text(
                AppStrings.lowIntensity,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: Colors.yellow.shade700,
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
                    value: vm.intensity.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (value) => vm.setIntensity(value.toInt()),
                  ),
                ),
              ),
              Text(
                AppStrings.highIntensity,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: Colors.red.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField(BodyTensionViewModel vm) {
    return TextField(
      maxLines: 3,
      decoration: InputDecoration(
        hintText: AppStrings.addNote,
        hintStyle: PersianFonts.Vazir.copyWith(
          fontSize: AppSizes.fontMd,
          color: AppColors.textHint,
        ),
        prefixIcon: const Icon(Icons.note_add, color: AppColors.textSecondary),
      ),
      onChanged: vm.setNotes,
    );
  }

  Widget _buildHistoryTab(BodyTensionViewModel vm) {
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
              AppStrings.noTensionHistory,
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
        return _TensionHistoryCard(entry: entry);
      },
    );
  }
}

/// Interactive body figure widget with tappable regions.
class _BodyFigureWidget extends StatelessWidget {
  final Set<String> selectedRegions;
  final void Function(String region) onRegionTapped;

  const _BodyFigureWidget({
    required this.selectedRegions,
    required this.onRegionTapped,
  });

  // Body region definitions with positions
  static const List<_BodyRegion> _regions = [
    _BodyRegion(id: 'head', label: 'سر', yFraction: 0.06, xFraction: 0.5),
    _BodyRegion(id: 'neck', label: 'گردن', yFraction: 0.16, xFraction: 0.5),
    _BodyRegion(
      id: 'shoulders',
      label: 'شانه‌ها',
      yFraction: 0.24,
      xFraction: 0.5,
    ),
    _BodyRegion(
      id: 'chest',
      label: 'قفسه سینه',
      yFraction: 0.34,
      xFraction: 0.5,
    ),
    _BodyRegion(id: 'back', label: 'پشت', yFraction: 0.34, xFraction: 0.78),
    _BodyRegion(id: 'arms', label: 'دست‌ها', yFraction: 0.42, xFraction: 0.22),
    _BodyRegion(id: 'abdomen', label: 'شکم', yFraction: 0.46, xFraction: 0.5),
    _BodyRegion(id: 'legs', label: 'پاها', yFraction: 0.7, xFraction: 0.5),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 380,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Stack(
        children: [
          // Body outline
          Center(
            child: CustomPaint(
              size: const Size(160, 340),
              painter: _BodyOutlinePainter(),
            ),
          ),

          // Tappable region buttons
          ..._regions.map((region) {
            final isSelected = selectedRegions.contains(region.id);
            return Positioned(
              top: region.yFraction * 340 + 20,
              left:
                  region.xFraction * 160 +
                  (MediaQuery.of(context).size.width - 160) / 2 -
                  30,
              child: GestureDetector(
                onTap: () => onRegionTapped(region.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getRegionColor(region.id).withValues(alpha: 0.3)
                        : AppColors.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(
                      color: isSelected
                          ? _getRegionColor(region.id)
                          : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      region.label,
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontXs,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? _getRegionColor(region.id)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static Color _getRegionColor(String regionId) {
    switch (regionId) {
      case 'head':
        return Colors.purple;
      case 'neck':
        return Colors.blue;
      case 'shoulders':
        return Colors.teal;
      case 'chest':
        return Colors.orange;
      case 'back':
        return Colors.brown;
      case 'arms':
        return Colors.green;
      case 'abdomen':
        return Colors.red;
      case 'legs':
        return Colors.indigo;
      default:
        return AppColors.primary;
    }
  }
}

/// Body region definition.
class _BodyRegion {
  final String id;
  final String label;
  final double yFraction;
  final double xFraction;

  const _BodyRegion({
    required this.id,
    required this.label,
    required this.yFraction,
    required this.xFraction,
  });
}

/// Painter for the body outline figure.
class _BodyOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textHint.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;

    // Head (circle)
    canvas.drawCircle(Offset(cx, 25), 22, fillPaint);
    canvas.drawCircle(Offset(cx, 25), 22, paint);

    // Neck
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, 58), width: 14, height: 18),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, 58), width: 14, height: 18),
      paint,
    );

    // Torso
    final torsoPath = Path()
      ..moveTo(cx - 40, 72)
      ..lineTo(cx + 40, 72)
      ..lineTo(cx + 35, 170)
      ..lineTo(cx - 35, 170)
      ..close();
    canvas.drawPath(torsoPath, fillPaint);
    canvas.drawPath(torsoPath, paint);

    // Arms
    final leftArm = Path()
      ..moveTo(cx - 40, 75)
      ..lineTo(cx - 60, 80)
      ..lineTo(cx - 65, 160)
      ..lineTo(cx - 55, 162)
      ..lineTo(cx - 50, 95)
      ..lineTo(cx - 40, 90);
    canvas.drawPath(leftArm, paint);

    final rightArm = Path()
      ..moveTo(cx + 40, 75)
      ..lineTo(cx + 60, 80)
      ..lineTo(cx + 65, 160)
      ..lineTo(cx + 55, 162)
      ..lineTo(cx + 50, 95)
      ..lineTo(cx + 40, 90);
    canvas.drawPath(rightArm, paint);

    // Legs
    final leftLeg = Path()
      ..moveTo(cx - 30, 170)
      ..lineTo(cx - 35, 310)
      ..lineTo(cx - 15, 310)
      ..lineTo(cx - 5, 170);
    canvas.drawPath(leftLeg, fillPaint);
    canvas.drawPath(leftLeg, paint);

    final rightLeg = Path()
      ..moveTo(cx + 5, 170)
      ..lineTo(cx + 15, 310)
      ..lineTo(cx + 35, 310)
      ..lineTo(cx + 30, 170);
    canvas.drawPath(rightLeg, fillPaint);
    canvas.drawPath(rightLeg, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// History card for a single body tension entry.
class _TensionHistoryCard extends StatelessWidget {
  final dynamic entry;

  const _TensionHistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final regions = (entry.bodyRegions as String).split(',');
    final intensity = entry.overallIntensity as int?;
    final date = entry.mappingDate as DateTime;
    final notes = entry.notes as String?;

    // Determine color based on intensity
    Color intensityColor;
    if (intensity == null || intensity <= 3) {
      intensityColor = Colors.yellow.shade700;
    } else if (intensity <= 6) {
      intensityColor = Colors.orange;
    } else {
      intensityColor = Colors.red.shade800;
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
                Text(
                  PersianDateFormatter.date(date),
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textHint,
                  ),
                ),
                if (intensity != null)
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
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.bold,
                        color: intensityColor,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.xs,
              runSpacing: AppSizes.xs,
              children: regions.map((r) {
                return Chip(
                  label: Text(
                    _getRegionLabel(r),
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontXs,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  backgroundColor: AppColors.surfaceVariant,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            if (notes != null && notes.isNotEmpty) ...[
              SizedBox(height: AppSizes.sm),
              Text(
                notes,
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

  String _getRegionLabel(String regionId) {
    switch (regionId) {
      case 'head':
        return AppStrings.bodyRegionHead;
      case 'neck':
        return AppStrings.bodyRegionNeck;
      case 'shoulders':
        return AppStrings.bodyRegionShoulders;
      case 'chest':
        return AppStrings.bodyRegionChest;
      case 'back':
        return AppStrings.bodyRegionBack;
      case 'arms':
        return AppStrings.bodyRegionArms;
      case 'abdomen':
        return AppStrings.bodyRegionAbdomen;
      case 'legs':
        return AppStrings.bodyRegionLegs;
      default:
        return regionId;
    }
  }
}
