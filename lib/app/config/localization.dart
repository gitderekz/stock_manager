import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('sw'), // Swahili
  ];

  static const LocalizationsDelegate<AppLocalizationsDelegate> localizationsDelegate =
  AppLocalizationsDelegate();



  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizationsDelegate(),
    LocaleNamesLocalizationsDelegate(), // From flutter_localized_locales
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];


  static AppLocalizationsDelegate of(BuildContext context) {
    return Localizations.of<AppLocalizationsDelegate>(
      context,
      AppLocalizationsDelegate,
    )!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizationsDelegate> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.contains(locale);
  }

  @override
  Future<AppLocalizationsDelegate> load(Locale locale) {
    return SynchronousFuture<AppLocalizationsDelegate>(this);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizationsDelegate> old) {
    return false;
  }
}