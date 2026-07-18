import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../view_models/cognitive_game_view_model.dart';

/// Cognitive Errors Game screen — drag & drop game for identifying
/// cognitive errors in workplace scenarios.
///
/// User reads a scenario, then selects the correct cognitive error type
/// from answer options. Score is tracked and submitted to backend.
class CognitiveGameScreen extends StatefulWidget {
  const CognitiveGameScreen({super.key});

  @override
  State<CognitiveGameScreen> createState() => _CognitiveGameScreenState();
}

class _CognitiveGameScreenState extends State<CognitiveGameScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<CognitiveGameViewModel>();
      vm.init();
      vm.startGame();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CognitiveGameViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cognitiveGameTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.cognitiveGameTitle),
            Tab(text: AppStrings.history),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildGameTab(vm), _buildHistoryTab(vm)],
      ),
    );
  }

  Widget _buildGameTab(CognitiveGameViewModel vm) {
    if (vm.gameFinished) {
      return _buildResultScreen(vm);
    }

    final scenario = vm.currentScenario;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.scenarioOf} ${vm.currentScenarioIndex + 1} از ${CognitiveGameViewModel.scenarios.length}',
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  '${AppStrings.yourScore}: ${vm.score}',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),

          // Scenario card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.lg),
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
                      Icons.work_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    SizedBox(width: AppSizes.sm),
                    Text(
                      scenario.title,
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
                  scenario.description,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.lg),

          // Answer options
          Text(
            AppStrings.cognitiveErrorTypes,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),

          // Answer options as tappable cards
          ...scenario.answerOptions.map((option) {
            return _AnswerOption(
              option: option,
              isSelected: vm.selectedAnswer == option,
              isCorrect:
                  vm.selectedAnswer != null && option == scenario.correctAnswer,
              isWrong:
                  vm.selectedAnswer == option &&
                  option != scenario.correctAnswer,
              isDisabled: vm.selectedAnswer != null,
              onTap: () => vm.selectAnswer(option),
            );
          }),

          // Feedback after answer
          if (vm.selectedAnswer != null) ...[
            SizedBox(height: AppSizes.lg),
            _buildFeedbackCard(vm),
            SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => vm.nextScenario(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  vm.currentScenarioIndex <
                          CognitiveGameViewModel.scenarios.length - 1
                      ? AppStrings.nextScenario
                      : AppStrings.gameResult,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(CognitiveGameViewModel vm) {
    final isCorrect = vm.isAnswerCorrect ?? false;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isCorrect ? AppColors.success : AppColors.error,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? AppColors.success : AppColors.error,
            size: 28,
          ),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? AppStrings.correctAnswer : AppStrings.wrongAnswer,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? AppColors.success : AppColors.error,
                  ),
                ),
                if (!isCorrect)
                  Text(
                    'پاسخ صحیح: ${vm.currentScenario.correctAnswer}',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(CognitiveGameViewModel vm) {
    final percentage = vm.totalAnswered > 0
        ? (vm.score / vm.totalAnswered * 100).round()
        : 0;

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: AppSizes.xxl),
          Icon(
            percentage >= 70
                ? Icons.emoji_events
                : percentage >= 40
                ? Icons.star
                : Icons.lightbulb_outline,
            size: 80,
            color: percentage >= 70
                ? AppColors.warning
                : percentage >= 40
                ? AppColors.info
                : AppColors.primary,
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            AppStrings.gameResult,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Container(
            padding: EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Text(
                  '${AppStrings.yourScore}: ${vm.score} از ${vm.totalAnswered}',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontXxl,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                Text(
                  '$percentage%',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontTitle,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 70
                        ? AppColors.success
                        : percentage >= 40
                        ? AppColors.warning
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => vm.resetGame(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                AppStrings.playAgain,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(CognitiveGameViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (vm.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.textHint),
            SizedBox(height: AppSizes.md),
            Text(
              AppStrings.noHistory,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSizes.paddingScreen,
      itemCount: vm.history.length,
      itemBuilder: (context, index) {
        final entry = vm.history[index];
        return _GameHistoryCard(entry: entry);
      },
    );
  }
}

/// Answer option card widget.
class _AnswerOption extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool isDisabled;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    if (isCorrect) {
      borderColor = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: 0.08);
    } else if (isWrong) {
      borderColor = AppColors.error;
      bgColor = AppColors.error.withValues(alpha: 0.08);
    } else if (isSelected) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withValues(alpha: 0.08);
    } else {
      borderColor = AppColors.divider;
      bgColor = AppColors.surface;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.sm),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect
                      ? Icons.check_circle
                      : isWrong
                      ? Icons.cancel
                      : Icons.drag_indicator,
                  color: isCorrect
                      ? AppColors.success
                      : isWrong
                      ? AppColors.error
                      : AppColors.textHint,
                  size: 22,
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    option,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// History card for a single game result.
class _GameHistoryCard extends StatelessWidget {
  final dynamic entry;

  const _GameHistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isCorrect = entry.isCorrect as bool? ?? false;
    final score = entry.score as int? ?? 0;
    final scenarioType = entry.scenarioType as String? ?? '';
    final timeTaken = entry.timeTakenSeconds as int? ?? 0;
    final createdAt = entry.createdAt as DateTime?;

    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.md),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? AppColors.success : AppColors.error,
              size: 32,
            ),
            SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scenarioType.isNotEmpty ? scenarioType : 'سناریو $score',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    'امتیاز: $score | زمان: $timeTakenث',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontXs,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            if (createdAt != null)
              Text(
                PersianDateFormatter.monthDay(createdAt),
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textHint,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
