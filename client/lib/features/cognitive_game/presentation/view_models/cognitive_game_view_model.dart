import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/week_calculator.dart';
import '../../data/models/cognitive_game_model.dart';
import '../../data/repositories/cognitive_game_repository.dart';

class GameScenario {
  final int id;
  final String title;
  final String description;
  final String correctAnswer;
  final List<String> answerOptions;

  const GameScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.correctAnswer,
    required this.answerOptions,
  });
}

class CognitiveGameViewModel extends ChangeNotifier {
  final CognitiveGameRepository _repository;

  CognitiveGameViewModel(this._repository);

  bool _isSaving = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<CognitiveGameModel> _history = [];

  int _currentScenarioIndex = 0;
  String? _selectedAnswer;
  bool? _isAnswerCorrect;
  int _score = 0;
  int _totalAnswered = 0;
  bool _gameFinished = false;
  int _startTime = 0;

  bool get isSaving => _isSaving;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CognitiveGameModel> get history => _history;
  int get currentScenarioIndex => _currentScenarioIndex;
  String? get selectedAnswer => _selectedAnswer;
  bool? get isAnswerCorrect => _isAnswerCorrect;
  int get score => _score;
  int get totalAnswered => _totalAnswered;
  bool get gameFinished => _gameFinished;

  int get _currentDayNumber {
    final registrationDate = WeekCalculator.parseStoredDate(
      TokenService.getRegistrationDate(),
    );
    return WeekCalculator.currentDayNumber(registrationDate);
  }

  static final List<GameScenario> scenarios = [
    GameScenario(
      id: 1,
      title: AppStrings.scenario1Title,
      description: AppStrings.scenario1Description,
      correctAnswer: AppStrings.scenario1Answer,
      answerOptions: [
        AppStrings.mentalFilter,
        AppStrings.catastrophizing,
        AppStrings.overgeneralization,
        AppStrings.personalization,
      ],
    ),
    GameScenario(
      id: 2,
      title: AppStrings.scenario2Title,
      description: AppStrings.scenario2Description,
      correctAnswer: AppStrings.scenario2Answer,
      answerOptions: [
        AppStrings.overgeneralization,
        AppStrings.allOrNothing,
        AppStrings.labeling,
        AppStrings.fortuneTelling,
      ],
    ),
    GameScenario(
      id: 3,
      title: AppStrings.scenario3Title,
      description: AppStrings.scenario3Description,
      correctAnswer: AppStrings.scenario3Answer,
      answerOptions: [
        AppStrings.mindReading,
        AppStrings.blaming,
        AppStrings.emotionalReasoning,
        AppStrings.shouldStatements,
      ],
    ),
  ];

  GameScenario get currentScenario => scenarios[_currentScenarioIndex];

  Future<void> init() async {
    await loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.listCognitiveGames();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (data) {
        _history = data;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void selectAnswer(String answer) {
    if (_selectedAnswer != null) return;
    _selectedAnswer = answer;
    _isAnswerCorrect = answer == currentScenario.correctAnswer;

    if (_isAnswerCorrect!) {
      _score++;
    }
    _totalAnswered++;

    final timeTaken =
        (DateTime.now().millisecondsSinceEpoch - _startTime) ~/ 1000;

    _submitGameResult(timeTaken: timeTaken);

    notifyListeners();
  }

  void nextScenario() {
    if (_currentScenarioIndex < scenarios.length - 1) {
      _currentScenarioIndex++;
      _selectedAnswer = null;
      _isAnswerCorrect = null;
      _startTime = DateTime.now().millisecondsSinceEpoch;
      notifyListeners();
    } else {
      _gameFinished = true;
      notifyListeners();
    }
  }

  void resetGame() {
    _currentScenarioIndex = 0;
    _selectedAnswer = null;
    _isAnswerCorrect = null;
    _score = 0;
    _totalAnswered = 0;
    _gameFinished = false;
    _startTime = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  void startGame() {
    _startTime = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  Future<void> _submitGameResult({required int timeTaken}) async {
    _isSaving = true;
    notifyListeners();

    final game = CognitiveGameModel(
      id: '',
      userId: '',
      gameDate: DateTime.now().toIso8601String(),
      scenarioId: currentScenario.id,
      scenarioType: currentScenario.correctAnswer,
      score: _isAnswerCorrect! ? 100 : 0,
      isCorrect: _isAnswerCorrect,
      timeTakenSeconds: timeTaken,
      dayNumber: _currentDayNumber,
    );

    final result = await _repository.createCognitiveGame(game: game);

    result.fold((failure) {}, (outcome) {
      final saved = outcome.data;
      _history = [saved, ..._history.where((e) => e.id != saved.id)];
    });

    _isSaving = false;
    notifyListeners();
  }
}
