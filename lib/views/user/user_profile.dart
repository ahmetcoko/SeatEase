import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    print("Initializing user profile page.");
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
        print("Image picked: ${tempImage.path}");
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
              setState(() {
                _profileImageUrl = downloadURL; // Update displayed image
              });
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
    backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : AssetImage('assets/placeholder.jpg'), // Fallback to a local asset
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
        title: Text("Profile"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
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
              SizedBox(height: profileHeight / 2 + 20), // Make space for the overlapping part of the profile image
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
                      stream: FirebaseFirestore.instance.collection('Events').orderBy('time').snapshots(),
                      builder: (context, eventSnapshot) {
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
                          return Center(child: Text("You haven't joined any events"));
                        }
                        return ListView(
                          children: eventSnapshot.data!.docs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            return Card(
                              child: ExpansionTile(
                                leading: Image.asset('assets/images/event.png', width: 40),
                                title: Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("Date-Time: ${DateFormat('yyyy-MM-dd – kk:mm').format(data['time'].toDate())}"),
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                                    child: Center(
                                      child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(data['description'] ?? 'No description provided'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text("Seat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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









  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logout failed: ${error.toString()}")));
    });
  }
}

