import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String? feedbackCorrect;
  final String? feedbackWrong;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.feedbackCorrect,
    this.feedbackWrong,
  });
}

class MultiChoiceQuizPage extends StatefulWidget {
  final String title;
  final List<QuizQuestion> questions;
  final ValueChanged<int> onCompleted;
  final String endMessage;
  final String buttonText;

  const MultiChoiceQuizPage({
    super.key,
    required this.title,
    required this.questions,
    required this.onCompleted,
    required this.endMessage,
    this.buttonText = 'ادامه',
  });

  @override
  State<MultiChoiceQuizPage> createState() => _MultiChoiceQuizPageState();
}

class _MultiChoiceQuizPageState extends State<MultiChoiceQuizPage> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  int _score = 0;
  bool _showResult = false;
  bool _canRetry = false;

  @override
  Widget build(BuildContext context) {
    if (_showResult) return _buildResult();

    final q = widget.questions[_currentQuestion];

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'سؤال ${_currentQuestion + 1} از ${widget.questions.length}',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            q.question,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          ...List.generate(q.options.length, (i) {
            final isSelected = _selectedAnswer == i;
            final isCorrectOption = i == q.correctAnswerIndex;
            Color borderColor;
            Color bgColor;

            if (!_hasAnswered) {
              borderColor = isSelected ? AppColors.primary : AppColors.divider;
              bgColor = isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface;
            } else {
              if (isCorrectOption) {
                borderColor = AppColors.success;
                bgColor = AppColors.success.withValues(alpha: 0.08);
              } else if (isSelected && !_isCorrect) {
                borderColor = AppColors.error;
                bgColor = AppColors.error.withValues(alpha: 0.08);
              } else {
                borderColor = AppColors.divider;
                bgColor = AppColors.surface;
              }
            }

            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.sm),
              child: Material(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: _hasAnswered && !_canRetry ? null : () => _onSelect(i),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Container(
                    padding: EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      q.options[i],
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontMd,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          if (_hasAnswered && _isCorrect) ...[
            SizedBox(height: AppSizes.md),
            _buildFeedback(true, q.feedbackCorrect),
          ],
          if (_hasAnswered && !_isCorrect) ...[
            SizedBox(height: AppSizes.md),
            _buildFeedback(false, q.feedbackWrong),
            if (_canRetry)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedAnswer = null;
                      _hasAnswered = false;
                      _canRetry = false;
                    });
                  },
                  child: Text(
                    'تلاش دوباره',
                    style: PersianFonts.Vazir.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
          SizedBox(height: AppSizes.lg),
          if (_hasAnswered && _isCorrect)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(
                  _currentQuestion < widget.questions.length - 1
                      ? 'سؤال بعدی'
                      : 'مشاهده نتیجه',
                ),
              ),
            ),
          if (_hasAnswered && !_isCorrect && !_canRetry)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _canRetry = true);
                },
                child: const Text('تلاش دوباره'),
              ),
            ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _onSelect(int index) {
    if (_hasAnswered && !_canRetry) return;

    final q = widget.questions[_currentQuestion];
    setState(() {
      _selectedAnswer = index;
      _hasAnswered = true;
      _isCorrect = index == q.correctAnswerIndex;
      if (_isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < widget.questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _hasAnswered = false;
        _isCorrect = false;
        _canRetry = false;
      });
    } else {
      setState(() => _showResult = true);
    }
  }

  Widget _buildFeedback(bool correct, String? text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: correct
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Text(
        text ??
            (correct
                ? 'آفرین! پاسخ صحیح است.'
                : 'پاسخ نادرست. دوباره بررسی کنید.'),
        style: PersianFonts.Vazir.copyWith(
          fontSize: AppSizes.fontSm,
          color: correct ? AppColors.success : AppColors.error,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _buildResult() {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        children: [
          Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.primary),
          SizedBox(height: AppSizes.lg),
          Text(
            'پاسخ‌های صحیح: $_score از ${widget.questions.length}',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            widget.endMessage,
            textAlign: TextAlign.center,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onCompleted(_score),
              child: Text(widget.buttonText),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}
