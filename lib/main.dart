import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:seat_ease/sign_up.dart';
import 'package:seat_ease/tab_bar_controller.dart';
import 'package:seat_ease/utils/customColors.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'login_page.dart';


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
      title: 'Flutter Demo',
      routes: {
        "/loginPage": (context) => LoginPage(),
        "/signUp": (context) => SignUp(),
        "/homePage": (context) => HomePage()
      },
      theme: ThemeData(
          scaffoldBackgroundColor: CustomColors.darkColor,
          appBarTheme: AppBarTheme(color: CustomColors.pinkColor)
      ),
      home: LoginPage(),  // Set LoginPage as the initial route
    );
  }
}
