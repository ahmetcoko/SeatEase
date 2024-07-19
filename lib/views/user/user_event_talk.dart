import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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

  Future<double> _calculateAverageScore(Map<String, dynamic> ratings) async {
    if (ratings.isEmpty) return 0.0;
    double total = ratings.values.fold(0.0, (sum, item) => sum + (item as num));
    return total / ratings.length;
  }

  Widget _buildCommentsSection(List<dynamic> comments, String eventId, String currentUser) {
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text("No comments made yet")),
      );
    }
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: comments.map<Widget>((comment) {
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

  Future<void> _postComment(String eventId, String comment, String userName) async {
    if (comment.isNotEmpty) {
      await FirebaseFirestore.instance.collection('Events').doc(eventId).update({
        'comments': FieldValue.arrayUnion([{'name': userName, 'comment': comment}])
      });
      _commentController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Talk"),
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
            stream: FirebaseFirestore.instance.collection('Events').where('time', isLessThan: Timestamp.fromDate(DateTime.now())).snapshots(),
            builder: (context, eventSnapshot) {
              if (eventSnapshot.hasError) return Text('Something went wrong');
              if (eventSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return ListView(
                children: eventSnapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  List<dynamic> comments = data['comments'] ?? [];
                  Map<String, dynamic> ratings = data['ratings']?.cast<String, dynamic>() ?? {};
                  bool hasRated = ratings.containsKey(currentUserName);
                  double avgScore = hasRated ? ratings[currentUserName] : 0.0;

                  return Card(
                    child: ExpansionTile(
                      leading: Image.asset('assets/images/event.png', width: 40),
                      title: Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${AppLocalizations.of(context)!.dateTime}: ${DateFormat('yyyy-MM-dd – kk:mm').format(data['time'].toDate())}"),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child: Center(
                            child: Text(data['description'] ?? 'No description provided', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        _buildCommentsSection(comments, document.id, currentUserName),
                        Divider(),
                        StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return FutureBuilder<double>(
                              future: _calculateAverageScore(ratings),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                if (snapshot.hasError || !snapshot.hasData) {
                                  return Text("Failed to calculate average rating");
                                }
                                double avgScore = snapshot.data!;
                                return Column(
                                  children: [
                                    Text('${AppLocalizations.of(context)!.averageRating} ${avgScore.toStringAsFixed(1)}', style: TextStyle(fontWeight: FontWeight.bold)),
                                    if (!hasRated)
                                      RatingBar.builder(
                                        initialRating: avgScore,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                        itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                                        onRatingUpdate: (rating) {
                                          setState(() {
                                            ratings[currentUserName] = rating;
                                            FirebaseFirestore.instance.collection('Events').doc(document.id).update({
                                              'ratings': ratings
                                            });
                                          });
                                        },
                                      ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
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






