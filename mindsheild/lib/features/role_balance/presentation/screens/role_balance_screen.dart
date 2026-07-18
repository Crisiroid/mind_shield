import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/role_value_model.dart';
import '../view_models/role_balance_view_model.dart';

/// Role Balance screen (Week 8) — visualizes the tension between the user's
/// organizational role and personal values as two overlapping circles (a
/// Venn diagram), and lets them add entries to each side, persisted to the
/// backend.
class RoleBalanceScreen extends StatefulWidget {
  const RoleBalanceScreen({super.key});

  @override
  State<RoleBalanceScreen> createState() => _RoleBalanceScreenState();
}

class _RoleBalanceScreenState extends State<RoleBalanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoleBalanceViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RoleBalanceViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.roleBalanceTitle)),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Scrollable top section (no Row with unbounded-width issues)
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSizes.paddingScreen,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.roleBalanceSubtitle,
                          style: PersianFonts.Vazir.copyWith(
                            fontSize: AppSizes.fontMd,
                            color: AppColors.textSecondary,
                            height: 1.8,
                          ),
                        ),
                        SizedBox(height: AppSizes.lg),

                        // Two overlapping circles (Venn diagram)
                        AspectRatio(
                          aspectRatio: 1.4,
                          child: CustomPaint(
                            painter: _RoleValueVennPainter(
                              overlap: vm.overlapIntensity,
                              roleCount: vm.roles.length,
                              valueCount: vm.values.length,
                            ),
                          ),
                        ),
                        SizedBox(height: AppSizes.md),

                        if (vm.hasTension)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(AppSizes.md),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                              border: Border.all(color: AppColors.warning),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.balance,
                                  color: AppColors.warning,
                                  size: 26,
                                ),
                                SizedBox(width: AppSizes.sm),
                                Expanded(
                                  child: Text(
                                    AppStrings.roleBalanceTensionMessage,
                                    style: PersianFonts.Vazir.copyWith(
                                      fontSize: AppSizes.fontSm,
                                      color: AppColors.textPrimary,
                                      height: 1.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Entry sections — outside SingleChildScrollView for bounded width
                Padding(
                  padding: AppSizes.paddingScreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Organizational role section
                      _EntrySection(
                        title: AppStrings.organizationalRole,
                        hint: AppStrings.addRoleHint,
                        buttonText: AppStrings.addRoleButton,
                        emptyText: AppStrings.noRolesYet,
                        color: AppColors.primary,
                        icon: Icons.work_outline,
                        entries: vm.roles,
                        isSaving: vm.isSaving,
                        onSubmit: (text) =>
                            vm.addEntry(entryType: 'role', text: text),
                      ),
                      SizedBox(height: AppSizes.md),

                      // Personal values section
                      _EntrySection(
                        title: AppStrings.personalValues,
                        hint: AppStrings.addValueHint,
                        buttonText: AppStrings.addValueButton,
                        emptyText: AppStrings.noValuesYet,
                        color: AppColors.secondary,
                        icon: Icons.favorite_outline,
                        entries: vm.values,
                        isSaving: vm.isSaving,
                        onSubmit: (text) =>
                            vm.addEntry(entryType: 'value', text: text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// A titled section with a text field to add an entry and a chip list of
/// existing entries.
class _EntrySection extends StatefulWidget {
  final String title;
  final String hint;
  final String buttonText;
  final String emptyText;
  final Color color;
  final IconData icon;
  final List<RoleValueModel> entries;
  final bool isSaving;
  final ValueChanged<String> onSubmit;

  const _EntrySection({
    required this.title,
    required this.hint,
    required this.buttonText,
    required this.emptyText,
    required this.color,
    required this.icon,
    required this.entries,
    required this.isSaving,
    required this.onSubmit,
  });

  @override
  State<_EntrySection> createState() => _EntrySectionState();
}

class _EntrySectionState extends State<_EntrySection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, color: widget.color, size: 22),
            SizedBox(width: AppSizes.sm),
            Text(
              widget.title,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    borderSide: BorderSide(color: widget.color),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSizes.sm),
            ElevatedButton(
              onPressed: widget.isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                // Override the global full-width `minimumSize`
                // (Size(double.infinity, ...)) from the app theme. Inside a
                // Row the button gets an unbounded max width, so an infinite
                // minimum width would force invalid constraints and crash
                // layout. Constrain it to a bounded square instead.
                minimumSize: Size.square(AppSizes.buttonHeight),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.md,
                ),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ],
        ),
        SizedBox(height: AppSizes.md),
        if (widget.entries.isEmpty)
          Text(
            widget.emptyText,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: AppColors.textHint,
            ),
          )
        else
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: widget.entries.map((entry) {
              return Chip(
                label: Text(
                  entry.entryText,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    color: widget.color,
                  ),
                ),
                backgroundColor: widget.color.withValues(alpha: 0.1),
                side: BorderSide(color: widget.color.withValues(alpha: 0.4)),
              );
            }).toList(),
          ),
      ],
    );
  }
}

/// Paints two overlapping circles representing the organizational role and
/// personal values. The overlap area grows and intensifies with the amount
/// of balance/tension between the two identities.
class _RoleValueVennPainter extends CustomPainter {
  final double overlap;
  final int roleCount;
  final int valueCount;

  _RoleValueVennPainter({
    required this.overlap,
    required this.roleCount,
    required this.valueCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final radius = math.min(size.width / 2.6, size.height / 2.2);

    // Larger overlap pulls the two circles closer together.
    final maxGap = radius;
    final minGap = radius * 0.55;
    final gap = maxGap - (maxGap - minGap) * overlap;

    final roleCenter = Offset(size.width / 2 - gap / 2, cy);
    final valueCenter = Offset(size.width / 2 + gap / 2, cy);

    final rolePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final valuePaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(roleCenter, radius, rolePaint);
    canvas.drawCircle(valueCenter, radius, valuePaint);

    // Overlap area highlighted via intersection clip.
    final rolePath = Path()
      ..addOval(Rect.fromCircle(center: roleCenter, radius: radius));
    final valuePath = Path()
      ..addOval(Rect.fromCircle(center: valueCenter, radius: radius));
    final overlapPath = Path.combine(
      PathOperation.intersect,
      rolePath,
      valuePath,
    );
    final overlapPaint = Paint()
      ..color = AppColors.warning.withValues(alpha: 0.25 + 0.45 * overlap)
      ..style = PaintingStyle.fill;
    canvas.drawPath(overlapPath, overlapPaint);

    // Circle outlines
    final outlineRole = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final outlineValue = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(roleCenter, radius, outlineRole);
    canvas.drawCircle(valueCenter, radius, outlineValue);

    // Labels
    _drawLabel(
      canvas,
      AppStrings.organizationalRole,
      '$roleCount',
      Offset(roleCenter.dx - radius * 0.45, cy),
      AppColors.primaryDark,
    );
    _drawLabel(
      canvas,
      AppStrings.personalValues,
      '$valueCount',
      Offset(valueCenter.dx + radius * 0.45, cy),
      AppColors.secondaryDark,
    );
  }

  void _drawLabel(
    Canvas canvas,
    String title,
    String count,
    Offset center,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title\n',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: count,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 120);
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_RoleValueVennPainter oldDelegate) =>
      oldDelegate.overlap != overlap ||
      oldDelegate.roleCount != roleCount ||
      oldDelegate.valueCount != valueCount;
}
