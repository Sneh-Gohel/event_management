import 'package:event_management/screens/AddGuestScreen.dart';
import 'package:event_management/screens/GuestDetailsScreen.dart';
import 'package:event_management/screens/QuickAddScreen.dart';
import 'package:flutter/material.dart';

class EnrolledGuestList extends StatefulWidget {
  var eventDetails;
  var guestDetails;
  var isPastEvent;
  EnrolledGuestList({
    required this.eventDetails,
    required this.guestDetails,
    required this.isPastEvent,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _EnrolledGuestList();
}

class _EnrolledGuestList extends State<EnrolledGuestList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Guest List...",
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
                delegate: GuestSearchDelegate(
                  guests: widget.guestDetails,
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
                          searchFor: "Guest",
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
            child: widget.guestDetails.length == 0
                ? const Center(
              child: Text(
                'No guests are enrolled...',
                style: TextStyle(
                  color: Color(0xFF7464bc),
                  fontSize: 18,
                ),
              ),
            )
                : ListView.builder(
              itemCount: widget.guestDetails.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    Icons.perm_contact_calendar_sharp,
                    color: widget.isPastEvent &&
                        widget.guestDetails[index]['attended'] == "yes"
                        ? const Color.fromARGB(255, 100, 188, 109)
                        : const Color(0xFF7464bc),
                  ),
                  title: Text(
                    widget.guestDetails[index]['name'],
                    style: TextStyle(
                      color: widget.isPastEvent &&
                          widget.guestDetails[index]['attended'] == "yes"
                          ? const Color.fromARGB(255, 100, 188, 109)
                          : const Color(0xFF7464bc),
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Guest details go here.',
                    style: TextStyle(
                      color: widget.isPastEvent &&
                          widget.guestDetails[index]['attended'] == "yes"
                          ? const Color.fromARGB(255, 100, 188, 109)
                          : const Color(0xFF7464bc),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: widget.isPastEvent &&
                        widget.guestDetails[index]['attended'] == "yes"
                        ? const Color.fromARGB(255, 100, 188, 109)
                        : const Color(0xFF7464bc),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            GuestDetailsScreen(
                              guestDetails: widget.guestDetails[index],
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
                        AddGuestScreen(
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

// SearchDelegate for searching guests by name and email
class GuestSearchDelegate extends SearchDelegate {
  final List guests;
  final bool isPastEvent;

  GuestSearchDelegate({
    required this.guests,
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
    List filteredGuests = guests
        .where((guest) =>
    guest['name'].toLowerCase().contains(query.toLowerCase()) ||
        guest['email'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return filteredGuests.isEmpty
        ? const Center(
      child: Text('No guests found'),
    )
        : ListView.builder(
      itemCount: filteredGuests.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredGuests[index]['name']),
          subtitle: Text(filteredGuests[index]['email']),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    GuestDetailsScreen(
                      guestDetails: filteredGuests[index],
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
