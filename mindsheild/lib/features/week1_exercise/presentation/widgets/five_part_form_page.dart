import 'package:flutter/material.dart';
import 'package:persian_fonts/persian_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class FivePartFormPage extends StatefulWidget {
  final String title;
  final String? guideText;
  final ValueChanged<Map<String, String>> onSubmit;
  final String submitText;
  final String? skipText;
  final VoidCallback? onSkip;

  const FivePartFormPage({
    super.key,
    required this.title,
    this.guideText,
    required this.onSubmit,
    this.submitText = 'ثبت تمرین',
    this.skipText,
    this.onSkip,
  });

  @override
  State<FivePartFormPage> createState() => _FivePartFormPageState();
}

class _FivePartFormPageState extends State<FivePartFormPage> {
  final _situationCtrl = TextEditingController();
  final _thoughtCtrl = TextEditingController();
  final _behaviorCtrl = TextEditingController();
  String? _emotion;
  String? _bodySign;

  final _emotions = [
    'اضطراب',
    'نگرانی',
    'خشم',
    'ناراحتی',
    'شرم',
    'ناامیدی',
    'ترس',
    'احساس گناه',
    'سردرگمی',
    'احساس دیگر',
  ];

  final _bodySigns = [
    'تنش عضلات',
    'تپش قلب',
    'تغییر تنفس',
    'سردرد',
    'ناراحتی معده',
    'لرزش',
    'گرما یا تعریق',
    'خستگی',
    'نشانه دیگر',
    'نشانه مشخصی نداشتم',
  ];

  @override
  void dispose() {
    _situationCtrl.dispose();
    _thoughtCtrl.dispose();
    _behaviorCtrl.dispose();
    super.dispose();
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
          if (widget.guideText != null) ...[
            SizedBox(height: AppSizes.md),
            Text(
              widget.guideText!,
              style: PersianFonts.Vazir.copyWith(
                fontSize: AppSizes.fontSm,
                height: 1.7,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: AppSizes.lg),
          _buildLabel('موقعیت: چه اتفاقی افتاد؟'),
          _buildTextField(_situationCtrl, 'فقط اتفاق قابل مشاهده را بنویسید.'),
          SizedBox(height: AppSizes.md),
          _buildLabel('فکر: چه فکری از ذهن شما گذشت؟'),
          _buildTextField(_thoughtCtrl, ''),
          SizedBox(height: AppSizes.md),
          _buildLabel('هیجان: چه احساسی داشتید؟'),
          _buildDropdown(
            _emotion,
            _emotions,
            (v) => setState(() => _emotion = v),
          ),
          SizedBox(height: AppSizes.md),
          _buildLabel('نشانه بدنی اصلی چه بود؟'),
          _buildDropdown(
            _bodySign,
            _bodySigns,
            (v) => setState(() => _bodySign = v),
          ),
          SizedBox(height: AppSizes.md),
          _buildLabel('رفتار: چه کاری انجام دادید یا از چه کاری اجتناب کردید؟'),
          _buildTextField(
            _behaviorCtrl,
            'برای مثال: سکوت کردم، کار را به تعویق انداختم.',
          ),
          SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit() ? _submit : null,
              child: Text(widget.submitText),
            ),
          ),
          if (widget.skipText != null) ...[
            SizedBox(height: AppSizes.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: widget.onSkip,
                child: Text(widget.skipText!),
              ),
            ),
          ],
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.xs),
      child: Text(
        text,
        style: PersianFonts.Vazir.copyWith(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      maxLength: 200,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: PersianFonts.Vazir.copyWith(
          fontSize: AppSizes.fontSm,
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: PersianFonts.Vazir.copyWith(fontSize: AppSizes.fontSm),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  bool _canSubmit() {
    return _situationCtrl.text.isNotEmpty &&
        _thoughtCtrl.text.isNotEmpty &&
        _emotion != null &&
        _bodySign != null &&
        _behaviorCtrl.text.isNotEmpty;
  }

  void _submit() {
    widget.onSubmit({
      'situation': _situationCtrl.text,
      'thought': _thoughtCtrl.text,
      'emotion': _emotion ?? '',
      'body_sign': _bodySign ?? '',
      'behavior': _behaviorCtrl.text,
    });
  }
}
