import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seat_ease/views/splash/sign_up.dart';
import 'package:seat_ease/views/splash/splash_screen.dart';
import 'package:seat_ease/views/theme_changer.dart';
import 'utils/app_theme.dart';
import 'views/splash/login_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Get the system's theme mode
  var brightness = WidgetsBinding.instance.window.platformBrightness;
  bool isDarkMode = brightness == Brightness.dark;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeChanger(isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SeatEase',
      routes: {
        "/loginPage": (context) => LoginPage(),
        "/signUp": (context) => SignUp(),
      },
      theme: theme.getTheme(),  // Use the current theme from the provider
      home: SplashScreen(),  // initial route
    );
  }
}