import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class AudioPlayerPage extends StatefulWidget {
  final String title;
  final String instruction;
  final String audioAssetPath;
  final String? skipText;
  final VoidCallback? onSkip;
  final ValueChanged<String> onSubmit;
  final String? safetyText;
  final String? questionText;
  final List<String>? statusOptions;

  const AudioPlayerPage({
    super.key,
    required this.title,
    required this.instruction,
    required this.audioAssetPath,
    this.skipText,
    this.onSkip,
    required this.onSubmit,
    this.safetyText,
    this.questionText,
    this.statusOptions,
  });

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedStatus;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  final _statusOptions = <String>[];
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  @override
  void initState() {
    super.initState();
    _statusOptions.addAll(
      widget.statusOptions ??
          ['بله', 'بخشی از آن را انجام دادم', 'انجام ندادم'],
    );
    _initAudio();
  }

  Future<void> _initAudio() async {
    _player = AudioPlayer();

    _playerStateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
        }
      });
    });

    _positionSub = _player.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });

    try {
      final duration = await _player.setAsset(widget.audioAssetPath);
      if (!mounted) return;
      setState(() {
        _duration = duration ?? Duration.zero;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'خطا در بارگذاری فایل صوتی';
        _isLoading = false;
      });
    }
  }

  void _togglePlay() {
    if (_isLoading || _errorMessage != null) return;
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _stop() {
    _player.pause();
    _player.seek(Duration.zero);
  }

  void _restart() {
    _player.seek(Duration.zero);
    _player.play();
  }

  void _seekTo(Duration position) {
    _player.seek(position);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          SizedBox(height: AppSizes.md),
          Text(
            widget.instruction,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.xl),
          // Safety warning (shown before audio controls)
          if (widget.safetyText != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.safetyText!,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontSm,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: AppSizes.lg),
          ],
          // Audio player controls
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              children: [
                // Waveform visualization
                _buildWaveform(),
                SizedBox(height: AppSizes.sm),
                // Progress bar and time
                _buildProgressBar(),
                SizedBox(height: AppSizes.md),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Restart
                    _buildControlButton(
                      icon: Icons.replay,
                      label: 'شروع مجدد',
                      onTap: _isLoading ? null : _restart,
                    ),
                    SizedBox(width: AppSizes.lg),
                    // Play/Pause
                    _buildMainButton(
                      isPlaying: _isPlaying,
                      isLoading: _isLoading,
                      onTap: _togglePlay,
                    ),
                    SizedBox(width: AppSizes.lg),
                    // Stop
                    _buildControlButton(
                      icon: Icons.stop,
                      label: 'توقف',
                      onTap: _isLoading ? null : _stop,
                    ),
                  ],
                ),
                // Error message
                if (_errorMessage != null) ...[
                  SizedBox(height: AppSizes.md),
                  Text(
                    _errorMessage!,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.skipText != null) ...[
            SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: widget.onSkip,
                child: Text(
                  widget.skipText!,
                  style: PersianFonts.Vazir.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          // Completion question
          Text(
            widget.questionText ?? 'آیا تمرین را انجام دادید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._statusOptions.map((option) {
            final isSelected = _selectedStatus == option;
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.sm),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: () => setState(() => _selectedStatus = option),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: option,
                          groupValue: _selectedStatus,
                          onChanged: (v) => setState(() => _selectedStatus = v),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            option,
                            style: PersianFonts.Vazir.copyWith(
                              fontSize: AppSizes.fontSm,
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
          }),
          SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedStatus != null
                  ? () {
                      widget.onSubmit(_selectedStatus!);
                    }
                  : null,
              child: const Text('ثبت و ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(30, (i) {
          final baseHeight = 10 + (i % 5) * 8.0;
          // Animate bars when playing
          final animatedHeight = _isPlaying
              ? baseHeight *
                    (0.6 +
                        0.4 * ((i + _position.inMilliseconds ~/ 100) % 5) / 5)
              : baseHeight;
          return Container(
            width: 3,
            height: animatedHeight.clamp(8.0, 50.0),
            margin: EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: _isPlaying ? 0.6 : 0.3,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 4,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: _isLoading
                ? null
                : (value) {
                    final newPosition = Duration(
                      milliseconds: (value * _duration.inMilliseconds).round(),
                    );
                    _seekTo(newPosition);
                  },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton({
    required bool isPlaying,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              )
            : Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.textOnPrimary,
                size: 32,
              ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: Icon(
              icon,
              color: onTap != null ? AppColors.primary : AppColors.textHint,
              size: 22,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
