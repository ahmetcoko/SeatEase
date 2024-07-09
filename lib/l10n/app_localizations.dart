import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'userSettingsPage': 'User Settings',
      'settingsTitle': 'Settings',
    },
    'tr': {
      'userSettingsPage': 'Kullanıcı Ayarları',
      'settingsTitle': 'Ayarlar',
    },
  };

  String get userSettingsPage {
    return _localizedValues[locale.languageCode]!['userSettingsPage']!;
  }

  String get settingsTitle {
    return _localizedValues[locale.languageCode]!['settingsTitle']!;
  }
}
