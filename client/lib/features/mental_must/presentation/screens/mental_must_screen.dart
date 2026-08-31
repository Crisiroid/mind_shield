import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../view_models/mental_must_view_model.dart';

class MentalMustScreen extends StatefulWidget {
  const MentalMustScreen({super.key});

  @override
  State<MentalMustScreen> createState() => _MentalMustScreenState();
}

class _MentalMustScreenState extends State<MentalMustScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MentalMustViewModel>().init();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MentalMustViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.mentalMustTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.backpackStones),
            Tab(text: AppStrings.releasedStones),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBackpackTab(vm), _buildReleasedTab(vm)],
      ),
    );
  }

  Widget _buildBackpackTab(MentalMustViewModel vm) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.backpack_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
                SizedBox(height: AppSizes.sm),
                Text(
                  AppStrings.mentalMustSubtitle,
                  textAlign: TextAlign.center,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                Text(
                  AppStrings.mentalMustBackpackDesc,
                  textAlign: TextAlign.center,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            AppStrings.addMentalMust,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          TextField(
            maxLines: 2,
            decoration: InputDecoration(
              hintText: AppStrings.mentalMustInputHint,
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textHint,
              ),
              prefixIcon: const Icon(
                Icons.edit_note,
                color: AppColors.textSecondary,
              ),
              suffixIcon: vm.isSaving
                  ? Padding(
                      padding: EdgeInsets.all(AppSizes.md),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.primary,
                      ),
                      onPressed: () => vm.submitMust(),
                    ),
            ),
            onChanged: vm.setMustText,
            controller: TextEditingController(text: vm.mustText),
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            '${AppStrings.activeMusts} (${vm.activeMusts.length})',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),

          if (vm.isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else if (vm.activeMusts.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.backpack_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: AppSizes.md),
                  Text(
                    AppStrings.noMustsYet,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...vm.activeMusts.map(
              (must) => _MustStone(
                must: must,
                onRelease: () => vm.releaseMust(must.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReleasedTab(MentalMustViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final released = vm.releasedMusts;

    if (released.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.free_breakfast, size: 64, color: AppColors.textHint),
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
      itemCount: released.length,
      itemBuilder: (context, index) {
        final must = released[index];
        return _ReleasedMustCard(must: must);
      },
    );
  }
}

class _MustStone extends StatelessWidget {
  final dynamic must;
  final VoidCallback onRelease;

  const _MustStone({required this.must, required this.onRelease});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.md),
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(Icons.grain, color: AppColors.warning, size: 28),
          ),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  must.mustText as String,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  'روز ${must.dayNumber ?? '-'}',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRelease,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.success.withValues(alpha: 0.1),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
            ),
            child: Text(
              AppStrings.releaseMust,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReleasedMustCard extends StatelessWidget {
  final dynamic must;

  const _ReleasedMustCard({required this.must});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.md),
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.success, size: 28),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  must.mustText as String,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  'رها شده',
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
