import 'dart:async';
import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

class MindfulTimerSheet extends StatefulWidget {
  const MindfulTimerSheet({super.key});

  @override
  State<MindfulTimerSheet> createState() => _MindfulTimerSheetState();
}

class _MindfulTimerSheetState extends State<MindfulTimerSheet>
    with SingleTickerProviderStateMixin {
  static const List<int> _presetMinutes = [3, 5, 10, 15, 20];

  int _selectedMinutes = 5;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _selectedMinutes * 60;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectDuration(int minutes) {
    if (_isRunning) return;
    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
    });
  }

  void _start() {
    if (_isRunning && !_isPaused) return;
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _complete();
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isPaused = true);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
  }

  void _complete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          'آفرین!',
          style: PersianFonts.Vazir.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'جلسه تایمر آگاهانه $_selectedMinutes دقیقه‌ای شما به پایان رسید.\n'
          'یک قدم کوچک برای آرامش ذهن‌تان برداشتید.',
          style: PersianFonts.Vazir.copyWith(fontSize: AppSizes.fontMd),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'بستن',
              style: PersianFonts.Vazir.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final total = _selectedMinutes * 60;
    return total == 0 ? 0 : (total - _remainingSeconds) / total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            AppStrings.mindfulTimer,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'چند دقیقه در سکوت، با تمرکز بر نفس‌هایتان',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.xl),

          _buildTimerDisplay(),
          SizedBox(height: AppSizes.xl),

          if (!_isRunning) ...[
            Text(
              'مدت زمان (دقیقه)',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _presetMinutes.map((m) {
                final selected = m == _selectedMinutes;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
                  child: ChoiceChip(
                    label: Text(
                      '$m',
                      style: PersianFonts.Vazir.copyWith(
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceVariant,
                    onSelected: (_) => _selectDuration(m),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: AppSizes.xl),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isRunning && !_isPaused)
                _ControlButton(
                  icon: Icons.pause_rounded,
                  label: 'توقف',
                  color: AppColors.warning,
                  onTap: _pause,
                )
              else if (_isRunning && _isPaused)
                _ControlButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'ادامه',
                  color: AppColors.success,
                  onTap: _start,
                )
              else
                _ControlButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'شروع',
                  color: AppColors.primary,
                  onTap: _start,
                ),
              SizedBox(width: AppSizes.md),
              _ControlButton(
                icon: Icons.refresh_rounded,
                label: 'بازنشانی',
                color: AppColors.textSecondary,
                onTap: _reset,
              ),
            ],
          ),
          SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay() {
    final isActive = _isRunning && !_isPaused;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = isActive ? 1.0 + (_pulseController.value * 0.08) : 1.0;
        return Transform.scale(
          scale: pulse,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isActive
                          ? AppColors.coolGradient
                          : [
                              AppColors.surfaceVariant,
                              AppColors.surfaceVariant,
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 6,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                Text(
                  _formatTime(_remainingSeconds),
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color.withValues(alpha: 0.1),
          shape: CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 28),
            ),
          ),
        ),
        SizedBox(height: AppSizes.xs),
        Text(
          label,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontSm,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
