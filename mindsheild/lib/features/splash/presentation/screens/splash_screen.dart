import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import 'package:permission_handler/permission_handler.dart';

/// Splash screen — Phase Zero, Screen 1.
///
/// Manifests the application entry experience:
/// - Animated logo and title entrance
/// - Runtime permission requests (notification & storage) on first launch
/// - Last login timestamp display for returning users
/// - Intelligent navigation to the correct next screen based on
///   authentication and onboarding state (SRP — only decides routing).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  String? _lastLoginTime;

  @override
  void initState() {
    super.initState();

    _loadLastLogin();
    _requestPermissions();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();

    // Navigate after animation + permissions
    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  Future<void> _loadLastLogin() async {
    // Stored as a raw ISO-8601 timestamp; convert to Shamsi for display.
    final lastLogin = DateTime.tryParse(TokenService.getLastLogin() ?? '');
    if (lastLogin != null && mounted) {
      setState(() => _lastLoginTime = PersianDateFormatter.dateTime(lastLogin));
    }
  }

  Future<void> _requestPermissions() async {
    // Request notification permission (Android 13+)
    await Permission.notification.request();

    // Request storage permission (Android < 13)
    final status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final isLoggedIn = TokenService.isLoggedIn();
    final agreementAccepted = TokenService.isAgreementAccepted();
    final onboardingComplete = TokenService.isOnboardingComplete();

    // Returning user whose local mirror still needs a first pull
    // (e.g. fresh install or login on another device) — rebuild it now.
    if (isLoggedIn && TokenService.needsInitialSync()) {
      await context.read<AppProvider>().runInitialSync();
      if (!mounted) return;
    }

    String route;

    if (isLoggedIn) {
      if (!agreementAccepted) {
        route = '/welcome-agreement';
      } else if (!onboardingComplete) {
        route = '/roadmap';
      } else {
        route = '/home';
      }
    } else {
      if (!agreementAccepted) {
        route = '/welcome-agreement';
      } else {
        route = '/login';
      }
    }

    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppColors.background),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // ─── Animated Logo ──────────────────────────────────
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(opacity: _fadeAnimation.value, child: child),
                );
              },
              child: Container(
                width: AppSizes.iconXl * 2.5,
                height: AppSizes.iconXl * 2.5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: AppSizes.lg),

            // ─── Animated Title ─────────────────────────────────
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  AppStrings.appTitle,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontHeadline,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSizes.sm),

            // ─── Subtitle ───────────────────────────────────────
            FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                ),
              ),
              child: Text(
                AppStrings.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // ─── Last Login Display ─────────────────────────────
            if (_lastLoginTime != null)
              Padding(
                padding: EdgeInsets.only(top: AppSizes.lg),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: AppSizes.iconSm,
                        color: AppColors.textHint,
                      ),
                      SizedBox(width: AppSizes.xs),
                      Text(
                        '${AppStrings.lastLogin}: $_lastLoginTime',
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontSm,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // ─── Loading Indicator ──────────────────────────────
            FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                ),
              ),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ),

            SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}
