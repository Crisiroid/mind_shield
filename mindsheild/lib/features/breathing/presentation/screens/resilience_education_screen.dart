import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

/// Resilience Education screen — concrete column vs steel palm comparison.
///
/// Static educational page that teaches about psychological resilience
/// through visual metaphors. No API needed — purely informational.
class ResilienceEducationScreen extends StatelessWidget {
  const ResilienceEducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.resilienceTitle)),
      body: SingleChildScrollView(
        padding: AppSizes.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Center(
              child: Text(
                AppStrings.resilienceSubtitle,
                textAlign: TextAlign.center,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppSizes.xl),

            // Two-column comparison
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Concrete Column
                Expanded(
                  child: _ComparisonCard(
                    title: AppStrings.concreteColumnTitle,
                    description: AppStrings.concreteColumnDesc,
                    icon: Icons.account_box,
                    color: AppColors.textSecondary,
                    visual: _ConcreteColumnVisual(),
                  ),
                ),
                SizedBox(width: AppSizes.md),
                // Steel Palm
                Expanded(
                  child: _ComparisonCard(
                    title: AppStrings.steelPalmTitle,
                    description: AppStrings.steelPalmDesc,
                    icon: Icons.nature,
                    color: AppColors.success,
                    visual: _SteelPalmVisual(),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSizes.xl),

            // Key lesson
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.coolGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
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
                      const Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: AppSizes.sm),
                      Text(
                        'درس کلیدی',
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontLg,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.md),
                  Text(
                    AppStrings.resilienceLesson,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 2.0,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizes.xl),

            // Visual resilience tips
            Text(
              'نشانه‌های انعطاف‌پذیری روانی:',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.md),
            _ResilienceTip(
              icon: Icons.water_drop,
              text: 'پذیرش احساسات بدون قضاوت',
            ),
            _ResilienceTip(
              icon: Icons.swap_horiz,
              text: 'سازگاری با تغییرات غیرقابل اجتناب',
            ),
            _ResilienceTip(
              icon: Icons.self_improvement,
              text: 'حفظ ارزش‌های اصلی در عین انعطاف',
            ),
            _ResilienceTip(
              icon: Icons.groups,
              text: 'کمک خواستن از دیگران در مواقع سخت',
            ),
            _ResilienceTip(
              icon: Icons.self_improvement,
              text: 'تمرین تنفس آگاهانه برای بازگشت به لحظه حال',
            ),
          ],
        ),
      ),
    );
  }
}

/// Comparison card for concrete column vs steel palm.
class _ComparisonCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget visual;

  const _ComparisonCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.visual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Visual illustration
          SizedBox(height: 120, child: Center(child: visual)),
          SizedBox(height: AppSizes.md),
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: AppSizes.xs),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: AppColors.textSecondary,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual for the concrete column (rigid, cracking).
class _ConcreteColumnVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(60, 110),
      painter: _ConcreteColumnPainter(),
    );
  }
}

class _ConcreteColumnPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final crackPaint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Column
    final columnRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 40,
        height: size.height,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(columnRect, paint);

    // Cracks
    final crackPath = Path()
      ..moveTo(size.width / 2 - 5, 20)
      ..lineTo(size.width / 2 + 3, 40)
      ..lineTo(size.width / 2 - 8, 60)
      ..lineTo(size.width / 2 + 5, 80);
    canvas.drawPath(crackPath, crackPaint);

    // Break indicator
    final breakPath = Path()
      ..moveTo(size.width / 2 + 10, 30)
      ..lineTo(size.width / 2 + 18, 50);
    canvas.drawPath(breakPath, crackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Visual for the steel palm (flexible, bending).
class _SteelPalmVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(80, 110), painter: _SteelPalmPainter());
  }
}

class _SteelPalmPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..color = AppColors.success.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Bent trunk
    final trunkPath = Path()
      ..moveTo(size.width / 2, size.height)
      ..quadraticBezierTo(
        size.width / 2 + 15,
        size.height * 0.5,
        size.width / 2 + 8,
        size.height * 0.2,
      );
    canvas.drawPath(trunkPath, trunkPaint);

    // Palm leaves
    final topX = size.width / 2 + 8;
    final topY = size.height * 0.2;

    // Left leaves
    canvas.drawLine(
      Offset(topX, topY),
      Offset(topX - 25, topY - 10),
      leafPaint,
    );
    canvas.drawLine(
      Offset(topX, topY),
      Offset(topX - 20, topY + 15),
      leafPaint,
    );

    // Right leaves
    canvas.drawLine(
      Offset(topX, topY),
      Offset(topX + 25, topY - 10),
      leafPaint,
    );
    canvas.drawLine(
      Offset(topX, topY),
      Offset(topX + 20, topY + 15),
      leafPaint,
    );

    // Top leaf
    canvas.drawLine(Offset(topX, topY), Offset(topX, topY - 20), leafPaint);

    // Wind lines
    final windPaint = Paint()
      ..color = AppColors.info.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(const Offset(0, 30), const Offset(20, 28), windPaint);
    canvas.drawLine(const Offset(5, 50), const Offset(25, 48), windPaint);
    canvas.drawLine(const Offset(0, 70), const Offset(20, 68), windPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Resilience tip row.
class _ResilienceTip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ResilienceTip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              text,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
