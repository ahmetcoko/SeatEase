import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/events.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/events.dart';

  class UserEventsPage extends StatefulWidget {
    @override
    _UserEventsPageState createState() => _UserEventsPageState();
  }

  class _UserEventsPageState extends State<UserEventsPage> {
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
                focusedDay: focusedDay!,
                calendarFormat: calendarFormat,
                eventLoader: (day) => _events[day] ?? [],
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    this.selectedDay = selectedDay;
                    this.focusedDay = focusedDay;
                  });
                },
                selectedDayPredicate: (day) {
                  return isSameDay(selectedDay, day);
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        right: 5,
                        bottom: 5,
                        child: _buildEventsMarker(date, events),
                      );
                    }
                  },
                  defaultBuilder: (context, date, _) {
                    DateTime dateKey = DateTime(date.year, date.month, date.day);
                    if (_events[dateKey] != null && _events[dateKey]!.isNotEmpty) {
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100, // Change color to indicate an event
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      return null; // Use default style
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
                        return InkWell( // Using InkWell to add a tap functionality
                          onTap: () {
                            // Here you can use document.id which is the documentId of the clicked item
                            print("Clicked event ID: ${document.id}");
                            // Optionally, perform navigation or further actions with the documentId
                          },
                          child: Card(
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
                                ),
                                // Here we integrate the seat grid
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _buildSeatGrid(
                                      data['row'],
                                      data['column'],
                                      List<bool>.filled(data['row'] * data['column'], false), // Assuming all seats are empty initially
                                      document.id // Pass the documentId to _buildSeatGrid
                                  ),
                                ),
                              ],
                            ),
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

    void _showReservationDialog(String seatId, String documentId) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Seat"),
            content: Text("Do you want to reserve seat $seatId?"),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Confirm"),
                onPressed: () {
                  _reserveSeat(seatId, documentId);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void _reserveSeat(String seatId, String documentId) {
      FirebaseFirestore.instance.collection('Events').doc(documentId).update({
        'participants': FieldValue.arrayUnion([
          {'name': 'Ahmet Coko', 'seat': seatId}
        ])
      }).then((_) {
        print("Seat reserved successfully.");
        // Optionally, refresh the state to show the updated seat status
      }).catchError((error) {
        print("Failed to reserve seat: $error");
      });
    }



    Widget _buildSeat(int row, int col, bool isOccupied, String documentId) {
      // Construct seat identifier
      String seatId = String.fromCharCode(65 + row) + (col + 1).toString();
      return InkWell(
        onTap: () {
          if (!isOccupied) {
            _showReservationDialog(seatId, documentId);
          }
        },
        child: Container(
          margin: EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isOccupied ? Colors.red.shade800 : Colors.green.shade200,
            border: Border.all(color: Colors.black),
          ),
          child: Text(seatId, style: TextStyle(color: Colors.white)),
        ),
      );
    }

    Widget _buildSeatGrid(int rows, int columns, List<bool> occupancy, String documentId) {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 1,
        ),
        itemCount: rows * columns,
        itemBuilder: (context, index) {
          int row = index ~/ columns;
          int col = index % columns;
          return _buildSeat(row, col, occupancy[index], documentId);
        },
      );
    }




    Widget _buildEventsMarker(DateTime date, List events) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue[200],
        ),
        width: 20.0,
        height: 20.0,
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
  }



