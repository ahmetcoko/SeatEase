import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

class EventDetailPage extends StatefulWidget {
  late final DocumentSnapshot eventDocument;

  EventDetailPage({required this.eventDocument});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  String currUserName = '';

  @override
  void initState() {
    _initUserName();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.eventDocument.data()! as Map<String, dynamic>;
    DateTime eventDate = (data['time'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bookSeat),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['name'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              SizedBox(height: 16),
              Text(
                "${AppLocalizations.of(context)!.dateTime}: ${DateFormat('yyyy-MM-dd – kk:mm').format(data['time'].toDate())}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "${AppLocalizations.of(context)!.capacity}: ${data['participants'].length}/${data['capacity']}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.description,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                data['description'] ?? 'No description provided',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              _buildSeatGrid(
                  data['row'],
                  data['column'],
                  data['participants'],
                  widget.eventDocument.id,
                  eventDate
              ),
              SizedBox(height: 16),
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
                    Text(AppLocalizations.of(context)!.full),
                    Container(
                      width: 20,
                      height: 20,
                      color: Colors.green.shade200,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    Text(AppLocalizations.of(context)!.empty),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initUserName() async {
    String name = await _fetchUserFullName();
    setState(() {
      currUserName = name;  
    });
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

  void _showReservationDialog(String seatId, String documentId, List<dynamic> participants, DateTime eventDate) {
    
    if (eventDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.alreadyTakenPlace))
      );
      return; 
    }

    
    bool hasReserved = participants.any((participant) => participant['name'] == currUserName);

    if (hasReserved) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.reservationDialog))
      );
      return; 
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmSeat),
          content: Text("${AppLocalizations.of(context)!.approval} ${AppLocalizations.of(context)!.yourSeat} $seatId "),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.confirm),
              onPressed: () {
                _reserveSeat(seatId, documentId, eventDate); 
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _reserveSeat(String seatId, String documentId, DateTime eventDate) {
    if (eventDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.alreadyTakenPlace))
      );
      return;
    }

    FirebaseFirestore.instance.collection('Events').doc(documentId).update({
      'participants': FieldValue.arrayUnion([
        {'name': currUserName, 'seat': seatId}
      ])
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context)!.reserveMessage} ${AppLocalizations.of(context)!.yourSeat} $seatId "))
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to reserve seat: $error"))
      );
    });
  }







  Widget _buildSeatGrid(int rows, int columns, List<dynamic> participants, String documentId, DateTime eventDate) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Events').doc(documentId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        
        var data = snapshot.data!.data() as Map<String, dynamic>;
        participants = data['participants'] as List<dynamic>;

        Set<String> occupiedSeats = participants.map<String>((participant) {
          return participant['seat'] as String;
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
            String seatId = String.fromCharCode(65 + row) + (col + 1).toString();

            bool isOccupied = occupiedSeats.contains(seatId);
            return _buildSeat(row, col, isOccupied, documentId, seatId, participants, eventDate);
          },
        );
      },
    );
  }




  Widget _buildSeat(int row, int col, bool isOccupied, String documentId, String seatId, List<dynamic> participants, DateTime eventDate) {
    return InkWell(
      onTap: () {
        if (!isOccupied) {
          _showReservationDialog(seatId, documentId, participants, eventDate);
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


}
