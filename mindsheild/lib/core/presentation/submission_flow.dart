import 'package:flutter/foundation.dart';

import '../constants/app_strings.dart';
import '../services/dialog_service.dart';
import '../sync/offline_first_repository.dart';
import '../sync/write_result.dart';

/// Standardizes the post-write flow shared by every feature view model.
///
/// After a create/update the app must always: show a dialog carrying the
/// server's own message, make the confirmed record appear immediately, and
/// clear the form. Centralizing this here keeps the twelve feature view models
/// thin and consistent (DRY) while each view model keeps ownership of its own
/// list/form state via the [onSuccess] callback (Single Responsibility).
mixin SubmissionFlow on ChangeNotifier {
  bool _isSubmitting = false;

  /// Whether a write is currently in flight (bind buttons/spinners to this).
  bool get isSubmitting => _isSubmitting;

  /// Run an offline-first write and apply the standard post-write flow.
  ///
  /// [action] performs the create/update and yields a [WriteResult].
  /// [onSuccess] lets the view model reflect the confirmed record in its own
  /// state (e.g. prepend it to the list and reset the form) — it is invoked
  /// before [notifyListeners] so the UI updates in a single frame.
  /// On success a dialog shows [WriteResult.message] (or [fallbackSuccessMessage]
  /// when the server sent none); on failure the server-derived error message.
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
