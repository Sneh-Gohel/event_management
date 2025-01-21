import 'package:event_management/screens/AddOnSpotEntryScreen.dart';
import 'package:event_management/screens/OnSpotEntryDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'QuickAddScreen.dart';

class EnrolledOnSpotEntryList extends StatefulWidget {
  var eventDetails;
  var onSpotEntryDetails;
  var isPastEvent;

  EnrolledOnSpotEntryList({
    required this.eventDetails,
    required this.onSpotEntryDetails,
    required this.isPastEvent,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _EnrolledOnSpotEntryList();
}

class _EnrolledOnSpotEntryList extends State<EnrolledOnSpotEntryList> {
  List filteredOnSpotEntryDetails = [];
  String searchQuery = '';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredOnSpotEntryDetails = widget.onSpotEntryDetails;
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      filteredOnSpotEntryDetails = widget.onSpotEntryDetails.where((entry) {
        final name = entry['name'].toString().toLowerCase();
        final email = entry['email'].toString().toLowerCase();
        return name.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase());
      }).toList();
    });
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        filteredOnSpotEntryDetails = widget.onSpotEntryDetails;
        searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allows the body to extend behind the AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Makes the AppBar transparent
        elevation: 0, // Removes the shadow
        title: !isSearching
            ? const Text(
          "On The Spot Entry List...",
          style: TextStyle(
            color: Color(0xFF7464bc), // Sets the title text color
            fontWeight: FontWeight.bold, // Optional: makes the text bold
            fontSize: 20, // Optional: sets the font size
          ),
        )
            : TextField(
          decoration: const InputDecoration(
            hintText: 'Search by name or email...',
            hintStyle: TextStyle(color: Color(0xFF7464bc)),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Color(0xFF7464bc)),
          onChanged: (value) {
            updateSearchQuery(value);
          },
          autofocus: true,
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF7464bc), // Sets the icon color (e.g., back button)
        ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            color: const Color(0xFF7464bc),
            onPressed: toggleSearch,
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
                          searchFor: "onSpotEntry",
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
            child: filteredOnSpotEntryDetails.isEmpty
                ? const Center(
              child: Text(
                'No on-the-spot entries found...',
                style: TextStyle(
                  color: Color(0xFF7464bc),
                  fontSize: 18,
                ),
              ),
            )
                : ListView.builder(
              itemCount: filteredOnSpotEntryDetails.length,
              itemBuilder: (context, index) {
                var entry = filteredOnSpotEntryDetails[index];
                return ListTile(
                  leading: Icon(
                    Icons.person_pin,
                    color: widget.isPastEvent
                        ? entry['attended'] == "yes"
                        ? const Color.fromARGB(255, 100, 188, 109)
                        : const Color(0xFF7464bc)
                        : const Color(0xFF7464bc),
                  ),
                  title: Text(
                    entry['name'],
                    style: TextStyle(
                      color: widget.isPastEvent
                          ? entry['attended'] == "yes"
                          ? const Color.fromARGB(255, 100, 188, 109)
                          : const Color(0xFF7464bc)
                          : const Color(0xFF7464bc),
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    entry['email'],
                    style: TextStyle(
                      color: widget.isPastEvent
                          ? entry['attended'] == "yes"
                          ? const Color.fromARGB(255, 100, 188, 109)
                          : const Color(0xFF7464bc)
                          : const Color(0xFF7464bc),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: widget.isPastEvent
                        ? entry['attended'] == "yes"
                        ? const Color.fromARGB(255, 100, 188, 109)
                        : const Color(0xFF7464bc)
                        : const Color(0xFF7464bc),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            OnSpotEntryDetailsScreen(
                              data: entry,
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
                        AddOnSpotEntryScreen(
                          eventDetails: widget.eventDetails,
                          onSpotEntryDetails: widget.onSpotEntryDetails,
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
}
