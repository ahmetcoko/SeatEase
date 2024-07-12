import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_theme.dart';
import '../splash/login_page.dart';
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
    final themeChanger = Provider.of<ThemeChanger>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.themTitle),
            subtitle: Text(isDarkTheme ? (AppLocalizations.of(context)!.darkTheme) : (AppLocalizations.of(context)!.lightTheme)),
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
            child: Text(AppLocalizations.of(context)!.language, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: ${error.toString()}")),
      );
    });
  }
}
