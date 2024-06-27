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



  Widget titleText() {
    return Text(
      "Merhaba, \nHosgeldin",
      style: CustomTextStyle.titleTextStyle,
    );
  }

  Widget customSizedBox({double height = 20.0}) => SizedBox(height: height);


  Widget emailTextField() {
    return TextFormField(
      controller: emailController,
      validator: (value) => emailValidator(value),
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Email"),
      onSaved: (value) => email = value!,
    );
  }

  Widget fullNameTextField() {
    return TextFormField(
      controller: fullNameController,
      validator: (value) => fullNameValidator(value),
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Ad Soyad"),
      onSaved: (value) => fullname = value!,
    );
  }

  Widget usernameTextField() {
    return TextFormField(
      controller: usernameController,
      validator: (value) => usernameValidator(value),
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Kullanici Adi"),
      onSaved: (value) => username = value!,
    );
  }

  Widget passwordTextField() {
    return TextFormField(
      controller: passwordController,
      validator: (value) => passwordValidator(value),
      obscureText: true,
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Şifre"),
      onSaved: (value) => password = value!,
    );
  }

  Widget confirmPasswordTextField() {
    return TextFormField(
      controller: confirmPasswordController,
      validator: (value) => confirmPasswordValidator(value, passwordController.text),
      obscureText: true,
      style: TextStyle(color: Colors.white),
      decoration: customInputDecoration("Confirm Password"),
      onSaved: (value) => confirmPassword = value!,
    );
  }

  Widget validationInfo() {
    return Column(
      children: [
        buildValidationRow("Password must be at least 6 characters.", passwordValid),
        buildValidationRow("Passwords must match.", confirmPasswordValid),
        buildValidationRow("Email must contain '@'.", emailValid),
        buildValidationRow("Full Name must be within 20 characters and contain a space.", fullNameValid),
        buildValidationRow("Username must be within 20 characters.", usernameValid),
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
      return "Please enter a valid email with '@'.";
    }
    return null;
  }

  String? fullNameValidator(String? value) {
    if (value!.isEmpty || !value.contains(" ") || value.length > 20) {
      return "Full Name should include a space and be max 20 characters.";
    }
    return null;
  }

  String? usernameValidator(String? value) {
    if (value!.isEmpty || value.length > 20) {
      return "Username should be max 20 characters.";
    }
    return null;
  }

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

  Widget signUpButton() {
    return Center(
      child: TextButton(
        onPressed: signUp,
        child: customText("Hesap Olustur", CustomColors.pinkColor),
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

  Widget backToLoginPage() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, "/loginPage"),
        child: customText("Giris Sayfasina Geri Don", CustomColors.pinkColor),
      ),
    );
  }

  Widget customText(String text, Color color) => Text(text, style: TextStyle(color: color));

  InputDecoration customInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
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
