import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seat_ease/l10n/app_localizations.dart';
import 'package:seat_ease/views/splash/login_page.dart';
import 'package:seat_ease/utils/customColors.dart';
import 'package:seat_ease/utils/customTextStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = '', fullname = '', username = '', password = '', confirmPassword = '';
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  // Controllers for text fields
  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Validation flags
  bool emailValid = false;
  bool fullNameValid = false;
  bool usernameValid = false;
  bool passwordValid = false;
  bool confirmPasswordValid = false;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    String topImage = "assets/images/topImage.png";
    return Scaffold(
      body: SafeArea(  // Ensure content does not overlap with system status or navigation bars
        child: appBody(height, topImage),
      ),
    );
  }

  SingleChildScrollView appBody(double height, String topImage) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 20), // Add padding to ensure content is above any system UI or watermarks
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
                    confirmPasswordTextField(),
                    validationInfo(),
                    customSizedBox(),
                    signUpButton(),
                    customSizedBox(height: 48), // Increased space before the bottom navigation or watermark
                    backToLoginPage(),
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

  Widget customSizedBox({double height = 20.0}) => SizedBox(height: height);


  TextFormField emailTextField() {
    return TextFormField(
      controller: emailController,
      validator: emailValidator,
      style: TextStyle(color: Colors.black), // Ensure text color is black for visibility
      decoration: customInputDecoration(AppLocalizations.of(context)!.email),
      onSaved: (value) => email = value!,
    );
  }

  TextFormField fullNameTextField() {
    return TextFormField(
      controller: fullNameController,
      validator: fullNameValidator,
      style: TextStyle(color: Colors.black), // Ensure text color is black for visibility
      decoration: customInputDecoration(AppLocalizations.of(context)!.fullName),
      onSaved: (value) => fullname = value!,
    );
  }

  TextFormField usernameTextField() {
    return TextFormField(
      controller: usernameController,
      validator: usernameValidator,
      style: TextStyle(color: Colors.black), // Ensure text color is black for visibility
      decoration: customInputDecoration(AppLocalizations.of(context)!.username),
      onSaved: (value) => username = value!,
    );
  }

  TextFormField passwordTextField() {
    return TextFormField(
      controller: passwordController,
      validator: passwordValidator,
      obscureText: true,
      style: TextStyle(color: Colors.black), // Ensure text color is black for visibility
      decoration: customInputDecoration(AppLocalizations.of(context)!.password),
      onSaved: (value) => password = value!,
    );
  }

  TextFormField confirmPasswordTextField() {
    return TextFormField(
      controller: confirmPasswordController,
      validator: (value) => confirmPasswordValidator(value, passwordController.text),
      obscureText: true,
      style: TextStyle(color: Colors.black), // Ensure text color is black for visibility
      decoration: customInputDecoration(AppLocalizations.of(context)!.confirmPassword),
      onSaved: (value) => confirmPassword = value!,
    );
  }

  Widget validationInfo() {
    return Column(
      children: [
        buildValidationRow(AppLocalizations.of(context)!.passwordValidation, passwordValid),
        buildValidationRow(AppLocalizations.of(context)!.confirmPasswordValidation, confirmPasswordValid),
        buildValidationRow(AppLocalizations.of(context)!.emailValidation, emailValid),
        buildValidationRow(AppLocalizations.of(context)!.fullNameValidation, fullNameValid),
        buildValidationRow(AppLocalizations.of(context)!.usernameValidation, usernameValid),
      ],
    );
  }

  Widget buildValidationRow(String text, bool isValid) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded( // Wrap the text with Expanded
          child: Text(text, style: TextStyle(color: Colors.grey[600])),
        ),
        Icon(isValid ? Icons.check : Icons.close, color: isValid ? Colors.green : Colors.red),
      ],
    );
  }


  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() => emailValid = emailValidator(emailController.text) == null));
    fullNameController.addListener(() => setState(() => fullNameValid = fullNameValidator(fullNameController.text) == null));
    usernameController.addListener(() => setState(() => usernameValid = usernameValidator(usernameController.text) == null));
    passwordController.addListener(() => setState(() => passwordValid = passwordValidator(passwordController.text) == null));
    confirmPasswordController.addListener(() => setState(() => confirmPasswordValid = confirmPasswordValidator(confirmPasswordController.text, passwordController.text) == null));
  }

  @override
  void dispose() {
    emailController.dispose();
    fullNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Validators
  String? emailValidator(String? value) {
    if (value!.isEmpty || !value.contains("@")) {
      return AppLocalizations.of(context)!.emailValidation;
    }
    return null;
  }

  String? fullNameValidator(String? value) {
    if (value!.isEmpty || !value.contains(" ") || value.length > 20) {
      return AppLocalizations.of(context)!.fullNameValidation;
    }
    return null;
  }

  String? usernameValidator(String? value) {
    if (value!.isEmpty || value.length > 20) {
      return AppLocalizations.of(context)!.usernameValidation;
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    } else if (value.length < 6) {
      return AppLocalizations.of(context)!.passwordValidation;
    }
    return null;
  }

  String? confirmPasswordValidator(String? value, String password) {
    if (value!.isEmpty) {
      return AppLocalizations.of(context)!.passwordValidationRequest;
    } else if (value != password) {
      return AppLocalizations.of(context)!.confirmPasswordValidation;
    }
    return null;
  }

  Widget signUpButton() {
    return Center(
      child: ElevatedButton(
        onPressed: signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor, // Use secondary color from theme
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          minimumSize: Size(150, 50),
        ),
        child: Text(
          AppLocalizations.of(context)!.createAccount,
          style: TextStyle(
            color: Colors.pinkAccent, // Ensuring text is visible against the button color
          ),
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
          'usertype': 'normalUser',
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

  Widget backToLoginPage() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, "/loginPage"),
        child: customText(AppLocalizations.of(context)!.backToLogin, CustomColors.pinkColor),
      ),
    );
  }

  Widget customText(String text, Color color) => Text(text, style: TextStyle(color: color));

  InputDecoration customInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey),  // Hint text color
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.pinkAccent),
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
}
