import 'package:downtown_merchant_app/service/app_localizations.dart';
import 'package:flutter/cupertino.dart';

class ErrorService {
  static List<String> translate(BuildContext context, List errors) {
    final localizations = AppLocalizations.of(context);
    print(errors);
    List<String> stringErrors = errors
        .map((errorMap) =>
            localizations.translate(errorMap['code']) ??
            errorMap['detail']?.toString())
        .toList();

    return stringErrors;
  }
}
