import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/dialog_service.dart';
import '../view_models/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.user == null
          ? _buildErrorState(vm)
          : RefreshIndicator(
              onRefresh: () => vm.loadProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSizes.md),
                child: Column(
                  children: [
                    _buildAccountInfoCard(vm),
                    SizedBox(height: AppSizes.md),
                    _buildSecurityCard(vm),
                    SizedBox(height: AppSizes.md),
                    _buildDeviceInfoCard(vm),
                    SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorState(ProfileViewModel vm) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          SizedBox(height: AppSizes.md),
          Text(
            vm.error ?? AppStrings.unknownError,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.md),
          ElevatedButton(
            onPressed: () => vm.loadProfile(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: Text(
              AppStrings.retry,
              style: PersianFonts.Vazir.copyWith(fontSize: AppSizes.fontMd),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(ProfileViewModel vm) {
    final user = vm.user!;
    return _ProfileCard(
      title: AppStrings.accountInfo,
      icon: Icons.person_outline,
      children: [
        _InfoRow(
          icon: Icons.phone_outlined,
          label: AppStrings.phoneNumberLabel,
          value: user.phoneNumber,
        ),
        _InfoRow(
          icon: Icons.calendar_today_outlined,
          label: AppStrings.registrationDateLabel,
          value: user.registrationDate != null
              ? _formatDate(user.registrationDate!)
              : AppStrings.notAvailable,
        ),
        _InfoRow(
          icon: Icons.access_time,
          label: AppStrings.lastLoginLabel,
          value: user.lastLogin != null
              ? _formatDate(user.lastLogin!)
              : AppStrings.notAvailable,
        ),
        _InfoRow(
          icon: Icons.login,
          label: AppStrings.loginCountLabel,
          value: '${user.loginCount}',
        ),
        _InfoRow(
          icon: Icons.check_circle_outline,
          label: AppStrings.agreementStatusLabel,
          value: user.agreementAccepted
              ? AppStrings.agreementAccepted
              : AppStrings.agreementNotAccepted,
          valueColor: user.agreementAccepted
              ? AppColors.success
              : AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildSecurityCard(ProfileViewModel vm) {
    return _ProfileCard(
      title: AppStrings.securitySection,
      icon: Icons.lock_outline,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.key_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            AppStrings.changePassword,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_left,
            color: AppColors.textSecondary,
          ),
          onTap: () => _showChangePasswordDialog(vm),
        ),
      ],
    );
  }

  Widget _buildDeviceInfoCard(ProfileViewModel vm) {
    final user = vm.user!;
    return _ProfileCard(
      title: AppStrings.deviceInfo,
      icon: Icons.devices_outlined,
      children: [
        _InfoRow(
          icon: Icons.android,
          label: AppStrings.androidVersionLabel,
          value: user.androidVersion ?? AppStrings.notAvailable,
        ),
        _InfoRow(
          icon: Icons.info_outline,
          label: AppStrings.appVersionLabel,
          value: user.appVersion ?? AppStrings.notAvailable,
        ),
      ],
    );
  }

  void _showChangePasswordDialog(ProfileViewModel vm) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.key_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Text(
                AppStrings.changePassword,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPassCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppStrings.currentPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? AppStrings.passwordRequired
                      : null,
                ),
                SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: newPassCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppStrings.newPassword,
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.passwordRequired;
                    }
                    if (v.length < 6) return AppStrings.passwordTooShort;
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: vm.isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      DialogService.showLoading();
                      final success = await vm.changePassword(
                        oldPassword: oldPassCtrl.text,
                        newPassword: newPassCtrl.text,
                      );
                      DialogService.hideLoading();

                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();

                      if (success) {
                        DialogService.showSuccess(
                          title: AppStrings.success,
                          message: AppStrings.passwordChanged,
                        );
                      } else {
                        DialogService.showError(
                          title: AppStrings.error,
                          message: vm.error ?? AppStrings.unknownError,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: vm.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      AppStrings.save,
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontMd,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$year/$month/$day  $hour:$minute';
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ProfileCard({
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          SizedBox(width: AppSizes.sm),
          Text(
            '$label: ',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
