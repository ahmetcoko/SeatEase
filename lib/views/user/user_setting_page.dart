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
    final currentTheme = Provider.of<ThemeChanger>(context, listen: false).getTheme();
    isDarkTheme = currentTheme.brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);

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
                themeChanger.setTheme(isDarkTheme ? AppTheme.darkTheme : AppTheme.lightTheme);
              });
            },
            secondary: Icon(isDarkTheme ? Icons.dark_mode : Icons.light_mode),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("Language", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: themeChanger.getLocale().languageCode,
                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).iconTheme.color),
                isExpanded: true,
                items: <String>['en', 'tr'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase(), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  themeChanger.setLocale(Locale(newValue!));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}



