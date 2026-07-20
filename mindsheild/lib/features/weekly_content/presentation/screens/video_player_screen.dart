import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../home/data/models/weekly_media_model.dart';
import '../view_models/weekly_content_view_model.dart';

/// In-app streaming video player (chewie + video_player). Marks the item
/// in-progress when playback starts and completed when it reaches the end.
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  WeeklyMediaModel? _media;
  bool _initialized = false;
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

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoController = controller;
    controller.addListener(_onVideoTick);

    try {
      await controller.initialize();
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        allowPlaybackSpeedChanging: false,
      );
      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _onVideoTick() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying && !_markedInProgress) {
      _markedInProgress = true;
      final media = _media;
      if (media != null) {
        context.read<WeeklyContentViewModel>().markInProgress(media);
      }
    }

    final position = controller.value.position;
    final duration = controller.value.duration;
    if (!_markedCompleted &&
        duration > Duration.zero &&
        position >= duration - const Duration(milliseconds: 800)) {
      _markedCompleted = true;
      final media = _media;
      if (media != null) {
        context.read<WeeklyContentViewModel>().markCompleted(media);
      }
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoTick);
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          _media?.description ?? 'ویدیو',
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Padding(
        padding: EdgeInsets.all(AppSizes.lg),
        child: Text(
          'پخش این ویدیو ممکن نیست',
          textAlign: TextAlign.center,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            color: Colors.white70,
          ),
        ),
      );
    }

    if (!_initialized || _chewieController == null) {
      return const CircularProgressIndicator(color: AppColors.primary);
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}
