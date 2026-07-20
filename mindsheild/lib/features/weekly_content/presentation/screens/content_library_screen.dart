import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../home/data/models/weekly_media_model.dart';
import '../view_models/weekly_content_view_model.dart';

/// Content library: weeks 1..8 as expandable sections. Locked weeks show a
/// lock; unlocked items show a type icon, description, and a watched/▶ badge.
/// Tapping an item routes to the correct in-app player by `file_type`.
class ContentLibraryScreen extends StatefulWidget {
  const ContentLibraryScreen({super.key});

  @override
  State<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends State<ContentLibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeeklyContentViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeeklyContentViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('کتابخانه محتوا')),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => vm.refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSizes.paddingScreen,
                children: [
                  _buildSummary(vm),
                  SizedBox(height: AppSizes.lg),
                  for (
                    var week = 1;
                    week <= WeeklyContentViewModel.totalWeeks;
                    week++
                  )
                    _buildWeekSection(context, vm, week),
                ],
              ),
            ),
    );
  }

  Widget _buildSummary(WeeklyContentViewModel vm) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        children: [
          _summaryStat('${vm.watchedCount}', 'دیده‌شده'),
          Container(
            width: 1,
            height: 36,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          _summaryStat('${vm.toWatchCount}', 'باقی‌مانده'),
        ],
      ),
    );
  }

  Widget _summaryStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            label,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSection(
    BuildContext context,
    WeeklyContentViewModel vm,
    int week,
  ) {
    final unlocked = vm.isWeekUnlocked(week);
    final items = vm.contentForWeek(week);

    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: unlocked && week == vm.currentWeek,
          leading: Icon(
            unlocked ? Icons.folder_open : Icons.lock_outline,
            color: unlocked ? AppColors.primary : AppColors.textHint,
          ),
          title: Text(
            'هفته $week',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.bold,
              color: unlocked ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
          subtitle: Text(
            unlocked ? '${items.length} مورد' : 'قفل شده',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              color: AppColors.textSecondary,
            ),
          ),
          children: unlocked
              ? (items.isEmpty
                    ? [
                        Padding(
                          padding: EdgeInsets.all(AppSizes.md),
                          child: Text(
                            'محتوایی برای این هفته منتشر نشده است',
                            style: PersianFonts.Vazir.copyWith(
                              fontSize: AppSizes.fontSm,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ]
                    : items
                          .map((media) => _buildItemTile(context, vm, media))
                          .toList())
              : const [],
        ),
      ),
    );
  }

  Widget _buildItemTile(
    BuildContext context,
    WeeklyContentViewModel vm,
    WeeklyMediaModel media,
  ) {
    final watched = vm.isWatched(media.id);
    final inProgress = vm.progressFor(media.id)?.isInProgress ?? false;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _typeColor(media.fileType).withValues(alpha: 0.12),
        child: Icon(
          _typeIcon(media.fileType),
          color: _typeColor(media.fileType),
        ),
      ),
      title: Text(
        media.description?.isNotEmpty == true
            ? media.description!
            : _typeLabel(media.fileType),
        style: PersianFonts.Vazir.copyWith(
          fontSize: AppSizes.fontMd,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        _typeLabel(media.fileType),
        style: PersianFonts.Vazir.copyWith(
          fontSize: AppSizes.fontSm,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: watched
          ? const Icon(Icons.check_circle, color: AppColors.success)
          : Icon(
              inProgress ? Icons.play_circle_outline : Icons.play_arrow,
              color: AppColors.primary,
            ),
      onTap: () => _open(context, vm, media),
    );
  }

  void _open(
    BuildContext context,
    WeeklyContentViewModel vm,
    WeeklyMediaModel media,
  ) {
    switch (media.fileType) {
      case 'video':
        Navigator.of(context).pushNamed('/content-video', arguments: media);
        break;
      case 'audio':
        Navigator.of(context).pushNamed('/content-audio', arguments: media);
        break;
      case 'image':
        vm.markCompleted(media);
        _showImage(context, media);
        break;
      default:
        vm.markInProgress(media);
        _showDocumentInfo(context, media);
        break;
    }
  }

  void _showImage(BuildContext context, WeeklyMediaModel media) {
    final url = media.fileUrl;
    if (url == null) return;
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(AppSizes.md),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Padding(
                    padding: EdgeInsets.all(AppSizes.lg),
                    child: Text(
                      'تصویر بارگذاری نشد',
                      style: PersianFonts.Vazir.copyWith(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentInfo(BuildContext context, WeeklyMediaModel media) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'این سند برای مطالعه در دسترس است',
          style: PersianFonts.Vazir.copyWith(fontSize: AppSizes.fontSm),
        ),
      ),
    );
  }

  IconData _typeIcon(String fileType) {
    switch (fileType) {
      case 'video':
        return Icons.play_circle_outline;
      case 'audio':
        return Icons.headphones;
      case 'image':
        return Icons.image_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  Color _typeColor(String fileType) {
    switch (fileType) {
      case 'video':
        return AppColors.secondary;
      case 'audio':
        return AppColors.info;
      case 'image':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  String _typeLabel(String fileType) {
    switch (fileType) {
      case 'video':
        return 'ویدیو';
      case 'audio':
        return 'صوت';
      case 'image':
        return 'تصویر';
      default:
        return 'سند';
    }
  }
}
