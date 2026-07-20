import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../home/data/models/weekly_media_model.dart';
import '../view_models/weekly_content_view_model.dart';

/// In-app audio player (just_audio) with play/pause and seek. Marks the item
/// in-progress on first play and completed when playback finishes.
class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  WeeklyMediaModel? _media;
  bool _hasError = false;
  bool _markedInProgress = false;
  bool _markedCompleted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_media != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is WeeklyMediaModel) {
      _media = args;
      _setup();
    }
  }

  Future<void> _setup() async {
    final url = _media?.fileUrl;
    if (url == null || url.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    _player.playerStateStream.listen((state) {
      if (state.playing && !_markedInProgress) {
        _markedInProgress = true;
        final media = _media;
        if (media != null) {
          context.read<WeeklyContentViewModel>().markInProgress(media);
        }
      }
      if (state.processingState == ProcessingState.completed &&
          !_markedCompleted) {
        _markedCompleted = true;
        final media = _media;
        if (media != null) {
          context.read<WeeklyContentViewModel>().markCompleted(media);
        }
      }
    });

    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _media?.description ?? 'پخش صوت',
          style: PersianFonts.Vazir.copyWith(fontSize: AppSizes.fontMd),
        ),
      ),
      body: _hasError
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.lg),
                child: Text(
                  'پخش این فایل صوتی ممکن نیست',
                  textAlign: TextAlign.center,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          : _buildPlayer(),
    );
  }

  Widget _buildPlayer() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.music_note,
              size: 72,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.xl),
          if (_media?.description != null)
            Text(
              _media!.description!,
              textAlign: TextAlign.center,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          SizedBox(height: AppSizes.xl),
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, positionSnapshot) {
              final position = positionSnapshot.data ?? Duration.zero;
              final total = _player.duration ?? Duration.zero;
              final maxMs = total.inMilliseconds.toDouble();
              final valueMs = position.inMilliseconds
                  .clamp(0, total.inMilliseconds)
                  .toDouble();
              return Column(
                children: [
                  Slider(
                    value: maxMs == 0 ? 0 : valueMs,
                    max: maxMs == 0 ? 1 : maxMs,
                    activeColor: AppColors.primary,
                    onChanged: maxMs == 0
                        ? null
                        : (v) =>
                              _player.seek(Duration(milliseconds: v.toInt())),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _format(position),
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontSm,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _format(total),
                        style: PersianFonts.Vazir.copyWith(
                          fontSize: AppSizes.fontSm,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: AppSizes.lg),
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              final processing = snapshot.data?.processingState;
              final isLoading =
                  processing == ProcessingState.loading ||
                  processing == ProcessingState.buffering;
              return IconButton(
                iconSize: 64,
                color: AppColors.primary,
                icon: isLoading
                    ? const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        playing
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
                onPressed: isLoading
                    ? null
                    : () => playing ? _player.pause() : _player.play(),
              );
            },
          ),
        ],
      ),
    );
  }
}
