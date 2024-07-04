import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seat_ease/views/splash/login_page.dart';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Duration of the rotation
      vsync: this,
    )..repeat(); // This causes the animation to repeat indefinitely

    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.linear, // Use a linear curve for constant rotation speed
    );

    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    _controller?.stop(); // Stop the animation when navigating away
  }

  @override
  void dispose() {
    _controller?.dispose(); // Properly dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Set a grey background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RotationTransition(
              turns: _animation!,
              child: Image.asset(
                'assets/images/launcher.png',
                width: 100, // Set a specific size for the image
                height: 100,
              ),
            ),
            SizedBox(height: 30), // Space between the image and the text
            Text(
              'SetEase',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
