import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../view_models/emotion_triangle_view_model.dart';

/// Emotion Triangle screen — interactive triangle with 3 tappable sides.
///
/// Each side represents a dimension of emotional experience:
/// thought, body, behavior. Tapping a side records the interaction
/// and navigates to the appropriate next screen.
class EmotionTriangleScreen extends StatefulWidget {
  const EmotionTriangleScreen({super.key});

  @override
  State<EmotionTriangleScreen> createState() => _EmotionTriangleScreenState();
}

class _EmotionTriangleScreenState extends State<EmotionTriangleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmotionTriangleViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmotionTriangleViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.emotionTriangleTitle)),
      body: SingleChildScrollView(
        padding: AppSizes.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Subtitle
            Text(
              AppStrings.emotionTriangleSubtitle,
              textAlign: TextAlign.center,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSizes.xl),

            // Interactive Triangle
            _InteractiveTriangle(
              isSaving: vm.isSaving,
              onSideTapped: (side) async {
                // Haptic feedback for body side
                if (side == 'body') {
                  await HapticFeedback.heavyImpact();
                } else {
                  await HapticFeedback.lightImpact();
                }

                final clickedSide = await vm.recordInteraction(side);
                if (clickedSide == null) return;

                if (!context.mounted) return;

                // Navigate based on side
                if (clickedSide == 'body') {
                  Navigator.of(context).pushNamed('/body-tension-map');
                } else if (clickedSide == 'thought') {
                  _showSideDescription(
                    context,
                    AppStrings.thoughtSide,
                    AppStrings.thoughtDescription,
                    Icons.psychology,
                  );
                } else if (clickedSide == 'behavior') {
                  _showSideDescription(
                    context,
                    AppStrings.behaviorSide,
                    AppStrings.behaviorDescription,
                    Icons.directions_walk,
                  );
                }
              },
            ),

            SizedBox(height: AppSizes.xl),

            // Instruction text
            Text(
              AppStrings.tapTriangleSide,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textHint,
              ),
            ),

            SizedBox(height: AppSizes.xl),

            // Interaction history
            if (vm.interactions.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.history,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${vm.interactions.length} ${AppStrings.interactionSaved}',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.md),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.interactions.length.clamp(0, 10),
                itemBuilder: (context, index) {
                  final item = vm.interactions[index];
                  return _InteractionHistoryTile(interaction: item);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSideDescription(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        title: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            SizedBox(width: AppSizes.sm),
            Text(title),
          ],
        ),
        content: Text(
          description,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondary,
            height: 1.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }
}

/// Interactive triangle widget with 3 tappable sides.
class _InteractiveTriangle extends StatelessWidget {
  final bool isSaving;
  final void Function(String side) onSideTapped;

  const _InteractiveTriangle({
    required this.isSaving,
    required this.onSideTapped,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.75;

    return SizedBox(
      width: size,
      height: size * 0.9,
      child: Stack(
        children: [
          // Triangle background
          Center(
            child: CustomPaint(
              size: Size(size, size * 0.85),
              painter: _TrianglePainter(),
            ),
          ),

          // Top vertex — Thought
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _TriangleSideButton(
                label: AppStrings.thoughtSide,
                icon: Icons.psychology,
                color: AppColors.primary,
                isLoading: isSaving,
                onTap: () => onSideTapped('thought'),
              ),
            ),
          ),

          // Bottom-left vertex — Body
          Positioned(
            bottom: 0,
            left: 0,
            child: _TriangleSideButton(
              label: AppStrings.bodySide,
              icon: Icons.accessibility_new,
              color: AppColors.secondary,
              isLoading: isSaving,
              onTap: () => onSideTapped('body'),
            ),
          ),

          // Bottom-right vertex — Behavior
          Positioned(
            bottom: 0,
            right: 0,
            child: _TriangleSideButton(
              label: AppStrings.behaviorSide,
              icon: Icons.directions_walk,
              color: AppColors.success,
              isLoading: isSaving,
              onTap: () => onSideTapped('behavior'),
            ),
          ),

          // Center label
          Center(
            child: Container(
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.change_history,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tappable button for each triangle vertex.
class _TriangleSideButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _TriangleSideButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
        child: Container(
          padding: EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: 2),
              Text(
                label,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Triangle painter for the background shape.
class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// History tile for a single interaction.
class _InteractionHistoryTile extends StatelessWidget {
  final dynamic interaction;

  const _InteractionHistoryTile({required this.interaction});

  @override
  Widget build(BuildContext context) {
    final side = interaction.sideClicked as String;
    final date = interaction.interactionDate as DateTime;

    String sideLabel;
    IconData sideIcon;
    Color sideColor;

    switch (side) {
      case 'thought':
        sideLabel = AppStrings.thoughtSide;
        sideIcon = Icons.psychology;
        sideColor = AppColors.primary;
        break;
      case 'body':
        sideLabel = AppStrings.bodySide;
        sideIcon = Icons.accessibility_new;
        sideColor = AppColors.secondary;
        break;
      default:
        sideLabel = AppStrings.behaviorSide;
        sideIcon = Icons.directions_walk;
        sideColor = AppColors.success;
    }

    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        leading: Icon(sideIcon, color: sideColor),
        title: Text(
          sideLabel,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          PersianDateFormatter.time(date),
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontSm,
            color: AppColors.textHint,
          ),
        ),
        trailing: interaction.vibrationTriggered
            ? const Icon(Icons.vibration, color: AppColors.warning, size: 20)
            : null,
      ),
    );
  }
}
