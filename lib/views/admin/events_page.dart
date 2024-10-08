import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../../l10n/app_localizations.dart';
import '../../model/events.dart';


class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  DateTime? _editingDate;
  TimeOfDay? _editingTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userEventsTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Events').orderBy('time').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return RefreshIndicator(
            onRefresh: () => Future.sync(() => snapshot.requireData),
            child: ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                bool isAvailable = data['participants'].length < data['capacity'];
                return Card(
                  child: ExpansionTile(
                    leading: Image.asset('assets/images/event.png', width: 40),
                    title: Text(
                      data['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${AppLocalizations.of(context)!.dateTime}: ${DateFormat('yyyy-MM-dd – kk:mm').format(data['time'].toDate())} - ${data['participants'].length}/${data['capacity']}",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    trailing: Image.asset(
                      isAvailable
                          ? (data['time'].toDate().isBefore(DateTime.now())
                          ? 'assets/images/expired.png'
                          : 'assets/images/available.png')
                          : 'assets/images/cross.png',
                      width: 24,
                    ),
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _changeDateTime(context, document.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              minimumSize: Size(150, 50),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.changeDateTime,
                              style: TextStyle(color: Colors.pinkAccent),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _deleteEvent(document.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              minimumSize: Size(150, 50),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.deleteEvent,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.description, style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(data['description'] ?? 'No description provided'),
                            SizedBox(height: 10),
                            Text(AppLocalizations.of(context)!.participant, style: TextStyle(fontWeight: FontWeight.bold)),
                            ..._buildParticipantWidgets(data['participants']),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildParticipantWidgets(List<dynamic> participants) {
    return participants.map<Widget>((participant) {
      if (participant is Map<String, dynamic>) {
        return Text("${participant['name']} - ${AppLocalizations.of(context)!.seat} ${participant['seat']}");
      } else if (participant is String) {
       
        return Text(participant);
      } else {
        
        return Text('Unknown participant type');
      }
    }).toList();
  }

  void _changeDateTime(BuildContext context, String eventId) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _editingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _editingTime ?? TimeOfDay.now(),
    );

    if (pickedDate != null && pickedTime != null) {
      
      DateTime eventDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

     
      await FirebaseFirestore.instance.collection('Events').doc(eventId).update({
        'time': eventDateTime,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.dateTimeUpdate)),
      );
    }
  }

  void _deleteEvent(String eventId) async {
    try {
   
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('deleteEvent');
      final response = await callable.call(<String, dynamic>{
        'eventId': eventId,
      });
      if (response.data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.eventDeleted)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: $e')),
      );
    }
  }


  Stream<List<Event>> streamEvents() {
    return FirebaseFirestore.instance.collection('Events').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Event.fromFirestore(doc.data() as Map<String, dynamic>)).toList()
    );
  }
}
