import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class StressSliderPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String leftLabel;
  final String rightLabel;
  final int? initialValue;
  final ValueChanged<int> onSubmit;
  final String submitText;
  final String? skipText;
  final VoidCallback? onSkip;

  const StressSliderPage({
    super.key,
    required this.title,
    required this.subtitle,
    this.leftLabel = 'بدون استرس',
    this.rightLabel = 'بیشترین استرس',
    this.initialValue,
    required this.onSubmit,
    this.submitText = 'ثبت و ادامه',
    this.skipText,
    this.onSkip,
  });

  @override
  State<StressSliderPage> createState() => _StressSliderPageState();
}

class _StressSliderPageState extends State<StressSliderPage> {
  late double _value;
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    _value = (widget.initialValue ?? 5).toDouble();
    _hasValue = widget.initialValue != null;
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
            widget.subtitle,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              trackHeight: 6,
            ),
            child: Slider(
              value: _value,
              min: 0,
              max: 10,
              divisions: 10,
              label: _value.toInt().toString(),
              onChanged: (v) {
                setState(() {
                  _value = v;
                  _hasValue = true;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.leftLabel,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _value.toInt().toString(),
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                widget.rightLabel,
                style: PersianFonts.Vazir.copyWith(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _hasValue
                  ? () => widget.onSubmit(_value.toInt())
                  : null,
              child: Text(widget.submitText),
            ),
          ),
          if (widget.skipText != null) ...[
            SizedBox(height: AppSizes.sm),
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
        ],
      ),
    );
  }
}
