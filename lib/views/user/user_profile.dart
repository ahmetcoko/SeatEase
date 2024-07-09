import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seat_ease/l10n/app_localizations.dart';
import 'package:seat_ease/views/user/user_setting_page.dart';
import '../splash/login_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final double coverHeight = 280;
  final double profileHeight = 144;
  File? _image;
  final picker = ImagePicker();
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }


  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File tempImage = File(pickedFile.path);
        setState(() {
          _image = tempImage; // Temporarily display selected image
        });
        await _uploadProfilePicture(tempImage); // Ensure upload completes before setting state
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Failed to pick image: $e");
    }
  }


  Future<void> _uploadProfilePicture(File image) async {
    print("Starting upload of profile picture.");
    String userId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('profile_pictures').child(userId);

    try {
      UploadTask uploadTask = ref.putFile(image);
      // Listen to the upload task for progress reporting
      uploadTask.snapshotEvents.listen(
              (TaskSnapshot snapshot) {
            print("Task state: ${snapshot.state}, bytes uploaded: ${snapshot.bytesTransferred} / ${snapshot.totalBytes}");
          },
          onError: (e) {
            print("Upload failed with error: $e");
          },
          onDone: () async {
            print("Upload completed.");
            try {
              String downloadURL = await ref.getDownloadURL();
              print("Download URL: $downloadURL");
              await FirebaseFirestore.instance.collection('Users').doc(userId).update({
                'profilePicture': downloadURL
              });
              if (mounted) {
                setState(() {
                  _profileImageUrl = downloadURL; // Update displayed image only if the widget is mounted
                });
              }
            } catch (e) {
              print("Failed to get download URL or update Firestore: $e");
            }
          }
      );
    } catch (e, s) {
      print("Failed to initiate upload task: $e");
      print("Stack trace: $s");
    }
  }




  Future<void> _loadProfilePicture() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Safe access with null check and fallback
    if (userId.isEmpty) {
      print("No user ID available");
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data()! as Map<String, dynamic>;
        if (userData.containsKey('profilePicture') && mounted) { // Check if the widget is still mounted
          setState(() {
            _profileImageUrl = userData['profilePicture'] as String;
          });
        }
      }
    } catch (e) {
      print("Failed to load profile picture: $e");
    }
  }



  Widget buildCoverImage() => Container(
    color: Colors.grey,
    child: Image.asset(
      'assets/images/devent.jpg', // Path to the image in your assets directory
      width: double.infinity,
      height: coverHeight, // Arbitrary height for cover image
      fit: BoxFit.cover,
    ),
  );


  Widget buildProfileImage() => CircleAvatar(
    radius: profileHeight / 2,
    backgroundColor: Colors.grey.shade800,
    backgroundImage: _profileImageUrl != null
        ? CachedNetworkImageProvider(_profileImageUrl!)
        : AssetImage('assets/images/event.png'),
  );


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



  @override
  Widget build(BuildContext context) {
    double coverHeight = 280;
    double profileHeight = 144;
    double top = coverHeight - profileHeight / 2;
    double bottomListTop = top + profileHeight / 2 + 20; // Added a 20 pixel space for clarity

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userProfileTitle),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SettingsUserPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Container(
                height: coverHeight,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/devent.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: profileHeight / 2 + 20), // Added a 20 pixel space for clarity
              Expanded(
                child: FutureBuilder<String>(
                  future: _fetchUserFullName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(child: Text("Failed to fetch user data or user not found"));
                    }
                    String currentUserName = snapshot.data!;
                    // Continue with your logic here once the data is available
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('Events').orderBy('time').snapshots(),
                      builder: (context, eventSnapshot) {
                        if (eventSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Ensure this also handles loading gracefully
                        }
                        if (eventSnapshot.hasError) {
                          return Text('Something went wrong');
                        }
                        if (eventSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        var joinedEvents = eventSnapshot.data!.docs.where((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                          return data['participants'].any((participant) => participant['name'] == currentUserName);
                        }).toList();

                        if (joinedEvents.isEmpty) {
                          return Center(child: Text(AppLocalizations.of(context)!.infoEvents));
                        }
                        return ListView(
                          children: eventSnapshot.data!.docs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            bool isUserJoined = data['participants'].any((participant) => participant['name'] == currentUserName);
                            if (!isUserJoined) return Container(); // Skip events the user hasn't joined

                            // Extract user's seat for the cancellation function
                            String userSeat = data['participants'].firstWhere((p) => p['name'] == currentUserName, orElse: () => {'seat': null})['seat'];

                            return Card(
                              child: ExpansionTile(
                                leading: Image.asset('assets/images/event.png', width: 40),
                                title: Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("${AppLocalizations.of(context)!.dateTime}: ${DateFormat('yyyy-MM-dd – kk:mm').format(data['time'].toDate())}"),
                                children: <Widget>[
                                  ElevatedButton(
                                    onPressed: () => _cancelReservation(document.id, currentUserName , userSeat),
                                    child: Text(
                                      AppLocalizations.of(context)!.cancelReservation,
                                      style: TextStyle(
                                        color: Colors.pinkAccent,
                                      ),
                                    ),
                                  ),
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(AppLocalizations.of(context)!.seat, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        data['participants']
                                            .firstWhere((participant) => participant['name'] == currentUserName, orElse: () => {'seat': 'No Seat Assigned'})['seat'],
                                        style: TextStyle(fontSize: 14),
                                      ),
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
              ),
            ],
          ),
          Positioned(
            top: top,
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: profileHeight / 2,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : AssetImage('assets/placeholder.jpg'),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _cancelReservation(String documentId, String userName, String userSeat) {
    FirebaseFirestore.instance.collection('Events').doc(documentId).update({
      'participants': FieldValue.arrayRemove([
        {'name': userName, 'seat': userSeat}
      ])
    }).then((_) {
      print("Reservation canceled successfully.");
      setState(() {}); // Refresh the UI to reflect the removal
    }).catchError((error) {
      print("Failed to cancel reservation: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to cancel reservation: $error")));
    });
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logout failed: ${error.toString()}")));
    });
  }
}
