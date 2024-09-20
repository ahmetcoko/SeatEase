import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seat_ease/l10n/app_localizations.dart';
import 'package:seat_ease/views/admin/admin_settings.dart';
import 'package:seat_ease/views/admin/profile_page.dart';
import 'package:seat_ease/views/admin/create_event.dart';

import 'events_page.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;


  final List<Widget> _widgetOptions = [
    EventsPage(),
    CreateEvent(),
    AdminSettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300), 
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event), 
            label: AppLocalizations.of(context)!.userEventsTitle,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: AppLocalizations.of(context)!.createEvent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settingsTitle,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pinkAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

