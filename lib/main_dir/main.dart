import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:seat_ease/views/splash/sign_up.dart';
import 'package:seat_ease/utils/customColors.dart';
import '../service/firebase_options.dart';
import '../utils/app_theme.dart';
import '../views/splash/login_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SeatEase',
      routes: {
        "/loginPage": (context) => LoginPage(),
        "/signUp": (context) => SignUp(),
      },
      theme: AppTheme.lightTheme,
      home: LoginPage(),  // initial route
    );
  }
}
