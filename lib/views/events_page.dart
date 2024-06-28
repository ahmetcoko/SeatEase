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
  Future<void> _refreshEvents() async {
    setState(() {});
  }

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
            onRefresh: _refreshEvents,
            child: ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                bool isAvailable = data['participants'].length < data['capacity'];
                return Card(
                  child: ExpansionTile(
                    leading: Image.asset('assets/images/event.png', width: 40),
                    title: Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Date-Time: ${DateFormat('yyyy-MM-dd – kk:mm').format(data['time'].toDate())} - ${data['participants'].length}/${data['capacity']}", style: TextStyle(fontWeight: FontWeight.normal)),
                    trailing: Image.asset(isAvailable ? 'assets/images/available.png' : 'assets/images/cross.png', width: 24),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(data['description']),
                            SizedBox(height: 20),
                            Text("Participants", style: TextStyle(fontWeight: FontWeight.bold)),
                            ...data['participants'].map<Widget>((name) => Text(name)).toList(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _selectDate(context, document.id),
                                  child: Text("Change Date-Time"),
                                ),
                                ElevatedButton(
                                  onPressed: () => _deleteEvent(document.id),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: Text("Delete Event"),
                                ),
                              ],
                            )
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

  void _selectDate(BuildContext context, String docId) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        DateTime fullDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        FirebaseFirestore.instance.collection('Events').doc(docId).update({
          'time': fullDateTime,
        });
      }
    }
  }

  void _deleteEvent(String docId) {
    FirebaseFirestore.instance.collection('Events').doc(docId).delete();
  }


  Stream<List<Event>> streamEvents() {
    return FirebaseFirestore.instance.collection('Events').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Event.fromFirestore(doc.data() as Map<String, dynamic>)).toList()
    );
  }
}
