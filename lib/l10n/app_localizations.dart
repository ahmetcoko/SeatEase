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

  String get userEventsTitle => _localizedValues[locale.languageCode]!['userEventsTitle']!;

  String get full => _localizedValues[locale.languageCode]!['full']!;

  String get empty => _localizedValues[locale.languageCode]!['empty']!;

  String get reservationDialog => _localizedValues[locale.languageCode]!['reservationDialog']!;

  String get confirmSeat => _localizedValues[locale.languageCode]!['confirmSeat']!;

  String get approval => _localizedValues[locale.languageCode]!['approval']!;

  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;

  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;

  String get reserveMessage => _localizedValues[locale.languageCode]!['reserveMessage']!;

  String get failedMessage => _localizedValues[locale.languageCode]!['failedMessage']!;

  String get profile => _localizedValues[locale.languageCode]!['profile']!;




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
      'userEventsTitle': 'Events',
      'full': 'Full',
      'empty': 'Empty',
      'reservationDialog': 'You have already reserved a seat in this event.',
      'confirmSeat': 'Confirm Seat',
      'approval': 'Do you want to reserve seat',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'reserveMessage' : "Seat reserved successfully",
      'failedMessage' : 'Seat reservation failed',
      'profile': 'Profile',

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
      'userEventsTitle': 'Etkinlikler',
      'full': 'Dolu',
      'empty': 'Boş',
      'reservationDialog': 'Bu etkinlik için zaten bir koltuk rezerve ettiniz.',
      'confirmSeat': 'Koltuğu Onayla',
      'approval': 'Koltuk rezervasyonu yapmak istiyor musunuz',
      'cancel': 'İptal',
      'confirm': 'Onayla',
      'reserveMessage' : "Koltuk başarıyla rezerve edildi",
      'failedMessage' : 'Koltuk rezervasyonu başarısız oldu',
      'profile': 'Profil',
    },
  };

  String get userSettingsPage {
    return _localizedValues[locale.languageCode]!['userSettingsPage']!;
  }

  String get settingsTitle {
    return _localizedValues[locale.languageCode]!['settingsTitle']!;
  }
}
