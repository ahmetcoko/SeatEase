import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seat_ease/l10n/app_localizations.dart';

class UserSettingsPage extends StatefulWidget {
  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  late Future<List<DocumentSnapshot>> _futureExpiredEvents;

  @override
  void initState() {
    super.initState();
    _futureExpiredEvents = _fetchExpiredEvents();
  }

  Future<List<DocumentSnapshot>> _fetchExpiredEvents() async {
    var userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    var now = DateTime.now();
    var snapshot = await FirebaseFirestore.instance
        .collection('Events')
        .where('participants', arrayContains: {'name': userId})
        .where('time', isLessThan: Timestamp.fromDate(now))
        .get();

    return snapshot.docs;
  }

  Future<String> _fetchUserFullName() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      print("No user ID available");
      return "Unknown User";
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['fullname'] ?? "Unknown User";
      }
    } catch (e) {
      print("Failed to load user fullname: $e");
    }
    return "Unknown User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userSettingsPage),
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        future: _fetchUserFullName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text("Failed to fetch user data or user not found"));
          }
          String currentUserName = snapshot.data!;
          // Continue with your logic here once the data is available
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Events').orderBy('time').snapshots(),
            builder: (context, eventSnapshot) {
              if (eventSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Ensure this also handles loading gracefully
              }
              if (eventSnapshot.hasError) {
                return Text('Something went wrong');
              }
              if (eventSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              var joinedEvents = eventSnapshot.data!.docs.where((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                return data['participants'].any((participant) => participant['name'] == currentUserName);
              }).toList();

              if (joinedEvents.isEmpty) {
                return Center(child: Text(AppLocalizations.of(context)!.infoEvents));
              }
              return ListView(
                children: eventSnapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  bool isUserJoined = data['participants'].any((participant) => participant['name'] == currentUserName);
                  if (!isUserJoined) return Container(); // Skip events the user hasn't joined

                  // Extract user's seat for the cancellation function
                  String userSeat = data['participants'].firstWhere((p) => p['name'] == currentUserName, orElse: () => {'seat': null})['seat'];

                  return Card(
                    child: ExpansionTile(
                      leading: Image.asset('assets/images/event.png', width: 40),
                      title: Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${AppLocalizations.of(context)!.dateTime}: ${DateFormat('yyyy-MM-dd – kk:mm').format(data['time'].toDate())}"),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child: Center(
                            child: Text(AppLocalizations.of(context)!.description, style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(data['description'] ?? 'No description provided'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(AppLocalizations.of(context)!.seat, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              data['participants']
                                  .firstWhere((participant) => participant['name'] == currentUserName, orElse: () => {'seat': 'No Seat Assigned'})['seat'],
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}



