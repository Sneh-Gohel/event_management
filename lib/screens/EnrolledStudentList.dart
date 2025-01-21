import 'package:event_management/screens/AddStudentScreen.dart';
import 'package:event_management/screens/QuickAddScreen.dart';
import 'package:event_management/screens/StudentDetailsScreen.dart';
import 'package:flutter/material.dart';

class EnrollStudentList extends StatefulWidget {
  bool regular = true;
  var eventDetails;
  var regularStudentDetails;
  var alumniStudentDetails;
  var isPastEvent;

  EnrollStudentList({
    required this.regular,
    required this.eventDetails,
    required this.regularStudentDetails,
    required this.alumniStudentDetails,
    required this.isPastEvent,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _EnrollStudentList();
}

class _EnrollStudentList extends State<EnrollStudentList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Student List...",
          style: TextStyle(
            color: Color(0xFF7464bc),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF7464bc),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: StudentSearchDelegate(
                  students: widget.regular
                      ? widget.regularStudentDetails
                      : widget.alumniStudentDetails,
                  regular: widget.regular,
                  eventDetails: widget.eventDetails,
                  isPastEvent: widget.isPastEvent,
                ),
              );
            },
          ),
          PopupMenuButton(
            offset: const Offset(0, 48),
            color: const Color(0xFFded9ee),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'Quick add',
                  child: Text(
                    'Quick Add',
                    style: TextStyle(color: Color(0xFF7464bc)),
                  ),
                ),
              ];
            },
            onSelected: (value) {
              if (value == "Quick add") {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        QuickAddScreen(
                          searchFor: widget.regular ? "Regular" : "Alumni",
                          eventDetails: widget.eventDetails,
                        ),
                    transitionsBuilder: (context, animation,
                        secondaryAnimation, child) {
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
              }
            },
          ),
        ],
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
            child: widget.regular
                ? _buildStudentList(widget.regularStudentDetails)
                : _buildStudentList(widget.alumniStudentDetails),
          ),
          Positioned(
            bottom: 50,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AddStudentScreen(
                          regular: widget.regular,
                          eventDetails: widget.eventDetails,
                        ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
              child: const Center(
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(List students) {
    return students.isEmpty
        ? const Center(
      child: Text(
        'No students are enrolled...',
        style: TextStyle(
          color: Color(0xFF7464bc),
          fontSize: 18,
        ),
      ),
    )
        : ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(
            Icons.person,
            color: widget.isPastEvent &&
                students[index]['attended'] == "yes"
                ? const Color.fromARGB(255, 100, 188, 109)
                : const Color(0xFF7464bc),
          ),
          title: Text(
            '${students[index]['name']}',
            style: TextStyle(
              color: widget.isPastEvent &&
                  students[index]['attended'] == "yes"
                  ? const Color.fromARGB(255, 100, 188, 109)
                  : const Color(0xFF7464bc),
              fontSize: 18,
            ),
          ),
          subtitle: Text('Student details go here.'),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: widget.isPastEvent &&
                students[index]['attended'] == "yes"
                ? const Color.fromARGB(255, 100, 188, 109)
                : const Color(0xFF7464bc),
          ),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    StudentDetailsScreen(
                      regular: widget.regular,
                      studentInformation: students[index],
                    ),
                transitionsBuilder: (context, animation,
                    secondaryAnimation, child) {
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
        );
      },
    );
  }
}

// SearchDelegate for searching students by name and email
class StudentSearchDelegate extends SearchDelegate {
  final List students;
  final bool regular;
  final eventDetails;
  final bool isPastEvent;

  StudentSearchDelegate({
    required this.students,
    required this.regular,
    required this.eventDetails,
    required this.isPastEvent,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(onPressed: () => close(context, null), icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    List filteredStudents = students
        .where((student) =>
    student['name'].toLowerCase().contains(query.toLowerCase()) ||
        student['email'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return filteredStudents.isEmpty
        ? const Center(
      child: Text('No students found'),
    )
        : ListView.builder(
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredStudents[index]['name']),
          subtitle: Text(filteredStudents[index]['email']),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    StudentDetailsScreen(
                      regular: regular,
                      studentInformation: filteredStudents[index],
                    ),
                transitionsBuilder: (context, animation,
                    secondaryAnimation, child) {
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
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
