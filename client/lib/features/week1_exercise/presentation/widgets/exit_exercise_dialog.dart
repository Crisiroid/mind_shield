import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class ExitExerciseDialog extends StatelessWidget {
  const ExitExerciseDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const ExitExerciseDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Text(
        'خروج از تمرین',
        style: PersianFonts.Vazir.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Text(
        'تمرین هنوز کامل نشده است. آیا می\u200cخواهید از آن خارج شوید؟',
        style: PersianFonts.Vazir.copyWith(height: 1.7),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'ادامه تمرین',
            style: PersianFonts.Vazir.copyWith(color: AppColors.primary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'خروج',
            style: PersianFonts.Vazir.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}
