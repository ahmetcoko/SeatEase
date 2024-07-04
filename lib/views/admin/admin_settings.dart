import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../theme_changer.dart';

class AdminSettingsPage extends StatefulWidget {
  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  late bool isDarkTheme;

  @override
  void initState() {
    super.initState();
    final currentTheme = Provider.of<ThemeChanger>(context, listen: false).getTheme();
    isDarkTheme = currentTheme.brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Theme"),
            subtitle: Text(isDarkTheme ? "Dark Theme" : "Light Theme"),
            value: isDarkTheme,
            onChanged: (bool value) {
              setState(() {
                isDarkTheme = value;
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
