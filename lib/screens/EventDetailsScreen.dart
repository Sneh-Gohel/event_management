import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:event_management/screens/EnrolledFacultyList.dart';
import 'package:event_management/screens/EnrolledGuestList.dart';
import 'package:event_management/screens/EnrolledOnSpotEntryList.dart';
import 'package:event_management/screens/EnrolledStudentsCategory.dart';
import 'package:event_management/screens/QRScanningScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vibration/vibration.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatefulWidget {
  var eventDetails;
  EventDetailsScreen({required this.eventDetails, super.key});

  @override
  State<StatefulWidget> createState() => _EventDetailsScreen();
}

class _EventDetailsScreen extends State<EventDetailsScreen> {
  final event_name_Controller = TextEditingController();
  final event_name = FocusNode();
  String? selectedDate;
  String? selectedTime;
  final textController = TextEditingController();
  final FocusNode textFocusNode = FocusNode();
  int wordCount = 0;
  final int maxWords = 50;
  bool enableEdit = false;
  List<Map<String, dynamic>> regularStudentDetails = [];
  List<Map<String, dynamic>> alumniStudentDetails = [];
  List<Map<String, dynamic>> facultyDetails = [];
  List<Map<String, dynamic>> guestDetails = [];
  List<Map<String, dynamic>> onSpotEntryDetails = [];
  bool loadingScreen = false;
  bool isPastEvent = false;
  int regularStudentAttendedCount = 0;
  int alumniStudentAttendedCount = 0;
  int facultyAttendedCount = 0;
  int guestAttendedCount = 0;
  int onSpotEntryAttendedCount = 0;

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime.format(context);
      });
    }
  }

  void _onTextChanged(String text) {
    List<String> words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    setState(() {
      wordCount = words.length;
    });

    if (wordCount > maxWords) {
      String truncatedText = words.take(maxWords).join(' ');
      textController.value = TextEditingValue(
        text: truncatedText,
        selection: TextSelection.fromPosition(
          TextPosition(offset: truncatedText.length),
        ),
      );
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      loadingScreen = true;
    });

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    try {
      // Fetch all documents in the 'Regular' collection under 'Student_details'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(widget.eventDetails[
              'name']) // Assume eventDetails contains 'name' of the event
          .doc('Student_details')
          .collection('Regular')
          .get();

      // Initialize an empty list to hold all student details
      List<Map<String, dynamic>> studentDetailsList = [];

      // Loop through all the documents in the collection
      for (var doc in querySnapshot.docs) {
        // Skip the document with ID 'QuickAdd_details'
        if (doc.id == 'QuickAdd_details') {
          continue; // Skip this document and move to the next iteration
        }

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Add both the document data and its ID to the map
        data['docId'] = doc.id; // Store document ID in the data map
        studentDetailsList.add(data); // Add the entire map to the list
        if (data['attended'] == "yes") {
          setState(() {
            regularStudentAttendedCount++;
          });
        }
      }

      // After collecting all documents, store the data in the regularStudentDetails list
      setState(() {
        regularStudentDetails =
            studentDetailsList; // Store all documents' data in the list
      });
    } catch (e) {
      setState(() {
        regularStudentDetails =
            []; // Handle any errors by setting an empty list
      });
    }

    try {
      // Fetch all documents in the 'Alumni' collection under 'Student_details'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(widget.eventDetails[
              'name']) // Assume eventDetails contains 'name' of the event
          .doc('Student_details')
          .collection('Alumni')
          .get();

      // Initialize an empty list to hold all student details
      List<Map<String, dynamic>> studentDetailsList = [];

      // Loop through all the documents in the collection
      for (var doc in querySnapshot.docs) {
        // Skip the document with ID 'QuickAdd_details'
        if (doc.id == 'QuickAdd_details') {
          continue; // Skip this document
        }

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Add both the document data and its ID to the map
        data['docId'] = doc.id; // Store document ID in the data map
        studentDetailsList.add(data); // Add the entire map to the list
        if (data['attended'] == "yes") {
          setState(() {
            alumniStudentAttendedCount++;
          });
        }
      }

      // After collecting all documents, store the data in the alumniStudentDetails list
      setState(() {
        alumniStudentDetails =
            studentDetailsList; // Store all documents' data in the list
      });
    } catch (e) {
      setState(() {
        alumniStudentDetails = []; // Handle any errors by setting an empty list
      });
    }

    try {
      // Fetch all documents in the 'List' collection under 'Faculty_details'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(widget.eventDetails[
              'name']) // Assume eventDetails contains 'name' of the event
          .doc('Faculty_details')
          .collection('List')
          .get();

      // Initialize an empty list to hold all faculty details
      List<Map<String, dynamic>> facultyDetailsList = [];

      // Loop through all the documents in the collection
      for (var doc in querySnapshot.docs) {
        // Skip the document with ID 'QuickAdd_details'
        if (doc.id == 'QuickAdd_details') {
          continue; // Skip this document
        }

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Add both the document data and its ID to the map
        data['docId'] = doc.id; // Store document ID in the data map
        facultyDetailsList.add(data); // Add the entire map to the list
        if (data['attended'] == "yes") {
          setState(() {
            facultyAttendedCount++;
          });
        }
      }

      // After collecting all documents, store the data in the facultyDetails list
      setState(() {
        facultyDetails =
            facultyDetailsList; // Store all documents' data in the list
      });
    } catch (e) {
      setState(() {
        facultyDetails = []; // Handle any errors by setting an empty list
      });
    }

    try {
      // Fetch all documents in the 'List' collection under 'Guest_details'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(widget.eventDetails[
              'name']) // Assume eventDetails contains 'name' of the event
          .doc('Guest_details')
          .collection('List')
          .get();

      // Initialize an empty list to hold all guest details
      List<Map<String, dynamic>> guestDetailsList = [];

      // Loop through all the documents in the collection
      for (var doc in querySnapshot.docs) {
        // Skip the document with ID 'QuickAdd_details'
        if (doc.id == 'QuickAdd_details') {
          continue; // Skip this document
        }

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Add both the document data and its ID to the map
        data['docId'] = doc.id; // Store document ID in the data map
        guestDetailsList.add(data); // Add the entire map to the list
        if (data['attended'] =="yes") {
          setState(() {
            guestAttendedCount++;
          });
        }
      }

      // After collecting all documents, store the data in the guestDetails list
      setState(() {
        guestDetails =
            guestDetailsList; // Store all documents' data in the list
      });
    } catch (e) {
      setState(() {
        guestDetails = []; // Handle any errors by setting an empty list
      });
    }

    try {
      // Fetch all documents in the 'List' collection under 'OnSpotEntry_details'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(widget.eventDetails[
              'name']) // Assume eventDetails contains 'name' of the event
          .doc('OnSpotEntry_details')
          .collection('List')
          .get();

      // Initialize an empty list to hold all on-spot entry details
      List<Map<String, dynamic>> onSpotEntryDetailsList = [];

      // Loop through all the documents in the collection
      for (var doc in querySnapshot.docs) {
        // Skip the document with ID 'QuickAdd_details'
        if (doc.id == 'QuickAdd_details') {
          continue; // Skip this document
        }

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Add both the document data and its ID to the map
        data['docId'] = doc.id; // Store document ID in the data map
        onSpotEntryDetailsList.add(data); // Add the entire map to the list
        if (data['attended'] == "yes") {
          setState(() {
            onSpotEntryAttendedCount++;
          });
        }
      }

      // After collecting all documents, store the data in the onSpotEntryDetails list
      setState(() {
        onSpotEntryDetails =
            onSpotEntryDetailsList; // Store all documents' data in the list
      });
    } catch (e) {
      setState(() {
        onSpotEntryDetails = []; // Handle any errors by setting an empty list
      });
    }

    setState(() {
      loadingScreen = false;
    });
  }

  void checkDateStatus() {
    // Define the format of your input date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Parse the input date string into a DateTime object
    DateTime parsedDate = dateFormat.parse(widget.eventDetails['date']);

    // Get today's date without time (only the date)
    DateTime today = DateTime.now();
    DateTime todayOnlyDate = DateTime(today.year, today.month, today.day);

    // Compare the parsed date with today's date
    if (parsedDate.isBefore(todayOnlyDate)) {
      setState(() {
        isPastEvent = true;
      });
    } else if (parsedDate.isAfter(todayOnlyDate)) {
      setState(() {
        isPastEvent = false;
      });
    } else {
      setState(() {
        isPastEvent = true;
      });
    }
  }

  Future<void> _save() async {
    if (selectedDate == "" || selectedDate == null) {
      Vibration.vibrate(duration: 50);
      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Warning!',
          message: 'Please make sure to select date.',
          contentType: ContentType.warning,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      setState(() {
        loadingScreen = false;
      });
      return;
    }

    if (selectedTime == "" || selectedTime == null) {
      Vibration.vibrate(duration: 50);
      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Warning!',
          message: 'Please make sure to select time.',
          contentType: ContentType.warning,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      setState(() {
        loadingScreen = false;
      });
      return;
    }

    if (textController.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(textFocusNode);
      setState(() {
        loadingScreen = false;
      });
      return;
    }

    setState(() {
      loadingScreen = true;
    });

    try {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      await _firestore.collection('Events').doc('EventList').update({
        event_name_Controller.text: selectedDate, // Add a new field here
      });

      DocumentReference docRef =
          _firestore.collection(event_name_Controller.text).doc("EventDetails");
      await docRef.update({
        'date': selectedDate,
        'time': selectedTime,
        'description': textController.text,
      });
    } catch (e) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Getting Error!',
          message: e.toString(),
          contentType: ContentType.warning,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      setState(() {
        loadingScreen = false;
      });
    } finally {
      setState(() {
        loadingScreen = false;
      });
    }
  }

  @override
  void initState() {
    event_name_Controller.text = widget.eventDetails['name'];
    selectedDate = widget.eventDetails['date'];
    selectedTime = widget.eventDetails['time'];
    textController.text = widget.eventDetails['description'];
    _fetchData();
    checkDateStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allows the body to extend behind the AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Makes the AppBar transparent
        elevation: 0, // Removes the shadow
        title: const Text(
          "Event Details...",
          style: TextStyle(
            color: Color(0xFF7464bc), // Sets the title text color
            fontWeight: FontWeight.bold, // Optional: makes the text bold
            fontSize: 20, // Optional: sets the font size
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        QRScanninScreen(
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
              icon: const Icon(
                Icons.qr_code_scanner,
                color: Color(0xFF7464bc),
              ),
            ),
          ),
        ],
        iconTheme: const IconThemeData(
          color: Color(0xFF7464bc), // Sets the icon color (e.g., back button)
        ),
      ),
      body: loadingScreen
          ? AnimatedContainer(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // Color(0x91a291da), // Semi-transparent purple
                    // Color(0xFFded9ee), // Light lavender
                    Color(0x99ded9ee),
                    Color(0x99e9e6ef),
                  ],
                ),
              ),
              duration: const Duration(milliseconds: 200),
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: const Color(0xFF7464bc),
                  size: 35,
                ),
              ),
            )
          : Stack(
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
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: const Color(0xFF7464bc),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 20, left: 20),
                                child: Text(
                                  "Event name :",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                                child: TextField(
                                  controller: event_name_Controller,
                                  focusNode: event_name,
                                  enabled: false,
                                  onEditingComplete: () {
                                    event_name.unfocus();
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF7464bc), // Muted violet
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.event_outlined,
                                        color: Color(0xFF7464bc)),
                                    suffix: GestureDetector(
                                      child: const Icon(Icons.clear,
                                          color: Color(0xFF7464bc)),
                                      onTap: () {
                                        event_name_Controller.clear();
                                      },
                                    ),
                                    filled: true,
                                    fillColor: const Color(
                                        0xFFded9ee), // Light lavender
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xFF7464bc)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    hintText: "Event Name",
                                    hintStyle: TextStyle(
                                        color: const Color(0xFF7464bc)
                                            .withOpacity(0.5)),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Event Date & Time :",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    selectedDate == null
                                        ? ElevatedButton(
                                            onPressed: _selectDate,
                                            child: const Text('Select Date'),
                                          )
                                        : Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: GestureDetector(
                                                onTap: _selectDate,
                                                child: TextField(
                                                  enabled: false,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Color(
                                                        0xFF7464bc), // Muted violet
                                                  ),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(
                                                        Icons.calendar_today,
                                                        color:
                                                            Color(0xFF7464bc)),
                                                    filled: true,
                                                    fillColor: const Color(
                                                        0xFFded9ee), // Light lavender
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .transparent),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Color(
                                                                  0xFF7464bc)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    hintText: selectedDate,
                                                    hintStyle: TextStyle(
                                                        color: const Color(
                                                                0xFF7464bc)
                                                            .withOpacity(0.5)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    const SizedBox(width: 20),
                                    selectedTime == null
                                        ? ElevatedButton(
                                            onPressed: _selectTime,
                                            child: const Text('Select Time'),
                                          )
                                        : Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: GestureDetector(
                                                onTap: _selectTime,
                                                child: TextField(
                                                  enabled: false,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Color(
                                                        0xFF7464bc), // Muted violet
                                                  ),
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(
                                                        Icons.access_time,
                                                        color:
                                                            Color(0xFF7464bc)),
                                                    filled: true,
                                                    fillColor: const Color(
                                                        0xFFded9ee), // Light lavender
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .transparent),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Color(
                                                                  0xFF7464bc)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    hintText: selectedTime,
                                                    hintStyle: TextStyle(
                                                        color: const Color(
                                                                0xFF7464bc)
                                                            .withOpacity(0.5)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Event Description :",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: textController,
                                      focusNode: textFocusNode,
                                      enabled: enableEdit,
                                      maxLines: null,
                                      onChanged: _onTextChanged,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color:
                                            Color(0xFF7464bc), // Muted violet
                                      ),
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                            Icons.text_fields,
                                            color: Color(0xFF7464bc)),
                                        filled: true,
                                        fillColor: const Color(
                                            0xFFded9ee), // Light lavender
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Color(0xFF7464bc)),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        hintText:
                                            "Enter Description (Max 50 words)",
                                        hintStyle: TextStyle(
                                            color: const Color(0xFF7464bc)
                                                .withOpacity(0.5)),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '$wordCount / $maxWords words',
                                      style: TextStyle(
                                        color: wordCount > maxWords
                                            ? Colors.red
                                            : const Color(0xFF7464bc),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 30,
                                    bottom: 50,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (enableEdit) {
                                        await _save();
                                      }
                                      setState(() {
                                        enableEdit = !enableEdit;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      backgroundColor: const Color(0xFF8e75e4),
                                      shape:
                                          const StadiumBorder(), // Soft purple
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Text(
                                        enableEdit ? "Save" : "Edit Details",
                                        style: const TextStyle(
                                          fontSize: 25,
                                          color: Color(0xFFEAE7DD),
                                        ), // Light lavender
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Color(0xFF7464bc),
                          ),
                          title: const Text(
                            "Students details",
                            style: TextStyle(
                              color: Color(0xFF7464bc),
                              fontSize: 18,
                            ),
                          ),
                          subtitle: const Text(
                            'Students enrollment List.',
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
                                child: isPastEvent
                                    ? Text(
                                        "${regularStudentAttendedCount + alumniStudentAttendedCount}",
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 100, 188, 109),
                                            fontSize: 18),
                                      )
                                    : const Center(),
                              ),
                              Text(
                                isPastEvent
                                    ? "/  ${regularStudentDetails.length + alumniStudentDetails.length}"
                                    : "${regularStudentDetails.length + alumniStudentDetails.length}",
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
                                        EnrollStudentCategory(
                                  eventDetails: widget.eventDetails,
                                  regularStudentDetails: regularStudentDetails,
                                  alumniStudentDetails: alumniStudentDetails,
                                  isPastEvent: isPastEvent,
                                  regularStudentAttendedCount:
                                      regularStudentAttendedCount,
                                  alumniStudentAttendedCount:
                                      alumniStudentAttendedCount,
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: ListTile(
                          leading: const Icon(
                            Icons.person_2,
                            color: Color(0xFF7464bc),
                          ),
                          title: const Text(
                            "Faculty details",
                            style: TextStyle(
                              color: Color(0xFF7464bc),
                              fontSize: 18,
                            ),
                          ),
                          subtitle: const Text(
                            'Faculty enrollment List.',
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
                                child: isPastEvent
                                    ? Text(
                                        "$facultyAttendedCount",
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 100, 188, 109),
                                            fontSize: 18),
                                      )
                                    : const Center(),
                              ),
                              Text(
                                isPastEvent
                                    ? "/  ${facultyDetails.length}"
                                    : "${facultyDetails.length}",
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
                                        EnrolledFacultyList(
                                  eventDetails: widget.eventDetails,
                                  facultyDetails: facultyDetails,
                                  isPastEvent: isPastEvent,
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: ListTile(
                          leading: const Icon(
                            Icons.perm_contact_calendar_sharp,
                            color: Color(0xFF7464bc),
                          ),
                          title: const Text(
                            "Guest details",
                            style: TextStyle(
                              color: Color(0xFF7464bc),
                              fontSize: 18,
                            ),
                          ),
                          subtitle: const Text(
                            'Guest enrollment List.',
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
                                child: isPastEvent
                                    ? Text(
                                        "$guestAttendedCount",
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 100, 188, 109),
                                            fontSize: 18),
                                      )
                                    : const Center(),
                              ),
                              Text(
                                isPastEvent
                                    ? "/  ${guestDetails.length}"
                                    : "${guestDetails.length}",
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
                                        EnrolledGuestList(
                                  eventDetails: widget.eventDetails,
                                  guestDetails: guestDetails,
                                  isPastEvent: isPastEvent,
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: ListTile(
                          leading: const Icon(
                            Icons.person_pin,
                            color: Color(0xFF7464bc),
                          ),
                          title: const Text(
                            "On Spot Entry",
                            style: TextStyle(
                              color: Color(0xFF7464bc),
                              fontSize: 18,
                            ),
                          ),
                          subtitle: const Text(
                            'On Spot Entry enrollment List.',
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
                                child: isPastEvent
                                    ? Text(
                                        "$onSpotEntryAttendedCount",
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 100, 188, 109),
                                            fontSize: 18),
                                      )
                                    : const Center(),
                              ),
                              Text(
                                isPastEvent
                                    ? "/  ${onSpotEntryDetails.length}"
                                    : "${onSpotEntryDetails.length}",
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
                                pageBuilder: (context, animation,
                                        secondaryAnimation) =>
                                    EnrolledOnSpotEntryList(
                                        eventDetails: widget.eventDetails,
                                        onSpotEntryDetails: onSpotEntryDetails,
                                        isPastEvent: isPastEvent),
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
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 30,
                            bottom: 50,
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              backgroundColor: Colors.red,
                              shape: const StadiumBorder(),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(15),
                              child: Text(
                                "Delete Event",
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Color(0xFFEAE7DD),
                                ), // Light lavender
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
    );
  }
}
