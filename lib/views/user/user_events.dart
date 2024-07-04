import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';


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
    String currUserName = '';
    bool isDataLoaded = false;  // Flag to check if data is loaded
    bool showContent = false; // Added flag to control visibility of content

/// TODO: BAK
  /*@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }*/
    @override
    void initState() {
      super.initState();
      _initPage();
      // Add a timer to delay the display of content
      Timer(Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            showContent = true;
          });
        }
      });
    }

    Future<void> _initUserName() async {
      String name = await _fetchUserFullName();
      currUserName = name;  // Update the username without setting state immediately
    }

    Future<void> _initPage() async {
      await _initUserName();
      await _retrieveEvents();
      if (mounted) {
        setState(() {
          isDataLoaded = true;  // Set the data loaded flag to true after all data is fetched
        });
      }
    }


    // Retrieve events and organize them by date for the calendar markers
    Future<void> _retrieveEvents() async {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Events').get();
      Map<DateTime, List<dynamic>> tempEvents = {};
      for (var doc in snapshot.docs) {
        var data = doc.data();  // Get the data from the document
        if (data is Map<String, dynamic>) {  // Ensure data is correctly cast to Map<String, dynamic>
          Timestamp timestamp = data['time'] as Timestamp? ?? Timestamp.now();  // Use a fallback if null
          DateTime date = timestamp.toDate();
          DateTime dateKey = DateTime(date.year, date.month, date.day);
          tempEvents[dateKey] = tempEvents[dateKey] ?? [];
          tempEvents[dateKey]?.add(data);
        }
      }
      _events = tempEvents;
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

    void toggleCalendarVisibility() {
      setState(() {
        isCalendarVisible = !isCalendarVisible;
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("User Events"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(isCalendarVisible ? Icons.calendar_view_day : Icons.calendar_today),
              onPressed: toggleCalendarVisibility,
            ),
          ],
        ),
        body: !isDataLoaded
            ? Center(child: CircularProgressIndicator())  // Show a full-screen loader if data is not yet loaded
            : AnimatedOpacity(
          opacity: showContent ? 1.0 : 0.0,
          duration: Duration(milliseconds: 2000),
          onEnd: () {
            if (!showContent) {
              // Only update the state to show content once the animation has completed, preventing premature visibility
              setState(() {
                showContent = true;
              });
            }
          },
          child: Column(
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
                            color: Colors.blue.shade100,
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
                child: FutureBuilder<String>(
                  future: _fetchUserFullName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError || snapshot.data == "Unknown User") {
                      return Center(child: Text("Failed to fetch user data or user not found"));
                    }
                    String currentUserName = snapshot.data!;
                    return StreamBuilder<QuerySnapshot>(
                      stream: selectedDay == null
                          ? FirebaseFirestore.instance.collection('Events').orderBy('time').snapshots()
                          : FirebaseFirestore.instance.collection('Events')
                          .where('time', isGreaterThanOrEqualTo: DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day))
                          .where('time', isLessThan: DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day + 1))
                          .orderBy('time')
                          .snapshots(),
                      builder: (context, eventSnapshot) {
                        if (eventSnapshot.hasError) {
                          return Text('Something went wrong');
                        }
                        if (eventSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        return ListView(
                          children: eventSnapshot.data!.docs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            bool isUserJoined = data['participants'].any((participant) => participant['name'] == currentUserName);
                            bool isFull = data['participants'].length >= data['capacity'];
                            bool isPast = data['time'].toDate().isBefore(DateTime.now());

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
                                  isPast
                                      ? 'assets/images/expired.png'  // Show expired image if the event date is past
                                      : isUserJoined
                                      ? 'assets/images/res2.png'  // Show reserved image if user is joined
                                      : isFull
                                      ? 'assets/images/cross.png'  // Show cross image if event is full
                                      : 'assets/images/available.png',  // Otherwise, show available image
                                  width: 24,
                                ),
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Description",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data['description'] ?? 'No description provided',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _buildSeatGrid(
                                        data['row'],
                                        data['column'],
                                        data['participants'],
                                        document.id
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          color: Colors.red.shade800,
                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                        ),
                                        Text("Full"),
                                        Container(
                                          width: 20,
                                          height: 20,
                                          color: Colors.green.shade200,
                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                        ),
                                        Text("Empty"),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }




void _showReservationDialog(String seatId, String documentId, List<dynamic> participants) {
      // Check if the current user has already reserved a seat
      bool hasReserved = participants.any((participant) => participant['name'] == 'Ahmet Coko');

      if (hasReserved) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You have already reserved a seat in this event."))
        );
        return;  // Exit if the user has already reserved a seat
      }

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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Seat $seatId reserved successfully!"))
        );
      }).catchError((error) {
        SnackBar(content: Text("Failed to reserve seat: $error"));
      });
    }



    Widget _buildSeatGrid(int rows, int columns, List<dynamic> participants, String documentId) {
      // Create a set of occupied seats for quick lookup
      Set<String> occupiedSeats = participants.map<String>((participant) {
        return participant['seat'] as String;  // Make sure 'seat' is a string and corresponds to your seat naming convention
      }).toSet();

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
          String seatId = String.fromCharCode(65 + row) + (col + 1).toString(); // Generates seat ID like "A1", "A2", ...

          // Determine if the seat is occupied
          bool isOccupied = occupiedSeats.contains(seatId);
          return _buildSeat(row, col, isOccupied, documentId, seatId, participants);
        },
      );
    }

    Widget _buildSeat(int row, int col, bool isOccupied, String documentId, String seatId, List<dynamic> participants) {
      return InkWell(
        onTap: () {
          if (!isOccupied) {
            _showReservationDialog(seatId, documentId, participants);
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



