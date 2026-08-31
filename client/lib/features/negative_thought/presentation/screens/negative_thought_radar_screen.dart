import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../view_models/negative_thought_view_model.dart';

class NegativeThoughtRadarScreen extends StatefulWidget {
  const NegativeThoughtRadarScreen({super.key});

  @override
  State<NegativeThoughtRadarScreen> createState() =>
      _NegativeThoughtRadarScreenState();
}

class _NegativeThoughtRadarScreenState extends State<NegativeThoughtRadarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NegativeThoughtViewModel>().init();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NegativeThoughtViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.negativeThoughtRadarTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.instantReport),
            Tab(text: AppStrings.termiteAnimationTitle),
            Tab(text: AppStrings.thoughtImpactTitle),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _InstantReportTab(vm: vm),
          const _TermiteAnimationTab(),
          _ThoughtImpactTab(vm: vm),
        ],
      ),
    );
  }
}


class _InstantReportTab extends StatelessWidget {
  final NegativeThoughtViewModel vm;

  const _InstantReportTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.instantReportSubtitle,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            AppStrings.situationLabel,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          TextField(
            maxLines: 2,
            decoration: InputDecoration(
              hintText: AppStrings.situationHint,
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textHint,
              ),
              prefixIcon: const Icon(
                Icons.place_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            onChanged: vm.setSituation,
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            AppStrings.thoughtLabel,
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
              hintText: AppStrings.thoughtHint,
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textHint,
              ),
              prefixIcon: const Icon(
                Icons.psychology_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            onChanged: vm.setThoughtText,
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            AppStrings.errorTypeLabel,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          DropdownButtonFormField<String>(
            value: vm.selectedErrorType,
            decoration: InputDecoration(
              hintText: AppStrings.selectErrorType,
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textHint,
              ),
              prefixIcon: const Icon(
                Icons.category_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            items: NegativeThoughtViewModel.cognitiveErrorTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: vm.setSelectedErrorType,
          ),
          SizedBox(height: AppSizes.xl),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.isSaving ? null : () => vm.submitInstantReport(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
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
                      AppStrings.submit,
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


class _TermiteAnimationTab extends StatefulWidget {
  const _TermiteAnimationTab();

  @override
  State<_TermiteAnimationTab> createState() => _TermiteAnimationTabState();
}

class _TermiteAnimationTabState extends State<_TermiteAnimationTab>
    with TickerProviderStateMixin {
  late AnimationController _buildingController;
  late AnimationController _termiteController;
  late Animation<double> _buildingHealth;

  @override
  void initState() {
    super.initState();

    _buildingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _buildingHealth = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _buildingController, curve: Curves.easeInOut),
    );

    _termiteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _buildingController.forward();
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _termiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _buildingController,
              builder: (context, child) {
                return SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _BuildingWidget(health: _buildingHealth.value),
                      ...List.generate(5, (i) {
                        return AnimatedBuilder(
                          animation: _termiteController,
                          builder: (context, child) {
                            final angle = (i * 2 * math.pi / 5);
                            final dx =
                                math.cos(
                                  angle + _termiteController.value * math.pi,
                                ) *
                                60;
                            final dy =
                                math.sin(
                                  angle + _termiteController.value * math.pi,
                                ) *
                                30;
                            return Positioned(
                              left:
                                  MediaQuery.of(context).size.width / 2 +
                                  dx -
                                  12,
                              top: 100 + dy - 12,
                              child: const Icon(
                                Icons.bug_report,
                                size: 24,
                                color: Color(0xFF795548),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: AppSizes.md),

          AnimatedBuilder(
            animation: _buildingController,
            builder: (context, child) {
              final health = _buildingHealth.value;
              Color barColor;
              if (health > 0.6) {
                barColor = AppColors.success;
              } else if (health > 0.3) {
                barColor = AppColors.warning;
              } else {
                barColor = AppColors.error;
              }
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.buildingHealth,
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontSm,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${(health * 100).round()}%',
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.bold,
                          color: barColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.xs),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerRight,
                      widthFactor: health,
                      child: Container(
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: AppSizes.xl),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.error, size: 24),
                    SizedBox(width: AppSizes.sm),
                    Text(
                      AppStrings.termiteAnimationTitle,
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.md),
                Text(
                  AppStrings.termiteEducationText,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                ),
                SizedBox(height: AppSizes.md),
                Container(
                  padding: EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Text(
                    AppStrings.termiteKeyLesson,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildingWidget extends StatelessWidget {
  final double health;

  const _BuildingWidget({required this.health});

  @override
  Widget build(BuildContext context) {
    final buildingColor = Color.lerp(
      AppColors.success,
      AppColors.error,
      1.0 - health,
    )!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 120, height: 0),
        CustomPaint(
          size: const Size(140, 50),
          painter: _TrianglePainter(
            color: buildingColor.withValues(alpha: health.clamp(0.3, 1.0)),
          ),
        ),
        Container(
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            color: buildingColor.withValues(alpha: health.clamp(0.3, 1.0)),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...List.generate(2, (row) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...List.generate(2, (col) {
                      return Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: health > 0.5
                              ? Colors.yellow.withValues(alpha: 0.7)
                              : Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
        if (health < 0.7) Icon(Icons.remove, size: 16, color: buildingColor),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _ThoughtImpactTab extends StatelessWidget {
  final NegativeThoughtViewModel vm;

  const _ThoughtImpactTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.thoughtImpactDesc,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            AppStrings.thoughtLabel,
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
              hintText: AppStrings.thoughtHint,
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textHint,
              ),
              prefixIcon: const Icon(
                Icons.psychology_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            onChanged: vm.setThoughtText,
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            AppStrings.errorTypeLabel,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          DropdownButtonFormField<String>(
            value: vm.selectedErrorType,
            decoration: InputDecoration(
              hintText: AppStrings.selectErrorType,
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textHint,
              ),
              prefixIcon: const Icon(
                Icons.category_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            items: NegativeThoughtViewModel.cognitiveErrorTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: vm.setSelectedErrorType,
          ),
          SizedBox(height: AppSizes.xl),

          Text(
            AppStrings.impactLevel,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          _buildImpactSlider(),
          SizedBox(height: AppSizes.xl),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.isSaving ? null : () => vm.submitThoughtImpact(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
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
                      AppStrings.submit,
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

  Widget _buildImpactSlider() {
    Color impactColor;
    if (vm.impactLevel <= 3) {
      impactColor = AppColors.success;
    } else if (vm.impactLevel <= 6) {
      impactColor = AppColors.warning;
    } else {
      impactColor = AppColors.error;
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
            AppStrings.lowImpact,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.success,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: impactColor,
                inactiveTrackColor: impactColor.withValues(alpha: 0.2),
                thumbColor: impactColor,
                overlayColor: impactColor.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: vm.impactLevel.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (value) => vm.setImpactLevel(value.toInt()),
              ),
            ),
          ),
          Text(
            AppStrings.highImpact,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.error,
            ),
          ),
          SizedBox(width: AppSizes.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: impactColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(
              '${vm.impactLevel}',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.bold,
                color: impactColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
