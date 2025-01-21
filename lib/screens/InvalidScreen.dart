import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class InvalidScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _InvalidScreen();

}

class _InvalidScreen extends State<InvalidScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Invalid Entry...",
          style: TextStyle(
            color: Color(0xFF7464bc), // Sets the title text color
            fontWeight: FontWeight.bold, // Optional: makes the text bold
            fontSize: 20, // Optional: sets the font size
          ),
        ),
        backgroundColor: Colors.transparent, // Makes the AppBar transparent
        elevation: 0, // Removes the shadow
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFded9ee),
              Color(0xe2e9e6ef),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(
                'asset/gif/invalid.json', // Path to your Lottie file
                width: 225, // Adjust width as needed
                height: 225, // Adjust height as needed
                fit: BoxFit.fill,
                repeat: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}