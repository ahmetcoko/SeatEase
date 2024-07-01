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
                  if (_events[date] != null && _events[date]!.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100, // Change color to indicate selection
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(color: Colors.blue[200]),
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
                            ),
                            // Here we integrate the seat grid
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildSeatGrid(
                                  data['row'],
                                  data['column'],
                                  List<bool>.filled(data['row'] * data['column'], false) // Assuming all seats are empty initially
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

  Widget _buildSeat(bool isOccupied) {
    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isOccupied ? Colors.white : Colors.blue,
        border: Border.all(color: Colors.black),
      ),
    );
  }

  Widget _buildSeatGrid(int? rows, int? columns, List<bool> occupancy) {
    // Debugging output to check what is received
    print("Building seat grid with rows: $rows, columns: $columns");

    // Provide default values in case rows or columns are null
    final int rowCount = rows ?? 5; // Default to 5 rows if null
    final int columnCount = columns ?? 8; // Default to 8 columns if null

    // Ensure occupancy list matches expected size, default to all seats empty
    if (occupancy.isEmpty || occupancy.length != rowCount * columnCount) {
      occupancy = List<bool>.filled(rowCount * columnCount, false);
      print("Occupancy adjusted to match row/column count");
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // Disable GridView's scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        childAspectRatio: 1, // Ensures the cells are square-shaped
      ),
      itemCount: rowCount * columnCount,
      itemBuilder: (context, index) {
        // Determine if the seat is occupied
        bool isOccupied = occupancy[index];
        return _buildSeat(isOccupied);
      },
    );
  }



  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue[300],
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


