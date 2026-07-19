import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/sky_thought_model.dart';
import '../view_models/thought_sky_view_model.dart';

class ThoughtSkyScreen extends StatefulWidget {
  const ThoughtSkyScreen({super.key});

  @override
  State<ThoughtSkyScreen> createState() => _ThoughtSkyScreenState();
}

class _ThoughtSkyScreenState extends State<ThoughtSkyScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThoughtSkyViewModel>().load();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _release() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ThoughtSkyViewModel>().addThought(text);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ThoughtSkyViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.thoughtSkyTitle)),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF48C6EF),
                    Color(0xFFB6E6FB),
                    Color(0xFFEAF7FE),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: const Alignment(0, 0.75),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
                      child: Text(
                        AppStrings.thoughtSkyMantra,
                        textAlign: TextAlign.center,
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontLg,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.8,
                        ),
                      ),
                    ),
                  ),

                  if (!vm.isLoading && vm.clouds.isEmpty)
                    Align(
                      alignment: const Alignment(0, -0.2),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.xl),
                        child: Text(
                          AppStrings.skyEmptyMessage,
                          textAlign: TextAlign.center,
                          style: PersianFonts.Vazir.copyWith(
                            fontSize: AppSizes.fontMd,
                            color: AppColors.textSecondary,
                            height: 1.8,
                          ),
                        ),
                      ),
                    ),

                  if (vm.isLoading)
                    const Center(child: CircularProgressIndicator()),

                  for (final cloud in vm.clouds)
                    _DriftingCloud(
                      key: ValueKey(cloud.id.isNotEmpty ? cloud.id : cloud),
                      cloud: cloud,
                      onSwipe: () => vm.swipeAway(cloud),
                    ),
                ],
              ),
            ),
          ),

          _ThoughtInputBar(
            controller: _controller,
            isSaving: vm.isSaving,
            onSubmit: _release,
          ),
        ],
      ),
    );
  }
}

class _DriftingCloud extends StatefulWidget {
  final SkyThoughtModel cloud;
  final VoidCallback onSwipe;

  const _DriftingCloud({super.key, required this.cloud, required this.onSwipe});

  @override
  State<_DriftingCloud> createState() => _DriftingCloudState();
}

class _DriftingCloudState extends State<_DriftingCloud>
    with SingleTickerProviderStateMixin {
  static const List<double> _lanes = [-0.78, -0.58, -0.38, -0.18, 0.02, 0.22];

  late final AnimationController _controller;
  late final double _verticalAlign;
  late final double _phaseOffset;

  @override
  void initState() {
    super.initState();

    final seed =
        (widget.cloud.id.isNotEmpty
                ? widget.cloud.id
                : widget.cloud.thoughtText)
            .hashCode
            .abs();

    _verticalAlign = _lanes[seed % _lanes.length];

    _phaseOffset = 0.28 + (seed % 1000) / 1000 * 0.44;

    final seconds = 22 + (seed % 6) * 4;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: seconds),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final phase = (_controller.value + _phaseOffset) % 1.0;
          final x = 1.3 - 2.6 * phase;
          return Align(alignment: Alignment(x, _verticalAlign), child: child);
        },
        child: Dismissible(
          key: ObjectKey(widget.cloud),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => widget.onSwipe(),
          child: _CloudBubble(text: widget.cloud.thoughtText),
        ),
      ),
    );
  }
}

class _CloudBubble extends StatelessWidget {
  final String text;

  const _CloudBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: CustomPaint(
        painter: const _CloudPainter(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.xl,
            AppSizes.xl,
            AppSizes.xl,
            AppSizes.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
              SizedBox(height: AppSizes.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swipe, size: 14, color: AppColors.textHint),
                  SizedBox(width: 4),
                  Text(
                    AppStrings.swipeToPass,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontXs,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  const _CloudPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()..fillType = PathFillType.nonZero;

    final bodyRect = Rect.fromLTWH(w * 0.05, h * 0.34, w * 0.90, h * 0.60);
    path.addRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(bodyRect.height / 2)),
    );
    path.addOval(
      Rect.fromCircle(center: Offset(w * 0.30, h * 0.36), radius: h * 0.28),
    );
    path.addOval(
      Rect.fromCircle(center: Offset(w * 0.52, h * 0.24), radius: h * 0.34),
    );
    path.addOval(
      Rect.fromCircle(center: Offset(w * 0.72, h * 0.36), radius: h * 0.28),
    );
    path.addOval(
      Rect.fromCircle(center: Offset(w * 0.14, h * 0.64), radius: h * 0.24),
    );
    path.addOval(
      Rect.fromCircle(center: Offset(w * 0.86, h * 0.64), radius: h * 0.24),
    );

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.30), 6, false);

    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Color(0xFFEAF3FB)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(_CloudPainter oldDelegate) => false;
}

class _ThoughtInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSubmit;

  const _ThoughtInputBar({
    required this.controller,
    required this.isSaving,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.thoughtSkyInputHint,
                  hintStyle: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSizes.sm),
            SizedBox(
              width: 48,
              height: 48,
              child: ElevatedButton(
                onPressed: isSaving ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(AppSizes.md),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
