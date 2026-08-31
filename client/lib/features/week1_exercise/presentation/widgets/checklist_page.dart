import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class ChecklistPage extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String> items;
  final int maxSelections;
  final ValueChanged<List<String>> onSubmit;
  final String submitText;

  const ChecklistPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
    this.maxSelections = 2,
    required this.onSubmit,
    this.submitText = 'ثبت انتخاب\u200cها',
  });

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final Set<String> _selected = {};

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
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: AppSizes.lg),
          ...widget.items.map((item) {
            final isSelected = _selected.contains(item);
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.sm),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selected.remove(item);
                      } else if (_selected.length < widget.maxSelections) {
                        _selected.add(item);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Container(
                    padding: EdgeInsets.all(AppSizes.md),
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
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: null,
                            activeColor: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            item,
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
              onPressed: _selected.isNotEmpty
                  ? () => widget.onSubmit(_selected.toList())
                  : null,
              child: Text(widget.submitText),
            ),
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}
