import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../theme_changer.dart';


class UserSettingsPage extends StatefulWidget {
  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.userSettingsPage,
            ),
          ],
        ),
      ),
    );
  }
}
