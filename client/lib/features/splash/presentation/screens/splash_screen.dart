import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/persian_date_formatter.dart';

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

    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  Future<void> _loadLastLogin() async {
    final lastLogin = DateTime.tryParse(TokenService.getLastLogin() ?? '');
    if (lastLogin != null && mounted) {
      setState(() => _lastLoginTime = PersianDateFormatter.dateTime(lastLogin));
    }
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final isLoggedIn = TokenService.isLoggedIn();
    final agreementAccepted = TokenService.isAgreementAccepted();
    final onboardingComplete = TokenService.isOnboardingComplete();

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
