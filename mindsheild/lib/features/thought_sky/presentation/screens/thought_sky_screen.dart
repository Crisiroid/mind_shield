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
                  for (var i = 0; i < vm.clouds.length; i++)
                    _DriftingCloud(
                      key: ValueKey(vm.clouds[i]),
                      cloud: vm.clouds[i],
                      lane: i,
                      onSwipe: () => vm.swipeAway(vm.clouds[i]),
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
  final int lane;
  final VoidCallback onSwipe;

  const _DriftingCloud({
    super.key,
    required this.cloud,
    required this.lane,
    required this.onSwipe,
  });

  @override
  State<_DriftingCloud> createState() => _DriftingCloudState();
}

class _DriftingCloudState extends State<_DriftingCloud>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final double _verticalAlign;

  @override
  void initState() {
    super.initState();
    // Vary the drift speed a little so clouds don't move in lockstep.
    final seconds = 16 + (widget.lane % 5) * 3;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: seconds),
    )..repeat();

    // Spread clouds across five vertical lanes in the upper sky.
    final lanes = [-0.75, -0.5, -0.25, 0.0, 0.25];
    _verticalAlign = lanes[widget.lane % lanes.length];
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
          // Drift from right (1.2) to left (-1.2) for an RTL "passing" feel.
          final x = 1.2 - 2.4 * _controller.value;
          return Align(alignment: Alignment(x, _verticalAlign), child: child);
        },
        child: Dismissible(
          key: ValueKey('cloud-${widget.cloud.id}-${widget.lane}'),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => widget.onSwipe(),
          child: _CloudBubble(text: widget.cloud.thoughtText),
        ),
      ),
    );
  }
}

/// The visual cloud bubble carrying a thought's text.
class _CloudBubble extends StatelessWidget {
  final String text;

  const _CloudBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      margin: EdgeInsets.symmetric(horizontal: AppSizes.sm),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
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
    );
  }
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
            ElevatedButton(
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
          ],
        ),
      ),
    );
  }
}
