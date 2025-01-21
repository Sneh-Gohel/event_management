import 'package:event_management/screens/AddEventScreen.dart';
import 'package:event_management/screens/EventDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EventlistScreen extends StatefulWidget {
  const EventlistScreen({super.key});

  @override
  State<StatefulWidget> createState() => _EventlistScreen();
}

class _EventlistScreen extends State<EventlistScreen> {
  bool loadingScreen = false;
  List<Map<String, dynamic>> eventData = [];
  List<Map<String, dynamic>> filteredEventData = [];
  bool isEmpty = false;
  bool isSearching = false; // To track if the user is searching
  TextEditingController searchController = TextEditingController();

  Future<void> fetchEventListData() async {
    setState(() {
      loadingScreen = true;
    });

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('Events')
        .doc('EventList')
        .get();

    var data = docSnapshot.data() as Map<String, dynamic>?;
    if (data == null || data.isEmpty) {
      setState(() {
        isEmpty = true;
        loadingScreen = false;
      });
      return;
    } else {
      List<Map<String, dynamic>> tempEventData = [];

      for (var key in data.keys) {
        DocumentSnapshot eventDataDoc = await FirebaseFirestore.instance
            .collection(key)
            .doc('EventDetails')
            .get();

        if (eventDataDoc.exists) {
          var event_data = eventDataDoc.data() as Map<String, dynamic>?;
          if (event_data != null) {
            tempEventData.add(event_data);
          }
        }
      }

      tempEventData.sort((a, b) {
        String dateA = a['date'];
        String dateB = b['date'];
        return dateA.compareTo(dateB);
      });

      setState(() {
        eventData = tempEventData;
        filteredEventData = eventData; // Initially, show all events
        loadingScreen = false;
      });
    }
  }

  @override
  void initState() {
    fetchEventListData();
    super.initState();
  }

  // Method to filter events based on the search query
  void filterEvents(String query) {
    List<Map<String, dynamic>> tempFilteredEventData = [];

    if (query.isEmpty) {
      tempFilteredEventData = eventData;
    } else {
      tempFilteredEventData = eventData
          .where((event) =>
              event['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredEventData = tempFilteredEventData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search Events...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF7464bc)),
                ),
                style: const TextStyle(color: Color(0xFF7464bc)),
                onChanged: (value) {
                  filterEvents(value);
                },
              )
            : const Text(
                "Event List...",
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
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  filterEvents(''); // Reset the list when closing search
                }
                isSearching = !isSearching;
              });
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
            child: loadingScreen
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: const Color(0xFF7464bc),
                      size: 35,
                    ),
                  )
                : filteredEventData.isNotEmpty
                    ? ListView.builder(
                        itemCount: filteredEventData.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.event,
                                color: Color(0xFF7464bc)),
                            title: Text(
                              filteredEventData[index]['name'],
                              style: const TextStyle(
                                color: Color(0xFF7464bc),
                                fontSize: 18,
                              ),
                            ),
                            subtitle: const Text(
                              'Event details go here.',
                              style: TextStyle(
                                color: Color(0xFF7464bc),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF7464bc),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      EventDetailsScreen(eventDetails: filteredEventData[index]),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(0.0, 1.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;

                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    var offsetAnimation =
                                        animation.drive(tween);

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
                      )
                    : const Center(
                        child: Text(
                          'No events....',
                          style: TextStyle(
                            color: Color(0xFF7464bc),
                            fontSize: 18,
                          ),
                        ),
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
                        const AddEventScreen(),
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
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
