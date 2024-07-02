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
    radius: profileHeight/2, // Arbitrary radius for profile image
    backgroundColor: Colors.grey.shade800,
    backgroundImage: NetworkImage(_profileImageUrl!),
  );

  @override
  Widget build(BuildContext context) {
    double coverHeight = 280; // Height for cover image
    double profileHeight = 144; // Double the radius for profile image
    double top = coverHeight - profileHeight / 2; // Calculate top position for profile image

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
          buildCoverImage(),
          Positioned(
            top: top,
            child: GestureDetector(
              onTap: _pickImage, // Call _pickImage when profile image is tapped
              child: buildProfileImage(),
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

