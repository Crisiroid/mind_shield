import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../view_models/onboarding_view_model.dart';

class WelcomeAgreementScreen extends StatefulWidget {
  const WelcomeAgreementScreen({super.key});

  @override
  State<WelcomeAgreementScreen> createState() => _WelcomeAgreementScreenState();
}

class _WelcomeAgreementScreenState extends State<WelcomeAgreementScreen> {
  bool _iAgree = false;

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingViewModel>();

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppSizes.paddingScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppSizes.xxl),

                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSizes.lg),

                Text(
                  AppStrings.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontTitle,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                Text(
                  AppStrings.welcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontLg,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: AppSizes.xxl),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: AppColors.primary,
                            size: AppSizes.iconMd,
                          ),
                          SizedBox(width: AppSizes.sm),
                          Text(
                            AppStrings.agreementTitle,
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
                        AppStrings.agreementText,
                        textAlign: TextAlign.justify,
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontMd,
                          color: AppColors.textPrimary,
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSizes.md),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: AppSizes.iconMd,
                      ),
                      SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          AppStrings.agreementWarning,
                          textAlign: TextAlign.justify,
                          style: PersianFonts.Vazir.copyWith(
                            fontSize: AppSizes.fontSm,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSizes.xl),

                InkWell(
                  onTap: () => setState(() => _iAgree = !_iAgree),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _iAgree
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSm,
                            ),
                            border: Border.all(
                              color: _iAgree
                                  ? AppColors.primary
                                  : AppColors.textHint,
                              width: 2,
                            ),
                          ),
                          child: _iAgree
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Text(
                            AppStrings.iAgree,
                            style: PersianFonts.Vazir.copyWith(
                              fontSize: AppSizes.fontMd,
                              fontWeight: FontWeight.w500,
                              color: _iAgree
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppSizes.lg),

                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _iAgree && !onboarding.isLoading
                        ? _onContinue
                        : null,
                    child: onboarding.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        : Text(AppStrings.agreeAndContinue),
                  ),
                ),

                SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    final onboarding = context.read<OnboardingViewModel>();
    onboarding.acceptAgreement().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/register');
    });
  }
}
