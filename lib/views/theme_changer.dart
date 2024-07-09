import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;
  Locale _locale;

  ThemeChanger(this._themeData, this._locale);

  ThemeData getTheme() => _themeData;
  Locale getLocale() => _locale;

  void setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}


