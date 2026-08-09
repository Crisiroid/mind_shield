import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class SliderFormPage extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String firstSliderLabel;
  final String firstSliderLeftLabel;
  final String firstSliderRightLabel;
  final String secondSliderLabel;
  final String secondSliderLeftLabel;
  final String secondSliderRightLabel;
  final String dropdownLabel;
  final List<String> dropdownOptions;
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final String submitText;

  const SliderFormPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.firstSliderLabel,
    this.firstSliderLeftLabel = '۰',
    this.firstSliderRightLabel = '۱۰',
    required this.secondSliderLabel,
    this.secondSliderLeftLabel = '۰',
    this.secondSliderRightLabel = '۱۰',
    required this.dropdownLabel,
    required this.dropdownOptions,
    required this.onSubmit,
    this.submitText = 'ثبت پاسخ',
  });

  @override
  State<SliderFormPage> createState() => _SliderFormPageState();
}

class _SliderFormPageState extends State<SliderFormPage> {
  double _firstValue = 5;
  double _secondValue = 5;
  String? _selectedOption;

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
          if (widget.subtitle != null) ...[
            SizedBox(height: AppSizes.md),
            Text(
              widget.subtitle!,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                height: 1.7,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: AppSizes.lg),
          // First slider
          _buildSlider(
            label: widget.firstSliderLabel,
            value: _firstValue,
            leftLabel: widget.firstSliderLeftLabel,
            rightLabel: widget.firstSliderRightLabel,
            onChanged: (v) => setState(() => _firstValue = v),
          ),
          SizedBox(height: AppSizes.lg),
          // Second slider
          _buildSlider(
            label: widget.secondSliderLabel,
            value: _secondValue,
            leftLabel: widget.secondSliderLeftLabel,
            rightLabel: widget.secondSliderRightLabel,
            onChanged: (v) => setState(() => _secondValue = v),
          ),
          SizedBox(height: AppSizes.lg),
          // Dropdown selection
          Text(
            widget.dropdownLabel,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ...widget.dropdownOptions.map((option) {
            final isSelected = _selectedOption == option;
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.sm),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: () => setState(() => _selectedOption = option),
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
                          groupValue: _selectedOption,
                          onChanged: (v) => setState(() => _selectedOption = v),
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
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedOption != null
                  ? () => widget.onSubmit({
                      'first_slider': _firstValue.toInt(),
                      'second_slider': _secondValue.toInt(),
                      'selected_option': _selectedOption!,
                    })
                  : null,
              child: Text(widget.submitText),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required String leftLabel,
    required String rightLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PersianFonts.Vazir.copyWith(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.sm),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            label: value.toInt().toString(),
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftLabel,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value.toInt().toString(),
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              rightLabel,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontXs,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
