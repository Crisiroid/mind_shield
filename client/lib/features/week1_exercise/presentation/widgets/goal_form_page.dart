import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class GoalFormPage extends StatefulWidget {
  final ValueChanged<Map<String, String>> onSubmit;
  final String? skipText;
  final VoidCallback? onSkip;

  const GoalFormPage({
    super.key,
    required this.onSubmit,
    this.skipText,
    this.onSkip,
  });

  @override
  State<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends State<GoalFormPage> {
  String? _selectedCategory;
  final _goalTextCtrl = TextEditingController();
  bool _submitted = false;

  final _categories = [
    'شناخت بهتر استرس',
    'مدیریت نگرانی',
    'کاهش افکار منفی',
    'مدیریت بهتر هیجان\u200cها',
    'بهترشدن خلق',
    'افزایش انرژی و فعالیت',
    'واکنش سنجیده\u200cتر در موقعیت\u200cهای دشوار',
    'حل بهتر مشکلات',
    'موضوع دیگر',
  ];

  @override
  void dispose() {
    _goalTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return SingleChildScrollView(
        padding: AppSizes.paddingScreen,
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 64,
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              'هدف اولیه شما ثبت شد. می\u200cتوانید بعداً آن را از بخش «ثبت\u200cهای من» مرور یا ویرایش کنید.',
              textAlign: TextAlign.center,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontMd,
                height: 1.8,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onSubmit({
                  'goal_category': _selectedCategory ?? '',
                  'goal_text': _goalTextCtrl.text,
                }),
                child: const Text('ادامه'),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: AppSizes.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هدف شخصی من',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'انتخاب یک هدف روشن کمک می\u200cکند تغییرات خود را در طول برنامه بهتر مشاهده کنید.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            'بیشتر دوست دارید روی کدام موضوع کار کنید؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ..._categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: AppSizes.sm),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  onTap: () => setState(() => _selectedCategory = cat),
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
                    child: Text(
                      cat,
                      style: PersianFonts.Vazir.copyWith(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: AppSizes.lg),
          Text(
            'دوست دارید در پایان هشت هفته چه تغییر قابل مشاهده\u200cای ایجاد شود؟',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          TextField(
            controller: _goalTextCtrl,
            maxLength: 200,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'تغییر مورد انتظار خود را بنویسید.',
              hintStyle: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'مثال: پس از یک موقعیت دشوار، زمان کمتری درگیر تنش بمانم.',
            style: PersianFonts.Vazir.copyWith(
              fontSize: AppSizes.fontXs,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedCategory != null
                  ? () => setState(() => _submitted = true)
                  : null,
              child: const Text('ثبت هدف'),
            ),
          ),
          if (widget.skipText != null) ...[
            SizedBox(height: AppSizes.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _selectedCategory != null
                    ? () {
                        widget.onSubmit({
                          'goal_category': _selectedCategory!,
                          'goal_text': '',
                        });
                      }
                    : null,
                child: Text(widget.skipText!),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}
