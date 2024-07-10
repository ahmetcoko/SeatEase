import 'package:flutter/material.dart';
import 'package:seat_ease/views/user/user_events.dart';
import 'package:seat_ease/views/user/user_profile.dart';
import 'package:seat_ease/views/user/user_event_talk.dart';
import 'package:seat_ease/l10n/app_localizations.dart';




class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    UserEventsPage(), // Assumes you have an EventsPage widget
    EventsMedia(), // Assumes you have a SettingsPage widget
    UserProfilePage(), // Assumes you have a ProfilePage widget
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),  // Duration of the transition
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: AppLocalizations.of(context)!.userEventsTitle,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: AppLocalizations.of(context)!.eventTalk,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pinkAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

