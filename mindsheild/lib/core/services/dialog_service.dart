import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../sync/sync_progress.dart';
import 'package:persian_fonts/persian_fonts.dart';

/// Centralized dialog service for showing errors, statuses, and confirmations.
///
/// All user-facing notifications go through dialogs — never snackbars.
/// This ensures consistent UX and keeps error display logic in one place
/// (Single Responsibility Principle).
class DialogService {
  DialogService._();

  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Public accessor for the navigator key (used by screens outside the widget tree).
  static GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  static BuildContext? get _context => _navigatorKey?.currentContext;

  // ─── Error Dialog ───────────────────────────────────────────

  /// Show an error dialog with a title and message.
  static Future<void> showError({
    required String title,
    required String message,
    String? actionText,
  }) async {
    if (_context == null) return;
    await showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 28),
            SizedBox(width: AppSizes.sm),
            Text(title),
          ],
        ),
        content: Text(
          message,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(actionText ?? 'تایید'),
          ),
        ],
      ),
    );
  }

  // ─── Success Dialog ─────────────────────────────────────────

  static Future<void> showSuccess({
    required String title,
    required String message,
    String? actionText,
  }) async {
    if (_context == null) return;
    await showDialog(
      context: _context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 28,
            ),
            SizedBox(width: AppSizes.sm),
            Text(title),
          ],
        ),
        content: Text(
          message,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(actionText ?? 'تایید'),
          ),
        ],
      ),
    );
  }

  // ─── Confirm Dialog ─────────────────────────────────────────

  static Future<bool> showConfirm({
    required String title,
    required String message,
    String confirmText = 'تایید',
    String cancelText = 'لغو',
  }) async {
    if (_context == null) return false;
    final result = await showDialog<bool>(
      context: _context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        title: Text(title),
        content: Text(
          message,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ─── Loading Dialog ─────────────────────────────────────────

  static bool _isLoadingVisible = false;

  /// Show a calming, animated loading dialog whose message gently cross-fades
  /// through a curated list of remarks so waiting never feels static.
  static void showLoading({String? message}) {
    if (_context == null || _isLoadingVisible) return;
    _isLoadingVisible = true;
    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: _SyncCard(
            child: _AnimatedLoadingContent(fixedMessage: message),
          ),
        ),
      ),
    ).whenComplete(() => _isLoadingVisible = false);
  }

  static void hideLoading() {
    if (_context == null || !_isLoadingVisible) return;
    Navigator.of(_context!).pop();
    _isLoadingVisible = false;
  }

  // ─── Sync Progress Dialog ───────────────────────────────────

  static bool _isSyncVisible = false;

  /// Show an animated sync dialog driven by a [ValueListenable] of
  /// [SyncProgress]. Renders `done/total` plus the current remark and
  /// auto-dismisses once [SyncProgress.isComplete] becomes true.
  static void showSyncProgress(ValueListenable<SyncProgress> progress) {
    if (_context == null || _isSyncVisible) return;
    _isSyncVisible = true;
    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: _SyncCard(child: _SyncProgressContent(progress: progress)),
        ),
      ),
    ).whenComplete(() => _isSyncVisible = false);
  }

  /// Dismiss the sync dialog if it is showing.
  static void hideSyncProgress() {
    if (_context == null || !_isSyncVisible) return;
    Navigator.of(_context!).pop();
    _isSyncVisible = false;
  }

  // ─── Offline Info Dialog ────────────────────────────────────

  static Future<void> showOfflineMessage({required String message}) async {
    if (_context == null) return;
    await showDialog(
      context: _context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        title: Row(
          children: [
            const Icon(Icons.cloud_off, color: AppColors.warning, size: 28),
            SizedBox(width: AppSizes.sm),
            const Text('حالت آفلاین'),
          ],
        ),
        content: Text(
          message,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('تایید'),
          ),
        ],
      ),
    );
  }
}

/// Rounded surface card shared by the loading and sync dialogs so both speak
/// the same visual language (RTL, [AppColors], [AppSizes], Vazir font).
class _SyncCard extends StatelessWidget {
  final Widget child;

  const _SyncCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(minWidth: 240, maxWidth: 320),
          padding: EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A gently pulsing indicator whose caption cross-fades through a curated
/// remark list every ~2.5s so waiting feels calm rather than static.
class _AnimatedLoadingContent extends StatefulWidget {
  /// When provided, this fixed message is shown instead of rotating remarks.
  final String? fixedMessage;

  const _AnimatedLoadingContent({this.fixedMessage});

  @override
  State<_AnimatedLoadingContent> createState() =>
      _AnimatedLoadingContentState();
}

class _AnimatedLoadingContentState extends State<_AnimatedLoadingContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _remarkTimer;
  int _remarkIndex = 0;

  List<String> get _remarks => AppStrings.loadingRemarks;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    if (widget.fixedMessage == null && _remarks.isNotEmpty) {
      _remarkTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
        if (!mounted) return;
        setState(() => _remarkIndex = (_remarkIndex + 1) % _remarks.length);
      });
    }
  }

  @override
  void dispose() {
    _remarkTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message =
        widget.fixedMessage ??
        (_remarks.isEmpty ? AppStrings.loading : _remarks[_remarkIndex]);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 0.82, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.55, end: 1.0).animate(_controller),
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
        ),
        SizedBox(height: AppSizes.md),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            message,
            key: ValueKey(message),
            textAlign: TextAlign.center,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders live [SyncProgress] with a determinate bar, `done/total` counter
/// and the current remark, auto-dismissing once the run completes.
class _SyncProgressContent extends StatelessWidget {
  final ValueListenable<SyncProgress> progress;

  const _SyncProgressContent({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SyncProgress>(
      valueListenable: progress,
      builder: (context, value, _) {
        // Auto-dismiss right after the final frame paints.
        if (value.isComplete) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            DialogService.hideSyncProgress();
          });
        }
        final remark = value.remark.isEmpty
            ? AppStrings.preparingSpace
            : value.remark;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.initialSyncTitle,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: LinearProgressIndicator(
                value: value.total == 0 ? null : value.fraction,
                minHeight: 6,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppSizes.sm),
            if (value.total > 0)
              Text(
                '${value.done}/${value.total}',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textSecondary,
                ),
              ),
            SizedBox(height: AppSizes.sm),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                remark,
                key: ValueKey(remark),
                textAlign: TextAlign.center,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
