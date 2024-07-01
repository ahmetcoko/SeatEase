import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/events.dart';

class UserEventsPage extends StatefulWidget {
  @override
  _UserEventsPageState createState() => _UserEventsPageState();
}

class _UserEventsPageState extends State<UserEventsPage> {
  DateTime? _editingDate;
  TimeOfDay? _editingTime;
  bool isCalendarVisible = false;
  DateTime? selectedDay;
  DateTime? focusedDay = DateTime.now();
  Map<DateTime, List<dynamic>> _events = {};
  CalendarFormat calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _retrieveEvents();
  }

  // Retrieve events and organize them by date for the calendar markers
  void _retrieveEvents() {
    FirebaseFirestore.instance.collection('Events').snapshots().listen((snapshot) {
      Map<DateTime, List<dynamic>> tempEvents = {};
      for (var doc in snapshot.docs) {
        DateTime date = (doc.data()['time'] as Timestamp).toDate();
        DateTime dateKey = DateTime(date.year, date.month, date.day);
        if (!tempEvents.containsKey(dateKey)) {
          tempEvents[dateKey] = [];
        }
        tempEvents[dateKey]?.add(doc.data());
      }
      setState(() {
        _events = tempEvents;
      });
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Events"),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              setState(() {
                isCalendarVisible = !isCalendarVisible;
                if (!isCalendarVisible) {
                  selectedDay = null; // Reset the selected day when calendar is closed
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isCalendarVisible) // Only display the calendar if toggled
            TableCalendar(
              firstDay: DateTime.utc(2010, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              calendarFormat: calendarFormat,
              eventLoader: (day) => _events[day] ?? [],
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;  // You might need to add this variable if you want to keep track of which month is focused
                });
              },
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildEventsMarker(date, events),
                    );
                  }
                },
              ),
            ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: selectedDay == null
                  ? FirebaseFirestore.instance.collection('Events').orderBy('time').snapshots()
                  : FirebaseFirestore.instance.collection('Events')
                  .where('time', isGreaterThanOrEqualTo: DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day))
                  .where('time', isLessThan: DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day + 1))
                  .orderBy('time')
                  .snapshots(),

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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(data['description'] ?? 'No description provided'),
                                  SizedBox(height: 10),
                                  Text("Participants", style: TextStyle(fontWeight: FontWeight.bold)),
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
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: events.length > 1 ? Colors.blue[700] : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }




  List<Widget> _buildParticipantWidgets(List<dynamic> participants) {
    return participants.map<Widget>((participant) {
      if (participant is Map<String, dynamic>) {
        return Text("${participant['name']} - Seat: ${participant['seat']}");
      } else if (participant is String) {
        // Handle the case where a participant is a String
        return Text(participant);
      } else {
        // Handle the case where a participant is neither a Map nor a String
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


