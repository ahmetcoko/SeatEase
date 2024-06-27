import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seat_ease/login_page.dart';
import 'package:seat_ease/utils/customColors.dart';
import 'package:seat_ease/utils/customTextStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = '', fullname = '', username = '', password = '', confirmPassword = '';  // Changed to initial empty strings
  final formkey = GlobalKey<FormState>();
  final firebaseAuth = FirebaseAuth.instance;
  final authService = FirebaseAuth.instance;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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
                    confirmPasswordTextField(),  // Add this method call here
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

  TextFormField confirmPasswordTextField() {
    return TextFormField(
      controller: confirmPasswordController,
      validator: (value) => confirmPasswordValidator(value, passwordController.text),
      obscureText: true,
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Confirm Password"),
      onSaved: (value) => confirmPassword = value!,  // Add this line
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

  @override
  void initState() {
    super.initState();
    // Setup listeners to trigger form validation on change
    passwordController.addListener(validatePassword);
    confirmPasswordController.addListener(validatePassword);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void validatePassword() {
    // Trigger validation logic for confirmPassword field
    formkey.currentState?.validate();
  }

  TextFormField passwordTextField() {
    return TextFormField(
      controller: passwordController,
      validator: passwordValidator,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Şifre"),
      onSaved: (value) => password = value!,
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
    if (formkey.currentState!.validate()) { // Check if form inputs pass the validation rules
      formkey.currentState!.save(); // Save the form data to the respective variables

      // Check if the passwords match, ensuring `password` and `confirmPassword` are not empty
      if (password.isNotEmpty && confirmPassword.isNotEmpty && confirmPassword == password) {
        try {
          // Attempt to create a user with the provided email and password
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Upon successful user creation, store additional user details in Firestore
          FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).set({
            'fullname': fullname,
            'username': username,
            'email': email,
          }).then((value) {
            // Navigate to the LoginPage after successful registration and data storage
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
            );
          }).catchError((error) {
            // Handle errors related to Firestore operations
            print("Failed to add user to Firestore: $error");
            showErrorDialog("Error saving data", "Failed to save user details.");
          });

        } on FirebaseAuthException catch (e) {
          // Handle errors related to Firebase authentication
          if (e.code == 'weak-password') {
            showErrorDialog("Weak Password", "The password provided is too weak.");
          } else if (e.code == 'email-already-in-use') {
            showErrorDialog("Email Already in Use", "The account already exists for that email.");
          } else {
            showErrorDialog("Authentication Error", e.message ?? "An unexpected error occurred.");
          }
        } catch (e) {
          // Handle any other errors that might occur
          showErrorDialog("Error", e.toString());
        }
      } else {
        // Handle the case where passwords do not match
        showErrorDialog("Password Mismatch", "The passwords do not match. Please try again.");
      }
    }
  }

  void showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
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
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value, String password) {
    if (value!.isEmpty) {
      return "Please confirm your password.";
    } else if (value != password) {
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