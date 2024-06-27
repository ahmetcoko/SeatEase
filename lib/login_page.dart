import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seat_ease/reset_password_page.dart';
import 'package:seat_ease/utils/customColors.dart';
import 'package:seat_ease/utils/customTextStyle.dart';
import 'package:seat_ease/widgets/custom_text_button.dart';
import 'home_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String email, password;
  final formkey = GlobalKey<FormState>();
  final firebaseAuth = FirebaseAuth.instance;

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
                      buttonText: "Create Account",
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
      "Welcome to \n    SetEase",
      style: CustomTextStyle.titleTextStyle,
    );
  }

  TextFormField emailTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Check your credentials";
        } else {}
      },
      onSaved: (value) {
        email = value!;
      },
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Email"),
    );
  }

  TextFormField passwordTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Check your credentials";
        } else {}
      },
      onSaved: (value) {
        password = value!;
      },
      obscureText: true,
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Password"),
    );
  }

  Center forgotPasswordButton() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage())),
        child: customText(
          "Forgot Password?",
          CustomColors.pinkColor,
        ),
      ),
    );
  }

  Center signInButton() {
    return Center(
      child: TextButton(
        onPressed: signIn,
        child: Container(
          height: 50,
          width: 150,
          margin: EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Color(0xff31274F)),
          child: Center(
            child: customText("Log-in", CustomColors.loginButtonTextColor),
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
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false);
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
                title: Text("Login Error"),
                content: Text(errorMessage +"." +" Please try again"),
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


  Center signUpButton() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, "/signUp"),
        child: customText(
          "Sign Up",
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
