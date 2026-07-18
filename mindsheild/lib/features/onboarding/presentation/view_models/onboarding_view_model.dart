import 'package:flutter/material.dart';
import '../../../../core/services/token_service.dart';

/// Onboarding ViewModel — manages the Phase Zero onboarding flow state.
///
/// Tracks agreement acceptance and roadmap completion status locally
/// so the splash screen can decide navigation without API calls (SRP).
/// Follows the same Provider + ChangeNotifier pattern as AuthViewModel.
class OnboardingViewModel extends ChangeNotifier {
  bool _agreementAccepted = false;
  bool _onboardingComplete = false;
  bool _isLoading = false;

  bool get agreementAccepted => _agreementAccepted;
  bool get onboardingComplete => _onboardingComplete;
  bool get isLoading => _isLoading;

  /// Load onboarding state from local storage (SharedPreferences).
  /// Called once at app start from the splash screen.
  void loadState() {
    _agreementAccepted = TokenService.isAgreementAccepted();
    _onboardingComplete = TokenService.isOnboardingComplete();
    notifyListeners();
  }

  /// Accept the digital therapy agreement — persists locally.
  Future<void> acceptAgreement() async {
    _isLoading = true;
    notifyListeners();

    await TokenService.setAgreementAccepted(true);
    _agreementAccepted = true;

    _isLoading = false;
    notifyListeners();
  }

  /// Mark the 56-day roadmap as seen — persists locally.
  Future<void> completeOnboarding() async {
    await TokenService.setOnboardingComplete(true);
    _onboardingComplete = true;
    notifyListeners();
  }

  /// Reset onboarding state (e.g., on logout).
  Future<void> reset() async {
    await TokenService.setAgreementAccepted(false);
    await TokenService.setOnboardingComplete(false);
    _agreementAccepted = false;
    _onboardingComplete = false;
    notifyListeners();
  }
}
