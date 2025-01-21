import 'package:event_management/screens/LoginScreen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  double blurRadius = 100; // Initial blur radius (large)

  @override
  void initState() {
    super.initState();
    // Start the animation when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        blurRadius = 20; // Final blur radius (small)
      });
    });

    // Navigate to the next screen after a delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500), // Shorter duration
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = 0.0;
            var end = 1.0;
            var curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(), // Adjusted duration for animation
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff3f3f9c),
              Color(0xFF8e75e4),
            ],
          ),
        ),
        child: Center(
          child: Hero(
            tag: 'logo',
            child: AnimatedContainer(
              duration: const Duration(seconds: 1), // Reduce the animation duration
              curve: Curves.easeInOut, // Smooth easing curve
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 235, 211, 248),
                    spreadRadius: 10,
                    blurRadius: blurRadius, // Animate this value
                    offset: const Offset(0, 0), // Zero offset for uniform shadow
                  ),
                ],
              ),
              height: 200,
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    "asset/photos/logo.png",
                    width: 130,
                    height: 130,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}