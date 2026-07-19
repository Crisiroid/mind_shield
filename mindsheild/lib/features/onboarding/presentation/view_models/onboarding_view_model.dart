import 'package:flutter/material.dart';
import '../../../../core/services/token_service.dart';

class OnboardingViewModel extends ChangeNotifier {
  bool _agreementAccepted = false;
  bool _onboardingComplete = false;
  bool _isLoading = false;

  bool get agreementAccepted => _agreementAccepted;
  bool get onboardingComplete => _onboardingComplete;
  bool get isLoading => _isLoading;

  void loadState() {
    _agreementAccepted = TokenService.isAgreementAccepted();
    _onboardingComplete = TokenService.isOnboardingComplete();
    notifyListeners();
  }

  Future<void> acceptAgreement() async {
    _isLoading = true;
    notifyListeners();

    await TokenService.setAgreementAccepted(true);
    _agreementAccepted = true;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await TokenService.setOnboardingComplete(true);
    _onboardingComplete = true;
    notifyListeners();
  }

  Future<void> reset() async {
    await TokenService.setAgreementAccepted(false);
    await TokenService.setOnboardingComplete(false);
    _agreementAccepted = false;
    _onboardingComplete = false;
    notifyListeners();
  }
}
