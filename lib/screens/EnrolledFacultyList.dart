import 'package:event_management/screens/AddFacultyScreen.dart';
import 'package:event_management/screens/FacultyDetailsScreen.dart';
import 'package:event_management/screens/QuickAddScreen.dart';
import 'package:flutter/material.dart';

class EnrolledFacultyList extends StatefulWidget {
  var eventDetails;
  var facultyDetails;
  var isPastEvent;

  EnrolledFacultyList(
      {required this.eventDetails,
        required this.facultyDetails,
        required this.isPastEvent,
        super.key});

  @override
  State<StatefulWidget> createState() => _EnrolledFacultyList();
}

class _EnrolledFacultyList extends State<EnrolledFacultyList> {
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
          "Faculty List...",
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
                delegate: FacultySearchDelegate(
                  facultyDetails: widget.facultyDetails,
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
                          searchFor: "Faculty",
                          eventDetails: widget.eventDetails,
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
            child: widget.facultyDetails.length == 0
                ? const Center(
              child: Text(
                'No faculties are enrolled...',
                style: TextStyle(
                  color: Color(0xFF7464bc),
                  fontSize: 18,
                ),
              ),
            )
                : ListView.builder(
              itemCount: widget.facultyDetails.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    Icons.person_2,
                    color: widget.isPastEvent
                        ? widget.facultyDetails[index]['attended'] ==
                        "yes"
                        ? const Color.fromARGB(255, 100, 188, 109)
                        : const Color(0xFF7464bc)
                        : const Color(0xFF7464bc),
                  ),
                  title: Text(
                    widget.facultyDetails[index]['name'],
                    style: TextStyle(
                      color: widget.isPastEvent
                          ? widget.facultyDetails[index]['attended'] ==
                          "yes"
                          ? const Color.fromARGB(255, 100, 188, 109)
                          : const Color(0xFF7464bc)
                          : const Color(0xFF7464bc),
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Faculty details go here.',
                    style: TextStyle(
                      color: widget.isPastEvent
                          ? widget.facultyDetails[index]['attended'] ==
                          "yes"
                          ? const Color.fromARGB(255, 100, 188, 109)
                          : const Color(0xFF7464bc)
                          : const Color(0xFF7464bc),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: widget.isPastEvent
                        ? widget.facultyDetails[index]['attended'] ==
                        "yes"
                        ? const Color.fromARGB(255, 100, 188, 109)
                        : const Color(0xFF7464bc)
                        : const Color(0xFF7464bc),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                            FacultyDetailsScreen(
                                facultyDetails:
                                widget.facultyDetails[index]),
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
                  splashColor: const Color(0x91a291da),
                );
              },
            ),
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
                        AddFacultyScreen(
                          eventDetails: widget.eventDetails,
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
              child: const Center(
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Faculty Search Delegate
class FacultySearchDelegate extends SearchDelegate {
  final List facultyDetails;
  final bool isPastEvent;

  FacultySearchDelegate({required this.facultyDetails, required this.isPastEvent});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List filteredFaculties = facultyDetails
        .where((faculty) =>
    faculty['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
        faculty['email'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();

    return filteredFaculties.isEmpty
        ? const Center(
      child: Text('No faculties found'),
    )
        : ListView.builder(
      itemCount: filteredFaculties.length,
      itemBuilder: (context, index) {
        var faculty = filteredFaculties[index];
        return ListTile(
          leading: Icon(
            Icons.person_2,
            color: isPastEvent && faculty['attended'] == "yes"
                ? const Color.fromARGB(255, 100, 188, 109)
                : const Color(0xFF7464bc),
          ),
          title: Text(
            faculty['name'],
            style: const TextStyle(fontSize: 18),
          ),
          subtitle: Text(faculty['email']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FacultyDetailsScreen(
                  facultyDetails: faculty,
                ),
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
