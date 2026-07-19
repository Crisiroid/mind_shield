import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/token_service.dart';
import '../view_models/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSizes.paddingScreen,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.appTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    AppStrings.welcomeBack,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: AppSizes.xxl),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      hintText: AppStrings.phoneNumber,
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: _validatePhone,
                  ),
                  SizedBox(height: AppSizes.md),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: AppStrings.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  SizedBox(height: AppSizes.lg),

                  Consumer<AuthViewModel>(
                    builder: (context, auth, _) {
                      return ElevatedButton(
                        onPressed: auth.isLoading ? null : _onLogin,
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : const Text(AppStrings.login),
                      );
                    },
                  ),
                  SizedBox(height: AppSizes.md),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.noAccount,
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontMd,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushReplacementNamed('/register'),
                        child: const Text(AppStrings.registerHere),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.phoneRequired;
    }
    if (value.length != 11 || !value.startsWith('09')) {
      return AppStrings.phoneInvalid;
    }
    for (final ch in value.runes) {
      if (ch < 48 || ch > 57) return AppStrings.phoneInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthViewModel>();
    auth
        .login(
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
        )
        .then((_) async {
          if (!mounted) return;
          if (auth.errorMessage != null) {
            DialogService.showError(
              title: AppStrings.error,
              message: auth.errorMessage!,
            );
          } else if (auth.isAuthenticated) {
            final onboardingComplete = TokenService.isOnboardingComplete();
            _syncAgreementIfNeeded(auth);
            final appProvider = context.read<AppProvider>();
            await appProvider.runInitialSync();
            if (!mounted) return;
            Navigator.of(
              context,
            ).pushReplacementNamed(onboardingComplete ? '/home' : '/roadmap');
          }
        });
  }

  void _syncAgreementIfNeeded(AuthViewModel auth) {
    if (TokenService.isAgreementAccepted()) {
      auth.acceptAgreement();
    }
  }
}
