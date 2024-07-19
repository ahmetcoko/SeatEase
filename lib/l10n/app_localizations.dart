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

  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;

  String get email => _localizedValues[locale.languageCode]!['email']!;

  String get password => _localizedValues[locale.languageCode]!['password']!;

  String get login => _localizedValues[locale.languageCode]!['login']!;

  String get username => _localizedValues[locale.languageCode]!['username']!;

  String get fullName => _localizedValues[locale.languageCode]!['fullName']!;

  String get confirmPassword => _localizedValues[locale.languageCode]!['confirmPassword']!;

  String get createAccount => _localizedValues[locale.languageCode]!['createAccount']!;

  String get backToLogin => _localizedValues[locale.languageCode]!['backToLogin']!;

  String get passwordValidation => _localizedValues[locale.languageCode]!['passwordValidation']!;

  String get confirmPasswordValidation => _localizedValues[locale.languageCode]!['confirmPasswordValidation']!;

  String get emailValidation => _localizedValues[locale.languageCode]!['emailValidation']!;

  String get usernameValidation => _localizedValues[locale.languageCode]!['usernameValidation']!;

  String get fullNameValidation => _localizedValues[locale.languageCode]!['fullNameValidation']!;

  String get passwordValidationRequest => _localizedValues[locale.languageCode]!['passwordValidationRequest']!;

  String get forgotPassword => _localizedValues[locale.languageCode]!['forgotPassword']!;

  String get sendResetMail => _localizedValues[locale.languageCode]!['sendResetMail']!;

  String get infoResetSended => _localizedValues[locale.languageCode]!['infoResetSended']!;

  String get infoResetNotSended => _localizedValues[locale.languageCode]!['infoResetNotSended']!;

  String get enterEmail => _localizedValues[locale.languageCode]!['enterEmail']!;

  String get enterPassword => _localizedValues[locale.languageCode]!['enterPassword']!;

  String get loginError => _localizedValues[locale.languageCode]!['loginError']!;

  String get tryAgain => _localizedValues[locale.languageCode]!['tryAgain']!;

  String get createEvent => _localizedValues[locale.languageCode]!['createEvent']!;

  String get eventName => _localizedValues[locale.languageCode]!['eventName']!;

  String get eventDate => _localizedValues[locale.languageCode]!['eventDate']!;

  String get eventTime => _localizedValues[locale.languageCode]!['eventTime']!;

  String get eventDescription => _localizedValues[locale.languageCode]!['eventDescription']!;

  String get rowNumber => _localizedValues[locale.languageCode]!['rowNumber']!;

  String get columnNumber => _localizedValues[locale.languageCode]!['columnNumber']!;

  String get eventNameCheck => _localizedValues[locale.languageCode]!['eventNameCheck']!;

  String get rowNumberCheck => _localizedValues[locale.languageCode]!['rowNumberCheck']!;

  String get columnNumberCheck => _localizedValues[locale.languageCode]!['columnNumberCheck']!;

  String get changeDateTime => _localizedValues[locale.languageCode]!['changeDateTime']!;

  String get deleteEvent => _localizedValues[locale.languageCode]!['deleteEvent']!;

  String get participant => _localizedValues[locale.languageCode]!['participant']!;

  String get dateTimeUpdate => _localizedValues[locale.languageCode]!['dateTimeUpdate']!;

  String get eventDeleted => _localizedValues[locale.languageCode]!['eventDeleted']!;

  String get eventTalk => _localizedValues[locale.languageCode]!['eventTalk']!;

  String get addComment => _localizedValues[locale.languageCode]!['addComment']!;

  String get capacity => _localizedValues[locale.languageCode]!['capacity']!;

  String get back => _localizedValues[locale.languageCode]!['back']!;

  String get bookSeat => _localizedValues[locale.languageCode]!['bookSeat']!;

  String get reserveSeat => _localizedValues[locale.languageCode]!['reserveSeat']!;

  String get averageRating => _localizedValues[locale.languageCode]!['averageRating']!;

  String get search => _localizedValues[locale.languageCode]!['search']!;
















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
      'welcome': 'Welcome to',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'username': 'Username',
      'fullName': 'Full Name',
      'confirmPassword': 'Confirm Password',
      'createAccount': 'Create Account',
      'backToLogin': 'Back to Login Page',
      'passwordValidation': 'Password must be at least 6 characters',
      'confirmPasswordValidation': 'Passwords do not match',
      'emailValidation': 'Email must contain @',
      'usernameValidation': 'Username must be within 20 characters.',
      'fullNameValidation': 'Full Name must be within 20 characters and contain a space',
      'passwordValidationRequest': "Please confirm your password. ",
      'forgotPassword': 'Forgot Password',
      'sendResetMail': 'Send Reset Mail',
      'infoResetSended': 'Password reset email sent.',
      'infoResetNotSended': 'Error occurred while sending password reset email.',
      'enterEmail': 'Enter your email',
      'enterPassword': 'Enter your password',
      'loginError': 'Login Error',
      'tryAgain': 'Try Again',
      'createEvent': 'Create Event',
      'eventName': 'Event Name',
      'eventDate': 'Event Date',
      'eventTime': 'Event Time',
      'eventDescription': 'Event Description',
      'rowNumber': 'Row Number',
      'columnNumber': 'Column Number',
      'eventNameCheck': 'Please enter a name for the event',
      'rowNumberCheck': 'Please enter a valid number less than 10',
      'columnNumberCheck': 'Please enter a valid number less than 10',
      'changeDateTime': 'Change Date-Time',
      'deleteEvent': 'Delete Event',
      'participant': 'Participants',
      'dateTimeUpdate': 'Event date-time updated successfully',
      'eventDeleted': 'Event deleted successfully',
      'eventTalk': 'Event Talk',
      'addComment': 'Add Comment',
      'capacity': 'Capacity',
      'back': 'Back',
      'bookSeat': 'Reservation',
      'reserveSeat': 'Reserve Seat',
      'averageRating': 'Average Rating',
      'search': 'Search',



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
      'welcome': 'Hoşgeldiniz',
      'email': 'Email',
      'password': 'Şifre',
      'login': 'Giriş',
      'username': 'Kullanıcı Adı',
      'fullName': 'Ad Soyad',
      'confirmPassword': 'Şifreyi Onayla',
      'createAccount': 'Hesap Oluştur',
      'backToLogin': 'Giriş Sayfasına Geri Dön',
      'passwordValidation': 'Şifre en az 6 karakter olmalıdır',
      'confirmPasswordValidation': 'Şifreler eşleşmiyor',
      'emailValidation': 'Email "@" içermelidir',
      'usernameValidation': 'Kullanıcı adı en fazla 20 karakter olmalıdır.',
      'fullNameValidation': 'Ad Soyad en fazla 20 karakter olmalı ve bir boşluk içermelidir',
      'passwordValidationRequest': "Lütfen şifrenizi onaylayın.",
      'createAccount': 'Hesap Oluştur',
      'login': 'Giriş',
      'forgotPassword': 'Şifremi Unuttum',
      'sendResetMail': 'Şifre Sıfırlama Maili Gönder',
      'infoResetSended': 'Şifre sıfırlama maili gönderildi.',
      'infoResetNotSended': 'Şifre sıfırlama maili gönderilirken hata oluştu.',
      'enterEmail': 'Emailinizi girin',
      'enterPassword': 'Şifrenizi girin',
      'loginError': 'Giriş Hatası',
      'tryAgain': 'Tekrar Deneyin',
      'createEvent': 'Etkinlik Oluştur',
      'eventName': 'Etkinlik Adı',
      'eventDate': 'Etkinlik Tarihi',
      'eventTime': 'Etkinlik Saati',
      'eventDescription': 'Etkinlik Açıklaması',
      'rowNumber': 'Sıra Numarası',
      'columnNumber': 'Kolon Numarası',
      'eventNameCheck': 'Lütfen etkinlik için bir isim girin',
      'rowNumberCheck': 'Lütfen 10 dan küçük geçerli bir numara girin',
      'columnNumberCheck': 'Lütfen 10 dan küçük geçerli bir numara girin',
      'changeDateTime': 'Tarih-Saat Değiştir',
      'deleteEvent': 'Etkinliği Sil',
      'participant': 'Katılımcılar',
      'dateTimeUpdate': 'Etkinlik tarih-saat bilgisi başarıyla güncellendi',
      'eventDeleted': 'Etkinlik başarıyla silindi',
      'eventTalk': 'Yorumlar',
      'addComment': 'Yorum Yap',
      'capacity': 'Kapasite',
      'back' : 'Geri',
      'bookSeat': 'Koltuk Seçimi',
      'reserveSeat': 'Koltuk Seçimi',
      'averageRating': 'Etkinlik Puanı',
      'search': 'Ara',




    },
  };

  String get userSettingsPage {
    return _localizedValues[locale.languageCode]!['userSettingsPage']!;
  }

  String get settingsTitle {
    return _localizedValues[locale.languageCode]!['settingsTitle']!;
  }
}
