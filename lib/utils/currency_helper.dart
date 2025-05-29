import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:stock_manager/controllers/settings_controller.dart';

class CurrencyHelper {
  static String formatCurrency(
      BuildContext context,
      double amount, {
        String? currencySymbol,
      }) {
    final locale = Localizations.localeOf(context);
    final localizations = AppLocalizations.of(context);

    final symbol = currencySymbol ?? _getDefaultCurrencySymbol(context);
    final format = NumberFormat.currency(
      locale: locale.toString(),
      symbol: symbol,
      decimalDigits: 2,
    );

    return format.format(amount);
  }

  static String _getDefaultCurrencySymbol(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final settings = context.read<SettingsCubit>().state;

    if (settings is SettingsLoaded) {
      final currency = settings.settings['default_currency'] ?? 'Tsh';
      switch (currency) {
        case '\$':
          return localizations?.currencySymbolUsd ?? '\$';
        case '€':
          return localizations?.currencySymbolEur ?? '€';
        case '£':
          return localizations?.currencySymbolGbp ?? '£';
        default:
          return localizations?.currencySymbolTsh ?? 'Tsh';
      }
    }
    return localizations?.currencySymbolTsh ?? 'Tsh';
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import '../controllers/settings_controller.dart';
//
// class CurrencyHelper {
//   static NumberFormat currencyFormat(BuildContext context) {
//     final settingsState = context.read<SettingsCubit>().state;
//     final currencySymbol = settingsState is SettingsLoaded
//         ? settingsState.settings['default_currency'] ?? 'Tsh'
//         : 'Tsh';
//
//     return NumberFormat.currency(
//       symbol: currencySymbol,
//       decimalDigits: 2,
//     );
//   }
//
//   static String format(BuildContext context, double amount) {
//     return currencyFormat(context).format(amount);
//   }
// }
// // Text(
// // CurrencyHelper.format(context, product.price),
// // style: Theme.of(context).textTheme.bodyLarge,
// // )