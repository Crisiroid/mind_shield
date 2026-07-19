import 'package:flutter/foundation.dart';

import '../constants/app_strings.dart';
import '../services/dialog_service.dart';
import '../sync/offline_first_repository.dart';
import '../sync/write_result.dart';

mixin SubmissionFlow on ChangeNotifier {
  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  Future<bool> submit<T>({
    required Result<WriteResult<T>> Function() action,
    required void Function(WriteResult<T> outcome) onSuccess,
    String? fallbackSuccessMessage,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    final result = await action();

    _isSubmitting = false;
    notifyListeners();

    return result.fold(
      (failure) async {
        await DialogService.showError(
          title: AppStrings.error,
          message: failure.message,
        );
        return false;
      },
      (outcome) async {
        onSuccess(outcome);
        notifyListeners();
        final message = outcome.message.isNotEmpty
            ? outcome.message
            : (fallbackSuccessMessage ?? AppStrings.dataSaved);
        await DialogService.showSuccess(
          title: AppStrings.success,
          message: message,
        );
        return true;
      },
    );
  }
}
