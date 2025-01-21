// ignore_for_file: non_constant_identifier_names, file_names, prefer_typing_uninitialized_variables, must_be_immutable

import 'package:event_management/screens/EnrolledStudentList.dart';
import 'package:flutter/material.dart';

class EnrollStudentCategory extends StatefulWidget {
  var eventDetails;
  var regularStudentDetails;
  var alumniStudentDetails;
  var isPastEvent;
  var regularStudentAttendedCount;
  var alumniStudentAttendedCount;
  EnrollStudentCategory(
      {required this.eventDetails,
      required this.regularStudentDetails,
      required this.alumniStudentDetails,
      required this.isPastEvent,
      required this.regularStudentAttendedCount,
      required this.alumniStudentAttendedCount,
      super.key});

  @override
  State<StatefulWidget> createState() => _EnrollStudentsCategory();
}

class _EnrollStudentsCategory extends State<EnrollStudentCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allows the body to extend behind the AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Makes the AppBar transparent
        elevation: 0, // Removes the shadow
        title: const Text(
          "Folders...",
          style: TextStyle(
            color: Color(0xFF7464bc), // Sets the title text color
            fontWeight: FontWeight.bold, // Optional: makes the text bold
            fontSize: 20, // Optional: sets the font size
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF7464bc), // Sets the icon color (e.g., back button)
        ),
      ),
      body: Stack(
        children: [
          Container(
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
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(),
                  child: ListTile(
                    leading: const Icon(
                      Icons.folder,
                      color: Color(0xFF7464bc),
                    ),
                    title: const Text(
                      "Regular Students",
                      style: TextStyle(
                        color: Color(0xFF7464bc),
                        fontSize: 18,
                      ),
                    ),
                    subtitle: const Text(
                      'Student details go here',
                      style: TextStyle(
                        color: Color(0xFF7464bc),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10),
                          child: widget.isPastEvent
                              ? Text(
                            "${widget.regularStudentAttendedCount}",
                            style: const TextStyle(
                                color: Color.fromARGB(255, 100, 188, 109),
                                fontSize: 18),
                          )
                              : const Center(),
                        ),
                        Text(
                          widget.isPastEvent?"/  ${widget.regularStudentDetails.length}":"${widget.regularStudentDetails.length}",
                          style: const TextStyle(
                              color: Color(0xFF7464bc), fontSize: 18),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF7464bc),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  EnrollStudentList(
                            regular: true,
                            eventDetails: widget.eventDetails,
                            regularStudentDetails: widget.regularStudentDetails,
                            alumniStudentDetails: widget.alumniStudentDetails,
                                    isPastEvent: widget.isPastEvent,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    splashColor: const Color(0x91a291da),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(),
                  child: ListTile(
                    leading: const Icon(
                      Icons.folder,
                      color: Color(0xFF7464bc),
                    ),
                    title: const Text(
                      "Alumni Students",
                      style: TextStyle(
                        color: Color(0xFF7464bc),
                        fontSize: 18,
                      ),
                    ),
                    subtitle: const Text(
                      'Student details go here',
                      style: TextStyle(
                        color: Color(0xFF7464bc),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10),
                          child: widget.isPastEvent
                              ? Text(
                            "${widget.alumniStudentAttendedCount}",
                            style: const TextStyle(
                                color: Color.fromARGB(255, 100, 188, 109),
                                fontSize: 18),
                          )
                              : const Center(),
                        ),
                        Text(
                          widget.isPastEvent?"/  ${widget.alumniStudentDetails.length}":"${widget.alumniStudentDetails.length}",
                          style: const TextStyle(
                              color: Color(0xFF7464bc), fontSize: 18),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF7464bc),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  EnrollStudentList(
                            regular: false,
                            eventDetails: widget.eventDetails,
                            regularStudentDetails: widget.regularStudentDetails,
                            alumniStudentDetails: widget.alumniStudentDetails,
                                    isPastEvent: widget.isPastEvent,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    splashColor: const Color(0x91a291da),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
