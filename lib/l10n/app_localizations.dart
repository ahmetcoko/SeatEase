import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  String get settingsMainTitle => _localizedValues[locale.languageCode]!['settingsMainTitle']!;

  String get themTitle => _localizedValues[locale.languageCode]!['themTitle']!;

  String get darkTheme => _localizedValues[locale.languageCode]!['darkTheme']!;

  String get lightTheme => _localizedValues[locale.languageCode]!['lightTheme']!;

  String get language => _localizedValues[locale.languageCode]!['language']!;

  String get userProfileTitle => _localizedValues[locale.languageCode]!['userProfileTitle']!;

  String get infoEvents => _localizedValues[locale.languageCode]!['infoEvents']!;

  String get dateTime => _localizedValues[locale.languageCode]!['dateTime']!;

  String get cancelReservation => _localizedValues[locale.languageCode]!['cancelReservation']!;

  String get description => _localizedValues[locale.languageCode]!['description']!;

  String get seat => _localizedValues[locale.languageCode]!['seat']!;




  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'userSettingsPage': 'User Settings',
      'settingsTitle': 'Settings',
      'settingsMainTitle': 'Settings',
      'themTitle': 'Theme',
      'darkTheme': 'Dark Theme',
      'lightTheme': 'Light Theme',
      'language': 'Language',
      'userProfileTitle': 'User Profile',
      'infoEvents': 'Info Events',
      'dateTime': 'Date Time',
      'cancelReservation': 'Cancel Reservation',
      'description': 'Description',
      'seat': 'Seat',

    },
    'tr': {
      'userSettingsPage': 'Kullanıcı Ayarları',
      'settingsTitle': 'Ayarlar',
      'settingsMainTitle': 'Ayarlar',
      'themTitle': 'Tema',
      'darkTheme': 'Koyu Tema',
      'lightTheme': 'Açık Tema',
      'language': 'Dil',
      'userProfileTitle': 'Profil',
      'infoEvents': 'Bilgi Etkinlikleri',
      'dateTime': 'Tarih Saat',
      'cancelReservation': 'Rezervasyon İptal',
      'description': 'Açıklama',
      'seat': 'Koltuk',
    },
  };

  String get userSettingsPage {
    return _localizedValues[locale.languageCode]!['userSettingsPage']!;
  }

  String get settingsTitle {
    return _localizedValues[locale.languageCode]!['settingsTitle']!;
  }
}
