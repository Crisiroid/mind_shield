import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.helpAndAbout),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSizes.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAboutCard(),
            SizedBox(height: AppSizes.md),
            _buildCreatorsCard(),
            SizedBox(height: AppSizes.md),
            _buildFeaturesCard(),
            SizedBox(height: AppSizes.md),
            _buildContactCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return _HelpCard(
      title: AppStrings.aboutApp,
      icon: Icons.info_outline,
      children: [
        Text(
          AppStrings.aboutAppDescription,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondary,
            height: 1.8,
          ),
        ),
        SizedBox(height: AppSizes.md),
        Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 20),
            SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                AppStrings.aboutFeature1,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 20),
            SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                AppStrings.aboutFeature2,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 20),
            SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                AppStrings.aboutFeature3,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreatorsCard() {
    return _HelpCard(
      title: AppStrings.creators,
      icon: Icons.people_outline,
      children: [
        _CreatorTile(name: AppStrings.creator1, role: AppStrings.creator1Role),
        Divider(height: AppSizes.lg),
        _CreatorTile(name: AppStrings.creator2, role: AppStrings.creator2Role),
      ],
    );
  }

  Widget _buildFeaturesCard() {
    return _HelpCard(
      title: AppStrings.appFeatures,
      icon: Icons.featured_play_list_outlined,
      children: [
        _FeatureItem(icon: Icons.timeline, text: AppStrings.feature1),
        _FeatureItem(icon: Icons.self_improvement, text: AppStrings.feature2),
        _FeatureItem(icon: Icons.psychology, text: AppStrings.feature3),
        _FeatureItem(icon: Icons.air, text: AppStrings.feature4),
        _FeatureItem(icon: Icons.track_changes, text: AppStrings.feature5),
        _FeatureItem(icon: Icons.balance, text: AppStrings.feature6),
      ],
    );
  }

  Widget _buildContactCard() {
    return _HelpCard(
      title: AppStrings.needHelp,
      icon: Icons.help_outline,
      children: [
        Text(
          AppStrings.contactSupport,
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
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            children: [
              Icon(Icons.email_outlined, color: AppColors.info, size: 24),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.emailSupport,
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'support@mindsheild.app',
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HelpCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _HelpCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              SizedBox(width: AppSizes.sm),
              Text(
                title,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          ...children,
        ],
      ),
    );
  }
}

class _CreatorTile extends StatelessWidget {
  final String name;
  final String role;

  const _CreatorTile({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: Colors.white, size: 24),
        ),
        SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                role,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              text,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
