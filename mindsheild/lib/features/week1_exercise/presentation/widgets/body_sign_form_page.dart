import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class BodySignFormPage extends StatefulWidget {
  final ValueChanged<Map<String, String>> onSubmit;

  const BodySignFormPage({super.key, required this.onSubmit});

  @override
  State<BodySignFormPage> createState() => _BodySignFormPageState();
}

class _BodySignFormPageState extends State<BodySignFormPage> {
  String? _bodyArea;
  String? _sensation;

  final _areas = [
    'سر',
    'فک و صورت',
    'گردن و شانه',
    'قفسه سینه',
    'شکم',
    'دست\u200cها',
    'پاها',
    'کل بدن',
    'ناحیه دیگر',
    'نشانه مشخصی ندارم',
  ];

  final _sensations = [
    'فشار',
    'انقباض',
    'درد',
    'سنگینی',
    'گرما',
    'لرزش',
    'بی\u200cحسی',
    'احساس دیگر',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هنگام استرس، بیشتر کدام قسمت بدن را متوجه می\u200cشوید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._areas.map(
            (area) => _buildRadioTile(area, _bodyArea, (v) {
              setState(() => _bodyArea = v);
              if (v == 'نشانه مشخصی ندارم') _sensation = null;
            }),
          ),
          if (_bodyArea != null && _bodyArea != 'نشانه مشخصی ندارم') ...[
            SizedBox(height: AppSizes.lg),
            Text(
              'احساس اصلی چیست؟',
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            ..._sensations.map(
              (s) => _buildRadioTile(
                s,
                _sensation,
                (v) => setState(() => _sensation = v),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _bodyArea != null
                  ? () => widget.onSubmit({
                      'body_area': _bodyArea ?? '',
                      'body_sensation': _sensation ?? '',
                    })
                  : null,
              child: const Text('ثبت و ادامه'),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
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
