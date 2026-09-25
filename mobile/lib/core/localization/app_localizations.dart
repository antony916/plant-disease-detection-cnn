import 'package:flutter/widgets.dart';

/// Localization boundary for PlantCare AI.
///
/// Keep user-facing copy behind this boundary so additional languages can be
/// added without changing feature code. The first production release should
/// ship with a reviewed translation set rather than machine-generated strings.
class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
    Locale('hi'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    if (result == null) {
      throw FlutterError('AppLocalizations not found in widget tree.');
    }
    return result;
  }

  String get appName => 'PlantCare AI';
  String get garden => 'Garden';
  String get scan => 'Scan';
  String get library => 'Library';
  String get ai => 'AI';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
