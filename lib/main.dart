import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:seat_ease/views/splash/sign_up.dart';
import 'package:seat_ease/views/splash/splash_screen.dart';
import 'package:seat_ease/views/theme_changer.dart';
import 'config/firebase_api.dart';
import 'l10n/app_localization_delegate.dart';
import 'utils/app_theme.dart';
import 'views/splash/login_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseApi.registerBackgroundHandler();
  await FirebaseApi.initNotifications();

  var brightness = WidgetsBinding.instance.window.platformBrightness;
  bool isDarkMode = brightness == Brightness.dark;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeChanger(
        isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
        Locale('en'), // default locale
      ),
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      locale: themeProvider.getLocale(),
      theme: themeProvider.getTheme(),
      supportedLocales: [
        const Locale('en', ''),
        const Locale('tr', ''),
      ],
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'SeatEase',
      home: SplashScreen(),
      routes: {
        "/loginPage": (context) => LoginPage(),
        "/signUp": (context) => SignUp(),
      },
    );
  }
}

