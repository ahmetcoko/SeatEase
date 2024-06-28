import 'package:flutter/material.dart';


class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.white,
      hintColor: Colors.pinkAccent,
      scaffoldBackgroundColor: Colors.white,

      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black),
        titleMedium: TextStyle(fontSize: 18.0, fontStyle: FontStyle.italic, color: Colors.grey),
        bodyLarge: TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Colors.black),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.grey), // Label color
        hintStyle: TextStyle(color: Colors.grey),  // Hint text color
        errorStyle: TextStyle(color: Colors.red),  // Error text color
        // Setting default text style color
        counterStyle: TextStyle(color: Colors.black),
        floatingLabelStyle: TextStyle(color: Colors.black),
      ),

      buttonTheme: ButtonThemeData(
        buttonColor: Colors.pinkAccent,
        textTheme: ButtonTextTheme.primary,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        color: Colors.white,
        toolbarTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
