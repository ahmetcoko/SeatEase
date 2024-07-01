import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../splash/login_page.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            // Implement the logout functionality
            _logout(context);
          },
        ),
      ),
      body: Center(
        child: Text('Profile Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _logout(BuildContext context) {
    // Example logout functionality
    // Assume you're using Firebase Authentication for this example
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }).catchError((error) {
      // Handle errors or notify user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: ${error.toString()}")),
      );
    });
  }
}

