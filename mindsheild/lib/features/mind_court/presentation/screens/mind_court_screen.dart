import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../view_models/mind_court_view_model.dart';

class MindCourtScreen extends StatefulWidget {
  const MindCourtScreen({super.key});

  @override
  State<MindCourtScreen> createState() => _MindCourtScreenState();
}

class _MindCourtScreenState extends State<MindCourtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _supportingController = TextEditingController();
  final TextEditingController _contradictingController =
      TextEditingController();
  final TextEditingController _alternativeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MindCourtViewModel>().init();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _supportingController.dispose();
    _contradictingController.dispose();
    _alternativeController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(MindCourtViewModel vm) async {
    final success = await vm.submitVerdict();
    if (success) {
      _supportingController.clear();
      _contradictingController.clear();
      _alternativeController.clear();
      _tabController.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MindCourtViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.mindCourtTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.mindCourtBalanceTab),
            Tab(text: AppStrings.mindCourtAlternativeTab),
          ],
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : !vm.hasThoughts
          ? const _EmptyThoughtsState()
          : TabBarView(
              controller: _tabController,
              children: [
                _BalanceTab(
                  vm: vm,
                  supportingController: _supportingController,
                  contradictingController: _contradictingController,
                ),
                _AlternativeTab(
                  vm: vm,
                  alternativeController: _alternativeController,
                  onSubmit: () => _onSubmit(vm),
                ),
              ],
            ),
    );
  }
}

class _EmptyThoughtsState extends StatelessWidget {
  const _EmptyThoughtsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSizes.paddingScreen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gavel_outlined,
              size: AppSizes.iconXl,
              color: AppColors.textHint,
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              AppStrings.noThoughtsToTrial,
              textAlign: TextAlign.center,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSizes.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushReplacementNamed('/negative-thought-radar'),
                child: Text(
                  AppStrings.goToRadar,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceTab extends StatelessWidget {
  final MindCourtViewModel vm;
  final TextEditingController supportingController;
  final TextEditingController contradictingController;

  const _BalanceTab({
    required this.vm,
    required this.supportingController,
    required this.contradictingController,
  });

  void _showGuideHelper(BuildContext context) {
    vm.markGuideHelperUsed();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.warning),
            SizedBox(width: AppSizes.sm),
            const Text(AppStrings.guideHelper),
          ],
        ),
        content: Text(
          AppStrings.guideHelperExamples,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondary,
            height: 1.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.mindCourtSubtitle,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            AppStrings.selectThoughtOnTrial,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          DropdownButtonFormField<String>(
            value: vm.selectedThoughtId,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: AppStrings.selectThoughtHint,
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textHint,
              ),
              prefixIcon: const Icon(
                Icons.psychology_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            items: vm.thoughts.map((thought) {
              return DropdownMenuItem<String>(
                value: thought.id,
                child: Text(
                  thought.thoughtText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PersianFonts.Vazir.copyWith(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: vm.setSelectedThoughtId,
          ),
          SizedBox(height: AppSizes.lg),

          const _ScaleVisual(),
          SizedBox(height: AppSizes.lg),

          _EvidenceField(
            label: AppStrings.supportingEvidenceLabel,
            hint: AppStrings.supportingEvidenceHint,
            icon: Icons.thumb_up_outlined,
            accent: AppColors.error,
            controller: supportingController,
            onChanged: vm.setSupportingEvidence,
          ),
          SizedBox(height: AppSizes.lg),

          _EvidenceField(
            label: AppStrings.contradictingEvidenceLabel,
            hint: AppStrings.contradictingEvidenceHint,
            icon: Icons.thumb_down_outlined,
            accent: AppColors.success,
            controller: contradictingController,
            onChanged: vm.setContradictingEvidence,
          ),
          SizedBox(height: AppSizes.lg),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showGuideHelper(context),
              icon: Icon(
                vm.guideHelperUsed
                    ? Icons.check_circle_outline
                    : Icons.lightbulb_outline,
                color: AppColors.warning,
              ),
              label: Text(
                AppStrings.guideHelper,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleVisual extends StatelessWidget {
  const _ScaleVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          Icon(Icons.balance, size: AppSizes.iconXl, color: AppColors.primary),
          SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ScalePanLabel(
                text: AppStrings.supportingEvidenceLabel,
                color: AppColors.error,
              ),
              _ScalePanLabel(
                text: AppStrings.contradictingEvidenceLabel,
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScalePanLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _ScalePanLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: AppSizes.iconSm * 0.5, color: color),
        SizedBox(width: AppSizes.xs),
        Text(
          text,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontSm,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _EvidenceField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Color accent;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _EvidenceField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.accent,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: AppSizes.iconSm, color: accent),
            SizedBox(width: AppSizes.sm),
            Text(
              label,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.sm),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              color: AppColors.textHint,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _AlternativeTab extends StatelessWidget {
  final MindCourtViewModel vm;
  final TextEditingController alternativeController;
  final VoidCallback onSubmit;

  const _AlternativeTab({
    required this.vm,
    required this.alternativeController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppSizes.paddingScreen,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.route_outlined, color: AppColors.primary),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    AppStrings.alternativeThoughtDesc,
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      color: AppColors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.lg),

          Text(
            AppStrings.alternativeThoughtLabel,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          TextField(
            controller: alternativeController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: AppStrings.alternativeThoughtHint,
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textHint,
              ),
              prefixIcon: const Icon(
                Icons.lightbulb_outline,
                color: AppColors.textSecondary,
              ),
            ),
            onChanged: vm.setAlternativeThought,
          ),
          SizedBox(height: AppSizes.xl),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.isSaving ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.textHint,
              ),
              child: vm.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      AppStrings.submitVerdict,
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
}
