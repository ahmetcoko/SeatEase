import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadProfilePicture();
    }
  }

  Future<void> _uploadProfilePicture() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'profilePicture': _image!.path
    }).catchError((error) {
      print("Failed to update profile picture: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _logout(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2, // Proportion of screen for the event photo
            child: Stack(
              alignment: Alignment.bottomCenter, // Ensure alignment is centered at the bottom
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
                  bottom: -50, // Position to half the diameter of the CircleAvatar to align its center with the container's bottom
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : AssetImage('assets/images/profile_placeholder.png'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3, // Proportion of screen for profile details
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


