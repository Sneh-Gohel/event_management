// ignore_for_file: use_build_context_synchronously

import 'package:event_management/screens/EventlistScreen.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final user_id_Controller = TextEditingController();
  final password_Controller = TextEditingController();
  var show_password_bool = true;
  final user_id = FocusNode();
  final password = FocusNode();
  bool showContent = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showContent = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onLoginButtonPressed() async {
    if (user_id_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(user_id);
      return;
    }

    if (password_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(password);
      return;
    }

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('Login')
        .doc('LoginCredential')
        .get();
    var data = docSnapshot.data() as Map<String, dynamic>;

    if (data['userName'] == user_id_Controller.text) {
      if (data['password'] == password_Controller.text) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const EventlistScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      } else {
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Warning!',
            message: 'Please make sure to check your ID and password.',
            contentType: ContentType.warning,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } else {
      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'On Snap!',
          message: 'Please! Check your ID, Password once.',
          contentType: ContentType.warning,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }

    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff3f3f9c), // New vibrant blue
              Color(0xFF8e75e4), // Soft purple
            ],
          ),
        ),
        child: ListView(
          children: [
            const Padding(padding: EdgeInsets.symmetric(vertical: 30)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Hero(
                tag: 'logo',
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFded9ee), // Light lavender
                        spreadRadius: 10,
                        blurRadius: 20,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  height: 175,
                  width: 175,
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
            AnimatedOpacity(
              opacity: showContent ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    child: Container(
                      child: const Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                              color: Color(0xFFded9ee),
                              fontSize: 56,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 24, left: 40, right: 40),
                    child: TextField(
                      controller: user_id_Controller,
                      focusNode: user_id,
                      onEditingComplete: () {
                        if (password_Controller.text == "") {
                          FocusScope.of(context).requestFocus(password);
                        } else {
                          user_id.unfocus();
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.person, color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            user_id_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "User Name",
                        hintStyle: TextStyle(
                            color: Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 40, left: 40, right: 40),
                    child: TextField(
                      controller: password_Controller,
                      focusNode: password,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: show_password_bool,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.key, color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child: Icon(
                              show_password_bool
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color(0xFF7464bc)),
                          onTap: () {
                            setState(() {
                              show_password_bool = !show_password_bool;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Password",
                        hintStyle: TextStyle(
                            color: Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 50, left: 50, right: 50),
                    child: ScaleTransition(
                      scale: _animation,
                      child: ElevatedButton(
                        onPressed: _onLoginButtonPressed,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          backgroundColor: const Color(0xFF8e75e4),
                          shape: const StadiumBorder(), // Soft purple
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 25,
                                color: Color(0xFFEAE7DD)), // Light lavender
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
