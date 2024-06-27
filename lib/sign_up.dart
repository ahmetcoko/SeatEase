import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seat_ease/login_page.dart';
import 'package:seat_ease/utils/customColors.dart';
import 'package:seat_ease/utils/customTextStyle.dart';
import 'home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late String email, fullname, username, password;
  final formkey = GlobalKey<FormState>();
  final firebaseAuth = FirebaseAuth.instance;
  final authService = FirebaseAuth.instance;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleText(),
                    customSizedBox(),
                    emailTextField(),
                    customSizedBox(),
                    fullNameTextField(),
                    customSizedBox(),
                    usernameTextField(),
                    customSizedBox(),
                    passwordTextField(),
                    customSizedBox(),
                    signUpButton(),
                    customSizedBox(),
                    backToLoginPage()
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
      "Merhaba, \nHosgeldin",
      style: CustomTextStyle.titleTextStyle,
    );
  }

  TextFormField emailTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bilgileri Eksiksiz Doldurunuz";
        } else {}
      },
      onSaved: (value) {
        email = value!;
      },
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Email"),
    );
  }

  TextFormField fullNameTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bilgileri Eksiksiz Doldurunuz";
        } else {}
      },
      onSaved: (value) {
        fullname = value!;
      },
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Ad Soyad"),
    );
  }

  TextFormField usernameTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bilgileri Eksiksiz Doldurunuz";
        } else {}
      },
      onSaved: (value) {
        username = value!;
      },
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Kullanici Adi"),
    );
  }

  TextFormField passwordTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bilgileri Eksiksiz Doldurunuz";
        } else {}
      },
      onSaved: (value) {
        password = value!;
      },
      obscureText: true,
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Sifre"),
    );
  }

  Center signUpButton() {
    return Center(
      child: TextButton(
        onPressed: signUp,
        child: customText(
          "Hesap Olustur",
          CustomColors.pinkColor,
        ),
      ),
    );
  }

  void signUp() async {
    if (formkey.currentState!.validate()) {
      formkey.currentState!.save();
      try {
        // Create user with email and password
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save additional details in Firestore under the 'Users' collection
        FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).set({
          'fullname': fullname,
          'username': username,
          'email': email,
          // Any other user details you might want to save
        }).then((value) {
          print("User Added to Firestore");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
          );
        }).catchError((error) {
          print("Failed to add user: $error");
        });

      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }


  Center backToLoginPage() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, "/loginPage"),
        child: customText(
          "Giris Sayfasina Geri Don",
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

  // Email Validator
  String? emailValidator(String? value) {
    if (value!.isEmpty || !value.contains("@")) {
      return "Please enter a valid email with '@'.";
    }
    return null;
  }

// Full Name Validator
  String? fullNameValidator(String? value) {
    if (value!.isEmpty || !value.contains(" ") || value.length > 20) {
      return "Full Name should include a space and be max 20 characters.";
    }
    return null;
  }

// Username Validator
  String? usernameValidator(String? value) {
    if (value!.isEmpty || value.length > 20) {
      return "Username should be max 20 characters.";
    }
    return null;
  }

// Password Validator
  String? passwordValidator(String? value) {
    if (value!.isEmpty || value.length < 6) {
      return "Password should be more than 6 characters.";
    }
    return null;
  }

// Confirm Password Validator
  String? confirmPasswordValidator(String? value) {
    if (value != password) {
      return "Passwords do not match.";
    }
    return null;
  }

  Widget validationIcon(bool isValid) {
    String iconName = isValid ? 'assets/tick.png' : 'assets/cross.png';
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Image.asset(iconName, width: 20, height: 20),
    );
  }

}