import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class WeekEvaluationPage extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final VoidCallback? onHelpNeeded;

  const WeekEvaluationPage({
    super.key,
    required this.onSubmit,
    this.onHelpNeeded,
  });

  @override
  State<WeekEvaluationPage> createState() => _WeekEvaluationPageState();
}

class _WeekEvaluationPageState extends State<WeekEvaluationPage> {
  double _clarityScore = 5;
  double _usefulnessScore = 5;
  String? _durationRating;
  String? _significantDistress;
  bool _showDistressMessage = false;

  final _durationOptions = ['کوتاه', 'مناسب', 'طولانی'];
  final _distressOptions = ['خیر', 'بله', 'ترجیح می\u200cدهم پاسخ ندهم'];

  bool get _canSubmit =>
      _durationRating != null && _significantDistress != null;

  void _submit() {
    widget.onSubmit({
      'clarity_score': _clarityScore.toInt(),
      'usefulness_score': _usefulnessScore.toInt(),
      'duration_rating': _durationRating,
      'significant_distress': _significantDistress,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ارزیابی هفته',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q1: Clarity slider
          Text(
            'محتوای این هفته چقدر قابل فهم بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          _buildSlider(_clarityScore, (v) => setState(() => _clarityScore = v)),
          SizedBox(height: AppSizes.lg),
          // Q2: Usefulness slider
          Text(
            'تمرین\u200cهای این هفته چقدر برای شما مفید بودند؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          _buildSlider(
            _usefulnessScore,
            (v) => setState(() => _usefulnessScore = v),
          ),
          SizedBox(height: AppSizes.lg),
          // Q3: Duration rating
          Text(
            'مدت تمرین\u200cها چگونه بود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._durationOptions.map(
            (opt) => _buildRadioTile(
              opt,
              _durationRating,
              (v) => setState(() => _durationRating = v),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          // Q4: Significant distress
          Text(
            'آیا هیچ\u200cیک از تمرین\u200cهای این هفته باعث ناراحتی قابل توجه شد؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._distressOptions.map(
            (opt) => _buildRadioTile(opt, _significantDistress, (v) {
              setState(() {
                _significantDistress = v;
                _showDistressMessage = v == 'بله';
              });
            }),
          ),
          // Distress message
          if (_showDistressMessage) ...[
            SizedBox(height: AppSizes.md),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ادامه\u200cدادن هیچ تمرینی الزامی نیست. در صورت نیاز می\u200cتوانید از بخش «راهنما و کمک» استفاده کنید.',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontSm,
                      height: 1.7,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSizes.sm),
                  if (widget.onHelpNeeded != null)
                    TextButton(
                      onPressed: widget.onHelpNeeded,
                      child: Text(
                        'مشاهده راهنما و کمک',
                        style: PersianFonts.Vazir.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit ? () => _submit() : null,
              child: const Text('ثبت ارزیابی'),
            ),
          ),
          if (_showDistressMessage) ...[
            SizedBox(height: AppSizes.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _submit(),
                child: Text(
                  'ادامه',
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

  Widget _buildSlider(double value, ValueChanged<double> onChanged) {
    return Column(
      children: [
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
              '۰',
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
              '۱۰',
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

  Widget _buildRadioTile(
    String value,
    String? groupValue,
    ValueChanged<String?> onChanged,
  ) {
    final isSelected = groupValue == value;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSizes.sm),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: value,
                  groupValue: groupValue,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    value,
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
  }
}
