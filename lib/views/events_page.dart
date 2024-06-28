import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../data/events.dart';
import 'package:intl/intl.dart';

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
        title: Text("Events"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Events').snapshots(),
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
                      "Date-Time: ${DateFormat('yyyy-MM-dd – kk:mm').format(data['time'].toDate())} - ${data['participants'].length}/${data['capacity']}",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    trailing: Image.asset(
                      isAvailable ? 'assets/images/available.png' : 'assets/images/cross.png',
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
                              "Change Date-Time",
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
                              "Delete Event",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Add this line
                          children: [
                            Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(data['description']),
                            SizedBox(height: 10),
                            Text("Participants", style: TextStyle(fontWeight: FontWeight.bold)),
                            ...data['participants'].map<Widget>((name) => Text(name)).toList(),
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
      // Combine the date and time into one DateTime object
      DateTime eventDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      // Update the event in Firestore
      await FirebaseFirestore.instance.collection('Events').doc(eventId).update({
        'time': eventDateTime,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event date-time updated successfully')),
      );
    }
  }

  void _deleteEvent(String eventId) async {
    await FirebaseFirestore.instance.collection('Events').doc(eventId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event deleted successfully')),
    );
  }


  Stream<List<Event>> streamEvents() {
    return FirebaseFirestore.instance.collection('Events').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Event.fromFirestore(doc.data() as Map<String, dynamic>)).toList()
    );
  }
}
