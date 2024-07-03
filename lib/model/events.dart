import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String name;
  final DateTime dateTime;
  final int capacity;
  final String description;
  final List<String> participants;

  Event({
    required this.name,
    required this.dateTime,
    required this.capacity,
    required this.description,
    required this.participants,
  });

  factory Event.fromFirestore(Map<String, dynamic> data) {
    return Event(
      name: data['name'],
      dateTime: (data['time'] as Timestamp).toDate(),
      capacity: data['capacity'],
      description: data['description'],
      participants: List<String>.from(data['participants']),
    );
  }

}
