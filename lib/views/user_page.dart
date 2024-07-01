import 'package:flutter/material.dart';
import 'package:seat_ease/views/user_events.dart';
import 'package:seat_ease/views/user_profile.dart';
import 'package:seat_ease/views/user_settings.dart';



class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 0;

  // Adjusted the list of pages to fit the user context
  final List<Widget> _widgetOptions = [
    UserEventsPage(), // Assumes you have an EventsPage widget
    UserSettingsPage(), // Assumes you have a SettingsPage widget
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
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pinkAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

