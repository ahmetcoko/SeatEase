import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';


class EventsMedia extends StatefulWidget {
  @override
  _EventsMediaPageState createState() => _EventsMediaPageState();
}

class _EventsMediaPageState extends State<EventsMedia> {
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
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

  Future<void> _postComment(String eventId, String comment, String userName) async {
    if (comment.isNotEmpty) {
      await FirebaseFirestore.instance.collection('Events').doc(eventId).update({
        'comments': FieldValue.arrayUnion([{'name': userName, 'comment': comment}])
      });
      _commentController.clear();
    }
  }

  Widget _buildCommentsSection(List<dynamic> comments, String eventId, String currentUser) {
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text("No comments made yet")),
      );
    }
    return ListView(
      physics: NeverScrollableScrollPhysics(), // to disable scrolling in nested list
      shrinkWrap: true,
      children: comments.map((comment) {
        return ListTile(
          title: Text(comment['name']),
          subtitle: Text(comment['comment']),
          trailing: comment['name'] == currentUser ? IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteComment(eventId, comment),
          ) : null,
        );
      }).toList(),
    );
  }

  Future<void> _deleteComment(String eventId, Map<String, dynamic> commentToDelete) async {
    await FirebaseFirestore.instance.collection('Events').doc(eventId).update({
      'comments': FieldValue.arrayRemove([commentToDelete])
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.eventTalk),
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        future: _fetchUserFullName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text("Failed to fetch user data or user not found"));
          }
          String currentUserName = snapshot.data!;
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Events')
                .where('time', isLessThan: Timestamp.fromDate(DateTime.now()))
                .snapshots(),
            builder: (context, eventSnapshot) {
              if (eventSnapshot.hasError) return Text('Something went wrong');
              if (eventSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return ListView(
                children: eventSnapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  List<dynamic> comments = data['comments'] ?? [];
                  bool isUserJoined = data['participants'].any((participant) => participant['name'] == currentUserName);
                  if (!isUserJoined) return Container(); // Skip events the user hasn't joined
                  return Card(
                    child: ExpansionTile(
                      leading: Image.asset('assets/images/event.png', width: 40),
                      title: Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${AppLocalizations.of(context)!.dateTime}: ${DateFormat('yyyy-MM-dd – kk:mm').format(data['time'].toDate())}"),
                      children: [
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
                        _buildCommentsSection(comments, document.id, currentUserName),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!.addComment,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () => _postComment(document.id, _commentController.text, currentUserName),
                              )
                            ],
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




