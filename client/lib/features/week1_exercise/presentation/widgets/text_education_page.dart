import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class InfoCard {
  final String title;
  final String text;
  const InfoCard({required this.title, required this.text});
}

class TextEducationPage extends StatelessWidget {
  final String title;
  final String? bodyText;
  final String? noteText;
  final String? noteTitle;
  final String? helpTitle;
  final String? helpText;
  final String? bottomText;
  final String primaryButtonText;
  final VoidCallback onPrimaryButton;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButton;
  final List<InfoCard>? cards;
  final Widget? imageWidget;
  final bool showCheckbox;
  final String? checkboxText;
  final bool checkboxValue;
  final ValueChanged<bool>? onCheckboxChanged;
  final List<Widget>? customChildren;

  const TextEducationPage({
    super.key,
    required this.title,
    this.bodyText,
    this.noteText,
    this.noteTitle,
    this.helpTitle,
    this.helpText,
    this.bottomText,
    required this.primaryButtonText,
    required this.onPrimaryButton,
    this.secondaryButtonText,
    this.onSecondaryButton,
    this.cards,
    this.imageWidget,
    this.showCheckbox = false,
    this.checkboxText,
    this.checkboxValue = false,
    this.onCheckboxChanged,
    this.customChildren,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (bodyText != null) ...[
            SizedBox(height: AppSizes.md),
            Text(
              bodyText!,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                height: 1.8,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          if (imageWidget != null) ...[
            SizedBox(height: AppSizes.lg),
            Center(child: imageWidget!),
          ],
          if (cards != null) ...[
            SizedBox(height: AppSizes.lg),
            ...cards!.map((card) => _buildCard(card)),
          ],
          if (noteText != null) ...[
            SizedBox(height: AppSizes.lg),
            _buildNoteBox(noteTitle ?? 'نکته', noteText!),
          ],
          if (helpTitle != null) ...[
            SizedBox(height: AppSizes.lg),
            _buildHelpBox(helpTitle!, helpText!),
          ],
          if (showCheckbox) ...[
            SizedBox(height: AppSizes.lg),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: checkboxValue,
                    onChanged: onCheckboxChanged != null
                        ? (v) => onCheckboxChanged!(v ?? false)
                        : null,
                    activeColor: AppColors.primary,
                  ),
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    checkboxText ?? '',
                    style: PersianFonts.Vazir.copyWith(
                      fontSize: AppSizes.fontMd,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (bottomText != null) ...[
            SizedBox(height: AppSizes.lg),
            Text(
              bottomText!,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (customChildren != null) ...customChildren!,
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: showCheckbox && !checkboxValue
                  ? null
                  : onPrimaryButton,
              child: Text(primaryButtonText),
            ),
          ),
          if (secondaryButtonText != null) ...[
            SizedBox(height: AppSizes.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onSecondaryButton,
                child: Text(
                  secondaryButtonText!,
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

  Widget _buildCard(InfoCard card) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSizes.md),
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            card.text,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteBox(String title, String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            text,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpBox(String title, String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            text,
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontSm,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
