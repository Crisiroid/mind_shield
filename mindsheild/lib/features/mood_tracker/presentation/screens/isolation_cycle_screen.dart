import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

/// Isolation Cycle screen (Week 7) — educational looping animation of the
/// downward spiral: work pressure -> less activity -> lower mood -> more
/// isolation. Purely educational, no backend interaction.
class IsolationCycleScreen extends StatefulWidget {
  const IsolationCycleScreen({super.key});

  @override
  State<IsolationCycleScreen> createState() => _IsolationCycleScreenState();
}

class _IsolationCycleScreenState extends State<IsolationCycleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<String> _stages = [
    AppStrings.isolationStagePressure,
    AppStrings.isolationStageLessActivity,
    AppStrings.isolationStageLowMood,
    AppStrings.isolationStageIsolation,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.isolationCycleTitle)),
      body: SingleChildScrollView(
        padding: AppSizes.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.isolationCycleSubtitle,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
                height: 1.8,
              ),
            ),
            SizedBox(height: AppSizes.lg),

            // Animated cycle diagram
            AspectRatio(
              aspectRatio: 1,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _IsolationCyclePainter(
                      progress: _controller.value,
                      stages: _stages,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: AppSizes.lg),

            // Break-the-cycle message
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.success,
                    size: 28,
                  ),
                  SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      AppStrings.isolationCycleMessage,
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontMd,
                        color: AppColors.textPrimary,
                        height: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.lg),

            // Break the cycle -> go to micro activities
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/micro-activities'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                icon: const Icon(Icons.bolt, color: Colors.white),
                label: Text(
                  AppStrings.isolationBreakCta,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints four stage nodes on a ring with a rotating highlight and
/// clockwise arrows, illustrating the self-reinforcing downward cycle.
class _IsolationCyclePainter extends CustomPainter {
  final double progress;
  final List<String> stages;

  _IsolationCyclePainter({required this.progress, required this.stages});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 56;

    // Ring
    final ringPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, ringPaint);

    // Rotating highlight arc (shows the cycle "moving")
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.secondary.withValues(alpha: 0.0),
          AppColors.secondary.withValues(alpha: 0.7),
        ],
        startAngle: 0,
        endAngle: math.pi / 2,
        transform: GradientRotation(2 * math.pi * progress),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2 * math.pi * progress,
      math.pi / 2,
      false,
      sweepPaint,
    );

    // The active stage index based on progress
    final activeIndex = (progress * stages.length).floor() % stages.length;

    // Stage nodes at N, E, S, W positions
    for (var i = 0; i < stages.length; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / stages.length);
      final nodeCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final isActive = i == activeIndex;

      final nodePaint = Paint()
        ..color = isActive ? AppColors.secondary : AppColors.primary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(nodeCenter, isActive ? 34 : 28, nodePaint);

      // Stage number
      final numberPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      numberPainter.paint(
        canvas,
        nodeCenter - Offset(numberPainter.width / 2, numberPainter.height / 2),
      );

      // Stage label below the node
      final labelPainter = TextPainter(
        text: TextSpan(
          text: stages[i],
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 110);
      labelPainter.paint(
        canvas,
        Offset(
          nodeCenter.dx - labelPainter.width / 2,
          nodeCenter.dy + (isActive ? 40 : 34),
        ),
      );
    }

    // Center down-arrow denoting the downward spiral
    final centerArrow = TextPainter(
      text: const TextSpan(
        text: '↻',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    centerArrow.paint(
      canvas,
      center - Offset(centerArrow.width / 2, centerArrow.height / 2),
    );
  }

  @override
  bool shouldRepaint(_IsolationCyclePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
