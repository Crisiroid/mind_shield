import 'package:flutter/material.dart';
import '../../../../core/presentation/submission_flow.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../../../core/services/token_service.dart';
import '../../data/models/emotion_interaction_model.dart';
import '../../data/repositories/emotion_triangle_repository.dart';

class EmotionTriangleViewModel extends ChangeNotifier with SubmissionFlow {
  final EmotionTriangleRepository _repository;

  EmotionTriangleViewModel(this._repository);

  bool _isLoading = false;
  String? _errorMessage;
  String? _lastClickedSide;
  List<EmotionInteractionModel> _interactions = [];

  bool get isLoading => _isLoading;

  bool get isSaving => isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get lastClickedSide => _lastClickedSide;
  List<EmotionInteractionModel> get interactions => _interactions;

  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  Future<void> init() async {
    await loadInteractions();
  }

  Future<void> loadInteractions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.listInteractions();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (data) {
        _interactions = data;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> recordInteraction(String side) async {
    _lastClickedSide = side;
    notifyListeners();

    final interaction = EmotionInteractionModel(
      id: '',
      userId: '',
      interactionDate: DateTime.now(),
      sideClicked: side,
      vibrationTriggered: side == 'body',
      dayNumber: _currentDayNumber,
    );

    await submit<EmotionInteractionModel>(
      action: () => _repository.createInteraction(interaction: interaction),
      onSuccess: (outcome) {
        final saved = outcome.data;
        _interactions = [
          saved,
          ..._interactions.where((e) => e.id != saved.id),
        ];
      },
      fallbackSuccessMessage: 'تعامل هیجانی ثبت شد',
    );
    return side;
  }
}
