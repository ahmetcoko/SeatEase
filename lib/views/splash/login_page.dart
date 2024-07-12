import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:seat_ease/l10n/app_localizations.dart';
import 'package:seat_ease/views/splash/reset_password_page.dart';
import 'package:seat_ease/utils/customColors.dart';
import 'package:seat_ease/utils/custom_text_button.dart';
import 'package:seat_ease/views/user/user_page.dart';
import '../admin/admin_page.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String email, password;
  final formkey = GlobalKey<FormState>();
  final firebaseAuth = FirebaseAuth.instance;
  Map<DateTime, List<dynamic>>? events; // Variable to store fetched events

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    String topImage = "assets/images/topImage.png";
    return Scaffold(
      body: appBody(height, topImage),
    );
  }

  SingleChildScrollView appBody(double height, String topImage) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topImageContainer(height, topImage),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    titleText(),
                    customSizedBox(),
                    emailTextField(),
                    customSizedBox(),
                    passwordTextField(),
                    customSizedBox(),
                    forgotPasswordButton(),
                    customSizedBox(),
                    signInButton(),
                    customSizedBox(),
                    CustomTextButton(
                      onPressed: () => Navigator.pushNamed(context, "/signUp"),
                      buttonText: AppLocalizations.of(context)!.createAccount,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Text titleText() {
    return Text(
      "${AppLocalizations.of(context)!.welcome} \n   SeatEase",
      style: Theme.of(context).textTheme.displayLarge,  // Using the theme's headline1 style
    );
  }


  TextFormField emailTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return AppLocalizations.of(context)!.enterEmail ;
        } else if (!value.contains('@')) {
          return AppLocalizations.of(context)!.emailValidation;
        }
        return null;
      },
      onSaved: (value) {
        email = value!;
      },
      style: TextStyle(color: Colors.black), // Ensuring text color is black for visibility
      decoration: customInputDecoration(AppLocalizations.of(context)!.email),
    );
  }

  TextFormField passwordTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return AppLocalizations.of(context)!.enterPassword;
        }
        return null;
      },
      onSaved: (value) {
        password = value!;
      },
      obscureText: true,
      style: TextStyle(color: Colors.black), // Ensuring text color is black for visibility
      decoration: customInputDecoration(AppLocalizations.of(context)!.password),
    );
  }


  Center forgotPasswordButton() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage())),
        child: customText(
          AppLocalizations.of(context)!.forgotPassword,
          CustomColors.pinkColor,
        ),
      ),
    );
  }

  Center signInButton() {
    return Center(
      child: ElevatedButton(
        onPressed: signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor, // Using the primary color from the theme
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          minimumSize: Size(150, 50),
        ),
        child: Text(
          AppLocalizations.of(context)!.login,
          style: TextStyle(
            color: Colors.pinkAccent, // Assuming you want white text for better contrast
          ),
        ),
      ),
    );
  }



  void signIn() async {
    if (formkey.currentState!.validate()) {
      formkey.currentState!.save();
      try {
        UserCredential result = await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
        if (result.user != null) {
          // Fetch user type from Firestore and cast the data
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(result.user!.uid).get();
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          FirebaseMessaging.instance.subscribeToTopic('allUsers');
          events = await _retrieveEvents();
          if (userDoc.exists && userData['usertype'] == 'admin') {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => AdminPage()),
                    (route) => false);
          } else {
            // Passing events to UserPage via Navigator arguments
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => UserPage(),
                  settings: RouteSettings(arguments: events),  // Pass events here
                ),
                    (route) => false);
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = "An error occurred";
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        }
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.loginError),
                content: Text(errorMessage + "\n" + AppLocalizations.of(context)!.tryAgain)                           ,
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("OK"))
                ],
              );
            });
      }
    }
  }

  Future<Map<DateTime, List<dynamic>>> _retrieveEvents() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Events').get();
    Map<DateTime, List<dynamic>> tempEvents = {};
    for (var doc in snapshot.docs) {
      var data = doc.data();  // Get the data from the document
      if (data is Map<String, dynamic>) {  // Ensure data is correctly cast to Map<String, dynamic>
        Timestamp timestamp = data['time'] as Timestamp? ?? Timestamp.now();  // Use a fallback if null
        DateTime date = timestamp.toDate();
        DateTime dateKey = DateTime(date.year, date.month, date.day);
        tempEvents[dateKey] = tempEvents[dateKey] ?? [];
        tempEvents[dateKey]?.add(data);
      }
    }
    return tempEvents;
  }




  Center signUpButton() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, "/signUp"),
        child: customText(
          AppLocalizations.of(context)!.createAccount,
          CustomColors.pinkColor,
        ),
      ),
    );
  }

  Container topImageContainer(double height, String topImage) {
    return Container(
      height: height * .25,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(topImage),
        ),
      ),
    );
  }

  Widget customSizedBox() => SizedBox(
    height: 20,
  );

  Widget customText(String text, Color color) => Text(
    text,
    style: TextStyle(color: color),
  );

  InputDecoration customInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
    );
  }
}