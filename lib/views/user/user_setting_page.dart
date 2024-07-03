import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_theme.dart';
import '../theme_changer.dart';

class SettingsUserPage extends StatefulWidget {
  @override
  _SettingsUserPageState createState() => _SettingsUserPageState();
}

class _SettingsUserPageState extends State<SettingsUserPage> {
  late bool isDarkTheme;

  @override
  void initState() {
    super.initState();
    // Determine the current theme based on the provider
    final currentTheme = Provider.of<ThemeChanger>(context, listen: false).getTheme();
    isDarkTheme = currentTheme.brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Theme"),
            subtitle: Text(isDarkTheme ? "Dark Theme" : "Light Theme"),
            value: isDarkTheme,
            onChanged: (value) {
              setState(() {
                isDarkTheme = value;
                // Update the theme in the provider
                Provider.of<ThemeChanger>(context, listen: false).setTheme(
                    isDarkTheme ? AppTheme.darkTheme : AppTheme.lightTheme
                );
              });
            },
            secondary: Icon(isDarkTheme ? Icons.dark_mode : Icons.light_mode),
          ),
        ],
      ),
    );
  }
}


