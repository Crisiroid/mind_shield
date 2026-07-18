import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/sky_thought_model.dart';
import '../view_models/thought_sky_view_model.dart';

/// Thought Sky screen (Week 8) — the user types a negative thought which
/// turns into a cloud drifting across a sky background; swiping/dragging a
/// cloud dismisses it (updating the backend). A persistent mantra reminds
/// the user: "من آسمانم، ابرها در حال عبورند".
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
          // The sky
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
                  // Persistent mantra
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

                  // Empty-state hint
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

                  // Loading indicator
                  if (vm.isLoading)
                    const Center(child: CircularProgressIndicator()),

                  // Drifting clouds
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

          // Input bar
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

/// A single cloud that drifts horizontally across the sky and can be
/// swiped away to dismiss it.
class _DriftingCloud extends StatefulWidget {
  final SkyThoughtModel cloud;
  final VoidCallback onSwipe;

  const _DriftingCloud({super.key, required this.cloud, required this.onSwipe});

  @override
  State<_DriftingCloud> createState() => _DriftingCloudState();
}

class _DriftingCloudState extends State<_DriftingCloud>
    with SingleTickerProviderStateMixin {
  // Fixed vertical lanes in the upper sky the clouds travel along.
  static const List<double> _lanes = [-0.78, -0.58, -0.38, -0.18, 0.02, 0.22];

  late final AnimationController _controller;
  late final double _verticalAlign;
  late final double _phaseOffset;

  @override
  void initState() {
    super.initState();

    // Derive every visual property from a stable seed tied to the cloud's
    // identity — never from its position in the list. This keeps each cloud
    // on the same lane at the same speed even as other clouds are added or
    // swiped away, so nothing "jumps" when the list changes.
    final seed =
        (widget.cloud.id.isNotEmpty
                ? widget.cloud.id
                : widget.cloud.thoughtText)
            .hashCode
            .abs();

    _verticalAlign = _lanes[seed % _lanes.length];

    // Stagger the starting position across the visible sky so freshly added
    // clouds appear immediately, fully in view, instead of starting off the
    // right edge and slowly drifting in. Mapped through the x formula below
    // this range keeps every cloud's initial position on-screen.
    _phaseOffset = 0.28 + (seed % 1000) / 1000 * 0.44;

    // Vary the drift speed a little so clouds don't move in lockstep.
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
          // Loop the phase so the cloud continuously enters from the right
          // (x = 1.3, off-screen) and exits to the left (x = -1.3).
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

/// The visual cloud bubble carrying a thought's text, painted as a soft,
/// fluffy cloud silhouette rather than a plain rounded box.
class _CloudBubble extends StatelessWidget {
  final String text;

  const _CloudBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: CustomPaint(
        painter: const _CloudPainter(),
        // Generous padding keeps the text within the fluffy silhouette,
        // clear of the top bumps and rounded base.
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

/// Paints a soft, multi-lobed cloud silhouette that fills the given size.
class _CloudPainter extends CustomPainter {
  const _CloudPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Build the cloud as the union of a rounded base body plus several
    // overlapping circular puffs. A non-zero fill merges them into one
    // smooth silhouette with no internal seams.
    final path = Path()..fillType = PathFillType.nonZero;

    final bodyRect = Rect.fromLTWH(w * 0.05, h * 0.34, w * 0.90, h * 0.60);
    path.addRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(bodyRect.height / 2)),
    );
    // Top fluffy bumps.
    path.addOval(
      Rect.fromCircle(center: Offset(w * 0.30, h * 0.36), radius: h * 0.28),
    );
    path.addOval(
      Rect.fromCircle(center: Offset(w * 0.52, h * 0.24), radius: h * 0.34),
    );
    path.addOval(
      Rect.fromCircle(center: Offset(w * 0.72, h * 0.36), radius: h * 0.28),
    );
    // Side puffs.
    path.addOval(
      Rect.fromCircle(center: Offset(w * 0.14, h * 0.64), radius: h * 0.24),
    );
    path.addOval(
      Rect.fromCircle(center: Offset(w * 0.86, h * 0.64), radius: h * 0.24),
    );

    // Soft drop shadow beneath the cloud.
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.30), 6, false);

    // Fill with a gentle top-to-bottom white -> pale-blue gradient for depth.
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

/// The bottom input bar for typing and releasing a new thought.
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
