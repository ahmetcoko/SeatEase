import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../splash/login_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
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
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data()! as Map<String, dynamic>;  // Cast to Map<String, dynamic>
        if (userData.containsKey('profilePicture')) {
          setState(() {
            _profileImageUrl = userData['profilePicture'] as String;  // Cast for safety, although usually not necessary
          });
        }
      }
    } catch (e) {
      print("Failed to load profile picture: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/devent.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: Center(
                child: Text("Profile details and more info here."),
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

