import 'dart:convert';
import 'dart:io';
import 'package:event_management/screens/ErrorScreen.dart';
import 'package:event_management/services/FetchDataFromSheets.dart';
import 'package:event_management/services/MailServiceByAPI.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:event_management/services/MailService.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:vibration/vibration.dart';

class QuickAddScreen extends StatefulWidget {
  String searchFor = "Student";
  var eventDetails;
  QuickAddScreen(
      {required this.searchFor, required this.eventDetails, super.key});

  @override
  State<StatefulWidget> createState() => _QuickAddScreen();
}

class _QuickAddScreen extends State<QuickAddScreen> {
  final sheet_id_Controller = TextEditingController();
  final sheet_id = FocusNode();
  final start_Controller = TextEditingController();
  final start = FocusNode();
  final end_Controller = TextEditingController();
  final end = FocusNode();
  bool is_data_available = false;
  var data;
  var quickAddDetails;
  FetchDataFromSheets fData = FetchDataFromSheets();
  bool loadingScreen = false;
  bool updatingLoadingScreen = false;
  int index = 0;
  // String regularStudentSheetID = "1krAsN8XJNmkHGnOG202H2Y0aPy8PyxWdzcXF20SIagQ";
  String regularStudentSheetID = "12X26UXy3kLeMrrLMVLNnFj0UlRs2IzReOrOCnhX4duk";
  String alumniStudentSheetID = "1fZhdIzbxVyTREZrk9OvcTDUkFyLXRfXb6RwDHn2FTr4";
  // String facultySheetID = "1ORyOfI8g6Z55i7FgQ8_tBfek_sSwJshulqoUiTh0sko";
  String facultySheetID = "1W2woOd5jfLm9tOwClPGNM9Rz2LsR1y02tRgPmVgM_dE";
  // String guestSheetID = "1X8GQvGCJjzJ0wQylDwjmrrAlcMUI8TaxkvC4QZ5X-Ko";   // garbotsav sheet id
  String guestSheetID = "1KEtYta96VnJDk0KAVEzLpJHGAMPiWsWRb7o3mju7DpA";
  // String onSpotEntrySheetID = "1ajYRTvf9r19Ct2YxzaVEpg_BiqUcdbh3dIoNiH2bejU"; // garbotsav sheet id
  String onSpotEntrySheetID = "1FIDoJj5ZmBipdIhyMCeiL0BdBSpk3DDXwvvZ-tgbcFo";
  List<Map<String, dynamic>> errorData = [];
  var backgroundImageResponse;
  int start_count = 0;
  int end_count = 0;
  String docId = "";

  Future<void> _downloadImage() async {
    try {
      final backgroundImageUri = Uri.parse(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO");

      // Fetch the background image
      setState(() async {
        backgroundImageResponse = await http.get(backgroundImageUri);
      });

      if (backgroundImageResponse.statusCode != 200) {
        throw Exception('Failed to load background image from network');
      }
    } catch (e) {
      setState(() {
        backgroundImageResponse = "";
      });
    }
  }

  void getRangeModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final Size size = MediaQuery.of(context).size;
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 500,
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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    "-: Index Is Starting From '0' :-",
                    style: TextStyle(fontSize: 20, color: Color(0xFF7464bc)),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Text(
                  "Enter Starting : ",
                  style: TextStyle(fontSize: 20, color: Color(0xFF7464bc)),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: TextField(
                  controller: start_Controller,
                  focusNode: start,
                  onEditingComplete: () {
                    start.unfocus();
                  },
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF7464bc), // Muted violet
                  ),
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.onetwothree, color: Color(0xFF7464bc)),
                    suffix: GestureDetector(
                      child: const Icon(Icons.clear, color: Color(0xFF7464bc)),
                      onTap: () {
                        start_Controller.clear();
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFFded9ee), // Light lavender
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF7464bc)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hintText: "Start",
                    hintStyle: TextStyle(
                        color: const Color(0xFF7464bc).withOpacity(0.5)),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 40, left: 20),
                child: Text(
                  "Enter Ending : ",
                  style: TextStyle(fontSize: 20, color: Color(0xFF7464bc)),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: TextField(
                  controller: end_Controller,
                  focusNode: end,
                  onEditingComplete: () {
                    end.unfocus();
                  },
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF7464bc), // Muted violet
                  ),
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.onetwothree, color: Color(0xFF7464bc)),
                    suffix: GestureDetector(
                      child: const Icon(Icons.clear, color: Color(0xFF7464bc)),
                      onTap: () {
                        end_Controller.clear();
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFFded9ee), // Light lavender
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF7464bc)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hintText: "End",
                    hintStyle: TextStyle(
                        color: const Color(0xFF7464bc).withOpacity(0.5)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 50, horizontal: (size.width / 2 - 100)),
                child: ElevatedButton(
                  onPressed: () {
                    if (start_Controller.text.isEmpty) {
                      Vibration.vibrate(duration: 50);
                      FocusScope.of(context).requestFocus(start);
                      return;
                    }
                    if (end_Controller.text.isEmpty) {
                      Vibration.vibrate(duration: 50);
                      FocusScope.of(context).requestFocus(end);
                      return;
                    }
                    Navigator.pop(context);
                    setState(() {
                      end_count = int.parse(end_Controller.text);
                    });
                    if (widget.searchFor == "Regular") {
                      _addRangeRegularStudents();
                    } else if (widget.searchFor == "Alumni") {
                      _addRangeAlumniStudents();
                    } else if (widget.searchFor == "Faculty") {
                      _addRangeFaculties();
                    } else if (widget.searchFor == "Guest") {
                      _addRangeGuest();
                    } else {
                      _addRangeOnSpot();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    shape: const StadiumBorder(),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "Add",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int countCommas(String input) {
    // Check if the input contains commas
    if (input.contains(',')) {
      // Split the string by commas and return the length of the resulting list minus 1
      return input.split(',').length - 1;
    } else {
      // Return 0 if no commas are found
      return 0;
    }
  }

  Future<void> _fetchCurrentDetails() async {
    setState(() {
      loadingScreen = true;
    });
    if (widget.searchFor == "Regular") {
      try {
        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp();

        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection(widget.eventDetails['name'])
            .doc('Student_details')
            .collection('Regular')
            .doc('QuickAdd_details')
            .get();
        setState(() {
          quickAddDetails = docSnapshot.data() as Map<String, dynamic>;
          sheet_id_Controller.text = quickAddDetails['sheet_id'];
        });
      } catch (e) {
        setState(() {
          quickAddDetails = [];
        });
      }

      try {
        // Fetch all documents in the 'Regular' collection under 'Student_details'
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(widget.eventDetails[
                'name']) // Assume eventDetails contains 'name' of the event
            .doc('Student_details')
            .collection('Regular_error')
            .get();

        // Initialize an empty list to hold all student details
        List<Map<String, dynamic>> studentDetailsList = [];

        // Loop through all the documents in the collection
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Add both the document data and its ID to the map
          data['docId'] = doc.id; // Store document ID in the data map
          studentDetailsList.add(data); // Add the entire map to the list
        }

        // After collecting all documents, store the data in the regularStudentDetails list
        setState(() {
          errorData =
              studentDetailsList; // Store all documents' data in the list
        });
      } catch (e) {
        setState(() {
          errorData = []; // Handle any errors by setting an empty list
        });
      }
    } else if (widget.searchFor == "Alumni") {
      try {
        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp();

        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection(widget.eventDetails['name'])
            .doc('Student_details')
            .collection('Alumni')
            .doc('QuickAdd_details')
            .get();
        setState(() {
          quickAddDetails = docSnapshot.data() as Map<String, dynamic>;
          sheet_id_Controller.text = quickAddDetails['sheet_id'];
        });
      } catch (e) {
        setState(() {
          quickAddDetails = [];
        });
      }

      try {
        // Fetch all documents in the 'Regular' collection under 'Student_details'
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(widget.eventDetails[
                'name']) // Assume eventDetails contains 'name' of the event
            .doc('Student_details')
            .collection('Alumni_error')
            .get();

        // Initialize an empty list to hold all student details
        List<Map<String, dynamic>> studentDetailsList = [];

        // Loop through all the documents in the collection
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Add both the document data and its ID to the map
          data['docId'] = doc.id; // Store document ID in the data map
          studentDetailsList.add(data); // Add the entire map to the list
        }

        // After collecting all documents, store the data in the regularStudentDetails list
        setState(() {
          errorData =
              studentDetailsList; // Store all documents' data in the list
        });
      } catch (e) {
        setState(() {
          errorData = []; // Handle any errors by setting an empty list
        });
      }
    } else if (widget.searchFor == "Faculty") {
      try {
        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp();

        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection(widget.eventDetails['name'])
            .doc('Faculty_details')
            .collection('List')
            .doc('QuickAdd_details')
            .get();
        setState(() {
          quickAddDetails = docSnapshot.data() as Map<String, dynamic>;
          sheet_id_Controller.text = quickAddDetails['sheet_id'];
        });
      } catch (e) {
        setState(() {
          quickAddDetails = [];
        });
      }

      try {
        // Fetch all documents in the 'Regular' collection under 'Student_details'
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(widget.eventDetails[
                'name']) // Assume eventDetails contains 'name' of the event
            .doc('Faculty_details')
            .collection('List_error')
            .get();

        // Initialize an empty list to hold all student details
        List<Map<String, dynamic>> studentDetailsList = [];

        // Loop through all the documents in the collection
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Add both the document data and its ID to the map
          data['docId'] = doc.id; // Store document ID in the data map
          studentDetailsList.add(data); // Add the entire map to the list
        }

        // After collecting all documents, store the data in the regularStudentDetails list
        setState(() {
          errorData =
              studentDetailsList; // Store all documents' data in the list
        });
      } catch (e) {
        setState(() {
          errorData = []; // Handle any errors by setting an empty list
        });
      }
    } else if (widget.searchFor == "Guest") {
      try {
        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp();

        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection(widget.eventDetails['name'])
            .doc('Guest_details')
            .collection('List')
            .doc('QuickAdd_details')
            .get();
        setState(() {
          quickAddDetails = docSnapshot.data() as Map<String, dynamic>;
          sheet_id_Controller.text = quickAddDetails['sheet_id'];
        });
      } catch (e) {
        setState(() {
          quickAddDetails = [];
        });
      }

      try {
        // Fetch all documents in the 'Regular' collection under 'Student_details'
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(widget.eventDetails[
                'name']) // Assume eventDetails contains 'name' of the event
            .doc('Guest_details')
            .collection('List_error')
            .get();

        // Initialize an empty list to hold all student details
        List<Map<String, dynamic>> studentDetailsList = [];

        // Loop through all the documents in the collection
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Add both the document data and its ID to the map
          data['docId'] = doc.id; // Store document ID in the data map
          studentDetailsList.add(data); // Add the entire map to the list
        }

        // After collecting all documents, store the data in the regularStudentDetails list
        setState(() {
          errorData =
              studentDetailsList; // Store all documents' data in the list
        });
      } catch (e) {
        setState(() {
          errorData = []; // Handle any errors by setting an empty list
        });
      }
    } else {
      try {
        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp();

        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection(widget.eventDetails['name'])
            .doc('OnSpotEntry_details')
            .collection('List')
            .doc('QuickAdd_details')
            .get();
        setState(() {
          quickAddDetails = docSnapshot.data() as Map<String, dynamic>;
          sheet_id_Controller.text = quickAddDetails['sheet_id'];
        });
      } catch (e) {
        setState(() {
          quickAddDetails = [];
        });
      }

      try {
        // Fetch all documents in the 'Regular' collection under 'Student_details'
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(widget.eventDetails[
                'name']) // Assume eventDetails contains 'name' of the event
            .doc('OnSpotEntry_details')
            .collection('List_error')
            .get();

        // Initialize an empty list to hold all student details
        List<Map<String, dynamic>> studentDetailsList = [];

        // Loop through all the documents in the collection
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Add both the document data and its ID to the map
          data['docId'] = doc.id; // Store document ID in the data map
          studentDetailsList.add(data); // Add the entire map to the list
        }

        // After collecting all documents, store the data in the regularStudentDetails list
        setState(() {
          errorData =
              studentDetailsList; // Store all documents' data in the list
        });
      } catch (e) {
        setState(() {
          errorData = []; // Handle any errors by setting an empty list
        });
      }
    }

    setState(() {
      loadingScreen = false;
    });
  }

  Future<void> _get_form_data() async {
    setState(() {
      loadingScreen = true;
      index = 0;
    });
    if (quickAddDetails.length == 0) {
      if (widget.searchFor == "Regular") {
        data = await fData.fetchData(regularStudentSheetID, 0, "Regular");
      } else if (widget.searchFor == "Alumni") {
        data = await fData.fetchData(alumniStudentSheetID, 0, "Alumni");
      } else if (widget.searchFor == "Faculty") {
        data = await fData.fetchData(facultySheetID, 0, "Faculty");
      } else if (widget.searchFor == "Guest") {
        data = await fData.fetchData(guestSheetID, 0, "Guest");
      } else {
        data = await fData.fetchData(onSpotEntrySheetID, 0, "OnSpot");
      }
      if (data.length != 0) {
        setState(() {
          is_data_available = true;
        });
      }
    } else {
      int count = quickAddDetails['count'];
      if (widget.searchFor == "Regular") {
        data =
            await fData.fetchData(regularStudentSheetID, count + 1, "Regular");
      } else if (widget.searchFor == "Alumni") {
        data = await fData.fetchData(alumniStudentSheetID, count + 1, "Alumni");
      } else if (widget.searchFor == "Faculty") {
        data = await fData.fetchData(facultySheetID, count + 1, "Faculty");
      } else if (widget.searchFor == "Guest") {
        data = await fData.fetchData(guestSheetID, count + 1, "Guest");
      } else {
        data = await fData.fetchData(onSpotEntrySheetID, count + 1, "OnSpot");
      }
      if (data.length != 0) {
        setState(() {
          is_data_available = true;
        });
      }
    }
    setState(() {
      loadingScreen = false;
    });
  }

  Future<void> _addRangeRegularStudents() async {
    setState(() {
      updatingLoadingScreen = true;
    });
    for (index = int.parse(start_Controller.text);
        index < int.parse(end_Controller.text);
        index++) {
      try {
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;

        final DocumentReference docRef = await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Student_details')
            .collection('Regular')
            .add({
          'name': data[index]['name'],
          'college_name': data[index]['college'],
          'department_name': data[index]['department'],
          'sem': data[index]['sem'],
          'enrollment_number': data[index]['enrollment_number'],
          'gender': data[index]['gender'],
          'email': data[index]['email'],
          'mobile_number': data[index]['mobile_number'],
          'attended': 'no'
        });

        // Get the document ID
        final String docId = docRef.id;

        final String qrData = "Student_details;;Regular;;$docId";

        MailService mail = MailService();

        bool response = await mail.mailGenerate(
            "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
            data[index]['email'],
            qrData,
            widget.eventDetails,
            0,
            backgroundImageResponse);

        // MailServiceByAPI mail = MailServiceByAPI();
        //
        // bool response = await mail.sendEmailViaAppScript(
        //     "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
        //     data[index]['email'],
        //     qrData,
        //     widget.eventDetails,
        //     backgroundImageResponse);

        if (response != true) {
          final FirebaseFirestore _firestore = FirebaseFirestore.instance;
          await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Student_details')
              .collection('Regular')
              .doc(docId)
              .delete();

          await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Student_details')
              .collection('Regular_error')
              .add({
            'name': data[index]['name'],
            'college_name': data[index]['college'],
            'department_name': data[index]['department'],
            'sem': data[index]['sem'],
            'enrollment_number': data[index]['enrollment_number'],
            'gender': data[index]['gender'],
            'email': data[index]['email'],
            'mobile_number': data[index]['mobile_number'],
            'attended': 'no'
          });

          const snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Getting Error!',
              message: "Cannot able to send Email.",
              contentType: ContentType.warning,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
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
      }
      setState(() {
        index;
      });
    }
    setState(() {
      updatingLoadingScreen = false;
    });
  }

  Future<void> _addAllRegularStudents() async {
    if (widget.eventDetails['email']) {
      setState(() {
        updatingLoadingScreen = true;
      });
      int count = 0;
      if (quickAddDetails.isNotEmpty) {
        count = quickAddDetails['count'];
      }
      for (index = 0; index < data.length; index++) {
        try {
          final FirebaseFirestore _firestore = FirebaseFirestore.instance;

          final DocumentReference docRef = await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Student_details')
              .collection('Regular')
              .add({
            'name': data[index]['name'],
            'college_name': data[index]['college'],
            'department_name': data[index]['department'],
            'sem': data[index]['sem'],
            'enrollment_number': data[index]['enrollment_number'],
            'gender': data[index]['gender'],
            'email': data[index]['email'],
            'mobile_number': data[index]['mobile_number'],
            'attended': 'no'
          });

          // Get the document ID
          final String docId = docRef.id;

          final String qrData = "Student_details;;Regular;;$docId";

          MailService mail = MailService();

          bool response = await mail.mailGenerate(
              "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
              data[index]['email'],
              qrData,
              widget.eventDetails,
              0,
              backgroundImageResponse);

          // MailServiceByAPI mail = MailServiceByAPI();
          //
          // bool response = await mail.sendEmailViaAppScript(
          //     "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          //     data[index]['email'],
          //     qrData,
          //     widget.eventDetails,
          //     backgroundImageResponse);

          if (response != true) {
            final FirebaseFirestore _firestore = FirebaseFirestore.instance;
            await _firestore
                .collection(widget.eventDetails['name'])
                .doc('Student_details')
                .collection('Regular')
                .doc(docId)
                .delete();

            await _firestore
                .collection(widget.eventDetails['name'])
                .doc('Student_details')
                .collection('Regular_error')
                .add({
              'name': data[index]['name'],
              'college_name': data[index]['college'],
              'department_name': data[index]['department'],
              'sem': data[index]['sem'],
              'enrollment_number': data[index]['enrollment_number'],
              'gender': data[index]['gender'],
              'email': data[index]['email'],
              'mobile_number': data[index]['mobile_number'],
              'attended': 'no'
            });

            const snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Getting Error!',
                message: "Cannot able to send Email.",
                contentType: ContentType.warning,
              ),
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
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
        }
        setState(() {
          index;
        });
      }
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      await _firestore
          .collection(widget.eventDetails['name'])
          .doc('Student_details')
          .collection('Regular')
          .doc("QuickAdd_details")
          .set({
        'sheet_id': sheet_id_Controller.text,
        'count': count + data.length
      });
      setState(() {
        updatingLoadingScreen = false;
        data.clear;
      });
    } else {
      setState(() {
        loadingScreen = true;
      });
//       Map<String, dynamic> jsonData = {};
//
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection(widget.eventDetails[
//               'name']) // Assume eventDetails contains 'name' of the event
//           .doc('Student_details')
//           .collection('Regular')
//           .get();
//
// // Convert documents to a list of pairs with 'name' converted to an integer and the document ID
//       List<MapEntry<int, String>> docEntries = querySnapshot.docs.map((doc) {
//         // Parse the 'name' field as an integer (assuming 'name' field is a continuous number in string form)
//         int numericName = int.parse(doc['name']);
//         return MapEntry(numericName, doc.id);
//       }).toList();
//
// // Sort the entries by the integer 'name' field
//       docEntries.sort((a, b) => a.key.compareTo(b.key));
//
// // Remove the first 4000 entries
//       if (docEntries.length > 4000) {
//         docEntries = docEntries.sublist(4000);
//       }
//
// // Populate jsonData with sorted entries
//       int i = 0;
//       for (var entry in docEntries) {
//         i++;
//         jsonData["$i"] = "Student_details;;Regular;;${entry.value}"; // doc.id
//       }
//
//       // print("Processed JSON data: $jsonData");
//       print(jsonData.length);
//
//       jsonData.addAll({"event_name": "p", "folder_name": "pass"});

      // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      // for (int index = 0; index < data.length; index++) {
      //   final DocumentReference docRef = await _firestore
      //       .collection(widget.eventDetails['name'])
      //       .doc('Student_details')
      //       .collection('Regular')
      //       .add({
      //     'name': data[index]['name'],
      //     'college_name': data[index]['college'],
      //     'department_name': data[index]['department'],
      //     'sem': data[index]['sem'],
      //     'enrollment_number': data[index]['enrollment_number'],
      //     'gender': data[index]['gender'],
      //     'email': data[index]['email'],
      //     'mobile_number': data[index]['mobile_number'],
      //     'attended': 'no'
      //   });

      //   // Get the document ID
      //   final String docId = docRef.id;

      //   final String qrData = "Student_details;;Regular;;$docId";

      //   jsonData.addAll({data[index]['name']: qrData});
      // }
      // jsonData.addAll({
      //   "event_name": widget.eventDetails['name'],
      //   "folder_name": "student(Regular)"
      // });
      // print("uploading Data");
      // print(jsonData);
      // await generatePassLocally(jsonData);

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(widget.eventDetails['name'])
          .doc('Guest_details')
          .collection('List')
          .get();

      int i=0;
      // Iterate through each document and update the specified field
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        i++;
        await doc.reference.update({
          "attended": "no", // Set the new value for the specified field
        });
        print(i);
      }
      setState(() {
        loadingScreen = false;
      });
    }
  }

  Future<void> _addRegularStudent(int index) async {
    setState(() {
      loadingScreen = true;
    });
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      final DocumentReference docRef = await _firestore
          .collection(widget.eventDetails['name'])
          .doc('Student_details')
          .collection('Regular')
          .add({
        'name': data[index]['name'],
        'college_name': data[index]['college'],
        'department_name': data[index]['department'],
        'sem': data[index]['sem'],
        'enrollment_number': data[index]['enrollment_number'],
        'gender': data[index]['gender'],
        'email': data[index]['email'],
        'mobile_number': data[index]['mobile_number'],
        'attended': 'no'
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "Student_details;;Regular;;$docId";

      MailServiceByAPI mail = MailServiceByAPI();

      bool response = await mail.sendEmailViaAppScript(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          data[index]['email'],
          qrData,
          widget.eventDetails,
          backgroundImageResponse);

      if (response == true) {
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Successfully added student',
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        setState(() {
          loadingScreen = false;
        });
      } else {
        await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Student_details')
            .collection('Regular')
            .doc(docId)
            .delete();
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Getting Error!',
            message: "Cannot able to send Email check your connection once!",
            contentType: ContentType.warning,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        setState(() {
          loadingScreen = false;
        });
      }
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
    }
  }

  Future<void> _addRangeAlumniStudents() async {
    setState(() {
      updatingLoadingScreen = true;
    });
    for (index = int.parse(start_Controller.text);
        index < int.parse(end_Controller.text);
        index++) {
      try {
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;

        final DocumentReference docRef = await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Student_details')
            .collection('Alumni')
            .add({
          'name': data[index]['name'],
          'college_name': data[index]['college'],
          'department_name': data[index]['department'],
          'passout_year': data[index]['passout_year'],
          'company_name': data[index]['company_name'],
          'designation': data[index]['designation'],
          'gender': data[index]['gender'],
          'email': data[index]['email'],
          'mobile_number': data[index]['mobile_number'],
          'attended': 'no'
        });

        // Get the document ID
        final String docId = docRef.id;

        final String qrData = "Student_details;;Alumni;;$docId";

        MailService mail = MailService();

        bool response = await mail.mailGenerate(
            "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
            data[index]['email'],
            qrData,
            widget.eventDetails,
            0,
            backgroundImageResponse);

        // MailServiceByAPI mail = MailServiceByAPI();
        //
        // bool response = await mail.sendEmailViaAppScript(
        //     "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
        //     data[index]['email'],
        //     qrData,
        //     widget.eventDetails,
        //     backgroundImageResponse);

        if (response != true) {
          final FirebaseFirestore _firestore = FirebaseFirestore.instance;
          await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Student_details')
              .collection('Alumni')
              .doc(docId)
              .delete();

          await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Student_details')
              .collection('Alumni_error')
              .add({
            'name': data[index]['name'],
            'college_name': data[index]['college'],
            'department_name': data[index]['department'],
            'passout_year': data[index]['passout_year'],
            'company_name': data[index]['company_name'],
            'designation': data[index]['designation'],
            'gender': data[index]['gender'],
            'email': data[index]['email'],
            'mobile_number': data[index]['mobile_number'],
            'attended': 'no'
          });

          const snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Getting Error!',
              message: "Cannot able to send Email.",
              contentType: ContentType.warning,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
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
      }
      setState(() {
        index;
      });
    }
    setState(() {
      updatingLoadingScreen = false;
    });
  }

  Future<void> _addAllAumniStudents() async {
    setState(() {
      updatingLoadingScreen = true;
    });
    int count = 0;
    if (quickAddDetails.isNotEmpty) {
      count = quickAddDetails['count'];
    }
    for (index = 0; index < data.length; index++) {
      try {
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;

        final DocumentReference docRef = await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Student_details')
            .collection('Alumni')
            .add({
          'name': data[index]['name'],
          'college_name': data[index]['college'],
          'department_name': data[index]['department'],
          'passout_year': data[index]['passout_year'],
          'company_name': data[index]['company_name'],
          'designation': data[index]['designation'],
          'gender': data[index]['gender'],
          'email': data[index]['email'],
          'mobile_number': data[index]['mobile_number'],
          'attended': 'no'
        });

        // Get the document ID
        final String docId = docRef.id;

        final String qrData = "Student_details;;Alumni;;$docId";

        MailService mail = MailService();

        bool response = await mail.mailGenerate(
            "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
            data[index]['email'],
            qrData,
            widget.eventDetails,
            0,
            backgroundImageResponse);

        // MailServiceByAPI mail = MailServiceByAPI();
        //
        // bool response = await mail.sendEmailViaAppScript(
        //     "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
        //     data[index]['email'],
        //     qrData,
        //     widget.eventDetails,
        //     backgroundImageResponse);

        if (response != true) {
          final FirebaseFirestore _firestore = FirebaseFirestore.instance;
          await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Student_details')
              .collection('Alumni')
              .doc(docId)
              .delete();

          final DocumentReference docRef = await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Student_details')
              .collection('Alumni_error')
              .add({
            'name': data[index]['name'],
            'college_name': data[index]['college'],
            'department_name': data[index]['department'],
            'passout_year': data[index]['passout_year'],
            'company_name': data[index]['company_name'],
            'designation': data[index]['designation'],
            'gender': data[index]['gender'],
            'email': data[index]['email'],
            'mobile_number': data[index]['mobile_number'],
            'attended': 'no'
          });

          const snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Getting Error!',
              message: "Cannot able to send Email.",
              contentType: ContentType.warning,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
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
      }
      setState(() {
        index;
      });
    }
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    await _firestore
        .collection(widget.eventDetails['name'])
        .doc('Student_details')
        .collection('Alumni')
        .doc("QuickAdd_details")
        .set({
      'sheet_id': sheet_id_Controller.text,
      'count': count + data.length
    });
    setState(() {
      updatingLoadingScreen = false;
      data.clear;
    });
  }

  Future<void> _addAlumniStudent(int index) async {
    setState(() {
      loadingScreen = true;
    });
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      final DocumentReference docRef = await _firestore
          .collection(widget.eventDetails['name'])
          .doc('Student_details')
          .collection('Alumni')
          .add({
        'name': data[index]['name'],
        'college_name': data[index]['college'],
        'department_name': data[index]['department'],
        'passout_year': data[index]['passout_year'],
        'company_name': data[index]['company_name'],
        'designation': data[index]['designation'],
        'gender': data[index]['gender'],
        'email': data[index]['email'],
        'mobile_number': data[index]['mobile_number'],
        'attended': 'no'
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "Student_details;;Alumni;;$docId";

      MailServiceByAPI mail = MailServiceByAPI();

      bool response = await mail.sendEmailViaAppScript(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          data[index]['email'],
          qrData,
          widget.eventDetails,
          backgroundImageResponse);

      if (response == true) {
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Successfully added student',
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        setState(() {
          loadingScreen = false;
        });
      } else {
        await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Student_details')
            .collection('Alumni')
            .doc(docId)
            .delete();
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Getting Error!',
            message: "Cannot able to send Email check your connection once!",
            contentType: ContentType.warning,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        setState(() {
          loadingScreen = false;
        });
      }
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
    }
  }

  Future<void> _addRangeFaculties() async {
    setState(() {
      updatingLoadingScreen = true;
    });
    for (index = int.parse(start_Controller.text);
        index < int.parse(end_Controller.text);
        index++) {
      try {
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;

        final DocumentReference docRef = await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Faculty_details')
            .collection('List')
            .add({
          'name': data[index]['name'],
          'college_name': data[index]['college'],
          'department_name': data[index]['department'],
          'designation': data[index]['designation'],
          'gender': data[index]['gender'],
          'employee_id': data[index]['employee_id'],
          'number_of_guest': data[index]['number_of_guest'],
          'email': data[index]['email'],
          'mobile_number': data[index]['mobile_number'],
          'attended': 'no',
          'count': countCommas(data[index]['number_of_guest']) + 1,
        });

        // Get the document ID
        final String docId = docRef.id;

        final String qrData = "Faculty_details;;List;;$docId";

        MailService mail = MailService();

        bool response = await mail.mailGenerate(
            "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
            data[index]['email'],
            qrData,
            widget.eventDetails,
            0,
            backgroundImageResponse);

        // MailServiceByAPI mail = MailServiceByAPI();
        //
        // bool response = await mail.sendEmailViaAppScript(
        //     "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
        //     data[index]['email'],
        //     qrData,
        //     widget.eventDetails,
        //     backgroundImageResponse);

        if (response != true) {
          final FirebaseFirestore _firestore = FirebaseFirestore.instance;
          await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Faculty_details')
              .collection('List')
              .doc(docId)
              .delete();

          final DocumentReference docRef = await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Faculty_details')
              .collection('List_error')
              .add({
            'name': data[index]['name'],
            'college_name': data[index]['college'],
            'department_name': data[index]['department'],
            'designation': data[index]['designation'],
            'gender': data[index]['gender'],
            'employee_id': data[index]['employee_id'],
            'number_of_guest': data[index]['number_of_guest'],
            'email': data[index]['email'],
            'mobile_number': data[index]['mobile_number'],
            'attended': 'no',
            'count': countCommas(data[index]['number_of_guest'].text) + 1,
          });

          const snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Getting Error!',
              message: "Cannot able to send Email.",
              contentType: ContentType.warning,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
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
      }
      setState(() {
        index;
      });
    }
    setState(() {
      updatingLoadingScreen = false;
    });
  }

  Future<void> _addAllFaculties() async {
    setState(() {
      updatingLoadingScreen = true;
    });
    int count = 0;
    if (quickAddDetails.isNotEmpty) {
      count = quickAddDetails['count'];
    }
    for (index = 0; index < data.length; index++) {
      try {
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;

        final DocumentReference docRef = await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Faculty_details')
            .collection('List')
            .add({
          'name': data[index]['name'],
          'college_name': data[index]['college'],
          'department_name': data[index]['department'],
          'designation': data[index]['designation'],
          'gender': data[index]['gender'],
          'employee_id': data[index]['employee_id'],
          'number_of_guest': data[index]['number_of_guest'],
          'email': data[index]['email'],
          'mobile_number': data[index]['mobile_number'],
          'attended': 'no',
          'count': countCommas(data[index]['number_of_guest']) + 1,
        });

        // Get the document ID
        final String docId = docRef.id;

        final String qrData = "Faculty_details;;List;;$docId";

        MailService mail = MailService();

        bool response = await mail.mailGenerate(
            "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
            data[index]['email'],
            qrData,
            widget.eventDetails,
            0,
            backgroundImageResponse);

        // MailServiceByAPI mail = MailServiceByAPI();
        //
        // bool response = await mail.sendEmailViaAppScript(
        //     "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
        //     data[index]['email'],
        //     qrData,
        //     widget.eventDetails,
        //     backgroundImageResponse);

        if (response != true) {
          final FirebaseFirestore _firestore = FirebaseFirestore.instance;
          await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Faculty_details')
              .collection('List')
              .doc(docId)
              .delete();

          final DocumentReference docRef = await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Faculty_details')
              .collection('List_error')
              .add({
            'name': data[index]['name'],
            'college_name': data[index]['college'],
            'department_name': data[index]['department'],
            'designation': data[index]['designation'],
            'gender': data[index]['gender'],
            'employee_id': data[index]['employee_id'],
            'number_of_guest': data[index]['number_of_guest'],
            'email': data[index]['email'],
            'mobile_number': data[index]['mobile_number'],
            'attended': 'no',
            'count': countCommas(data[index]['number_of_guest'].text) + 1,
          });

          const snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Getting Error!',
              message: "Cannot able to send Email.",
              contentType: ContentType.warning,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
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
      }
      setState(() {
        index;
      });
    }
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    await _firestore
        .collection(widget.eventDetails['name'])
        .doc('Faculty_details')
        .collection('List')
        .doc("QuickAdd_details")
        .set({
      'sheet_id': sheet_id_Controller.text,
      'count': count + data.length
    });
    setState(() {
      updatingLoadingScreen = false;
      data.clear;
    });
  }

  Future<void> _addFaculty(int index) async {
    setState(() {
      loadingScreen = true;
    });
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      final DocumentReference docRef = await _firestore
          .collection(widget.eventDetails['name'])
          .doc('Faculty_details')
          .collection('List')
          .add({
        'name': data[index]['name'],
        'college_name': data[index]['college'],
        'department_name': data[index]['department'],
        'designation': data[index]['designation'],
        'gender': data[index]['gender'],
        'employee_id': data[index]['employee_id'],
        'number_of_guest': data[index]['number_of_guest'],
        'email': data[index]['email'],
        'mobile_number': data[index]['mobile_number'],
        'attended': 'no',
        'count': countCommas(data[index]['number_of_guest']) + 1,
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "Faculty_details;;List;;$docId";

      MailService mail = MailService();

      bool response = await mail.mailGenerate(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          data[index]['email'],
          qrData,
          widget.eventDetails,
          0,
          backgroundImageResponse);

      // MailServiceByAPI mail = MailServiceByAPI();
      //
      // bool response = await mail.sendEmailViaAppScript(
      //     "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
      //     data[index]['email'],
      //     qrData,
      //     widget.eventDetails,
      //     backgroundImageResponse);

      if (response == true) {
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Successfully added student',
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        setState(() {
          loadingScreen = false;
        });
      } else {
        await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Faculty_details')
            .collection('List')
            .doc(docId)
            .delete();
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Getting Error!',
            message: "Cannot able to send Email check your connection once!",
            contentType: ContentType.warning,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        setState(() {
          loadingScreen = false;
        });
      }
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
    }
  }

  Future<void> _addRangeGuest() async {
    setState(() {
      updatingLoadingScreen = true;
    });
    for (index = int.parse(start_Controller.text);
        index < int.parse(end_Controller.text);
        index++) {
      try {
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;

        final DocumentReference docRef = await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Guest_details')
            .collection('List')
            .add({
          'name': data[index]['name'],
          'college_name': data[index]['college'],
          'institution_name': data[index]['institution'],
          'designation': data[index]['designation'],
          'number_of_guest': data[index]['number_of_guest'],
          'gender': data[index]['gender'],
          'email': data[index]['email'],
          'mobile_number': data[index]['mobile_number'],
          'attended': 'no'
        });

        // Get the document ID
        final String docId = docRef.id;

        final String qrData = "Guest_details;;List;;$docId";

        MailService mail = MailService();

        bool response = await mail.mailGenerate(
            "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
            data[index]['email'],
            qrData,
            widget.eventDetails,
            0,
            backgroundImageResponse);

        // MailServiceByAPI mail = MailServiceByAPI();
        //
        // bool response = await mail.sendEmailViaAppScript(
        //     "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
        //     data[index]['email'],
        //     qrData,
        //     widget.eventDetails,
        //     backgroundImageResponse);

        if (response != true) {
          final FirebaseFirestore _firestore = FirebaseFirestore.instance;
          await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Guest_details')
              .collection('List')
              .doc(docId)
              .delete();

          final DocumentReference docRef = await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Guest_details')
              .collection('List_error')
              .add({
            'name': data[index]['name'],
            'college_name': data[index]['college'],
            'institution_name': data[index]['institution'],
            'designation': data[index]['designation'],
            'number_of_guest': data[index]['number_of_guest'],
            'gender': data[index]['gender'],
            'email': data[index]['email'],
            'mobile_number': data[index]['mobile_number'],
            'attended': 'no'
          });

          const snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Getting Error!',
              message: "Cannot able to send Email.",
              contentType: ContentType.warning,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
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
      }
      setState(() {
        index;
      });
    }
    setState(() {
      updatingLoadingScreen = false;
    });
  }

  Future<void> _addAllGuest() async {
    if (widget.eventDetails['email']) {
      setState(() {
        updatingLoadingScreen = true;
      });
      int count = 0;
      if (quickAddDetails.isNotEmpty) {
        count = quickAddDetails['count'];
      }
      for (index = 0; index < data.length; index++) {
        try {
          final FirebaseFirestore _firestore = FirebaseFirestore.instance;

          final DocumentReference docRef = await _firestore
              .collection(widget.eventDetails['name'])
              .doc('Guest_details')
              .collection('List')
              .add({
            'name': data[index]['name'],
            'college_name': data[index]['college'],
            'institution_name': data[index]['institution'],
            'designation': data[index]['designation'],
            'number_of_guest': data[index]['number_of_guest'],
            'gender': data[index]['gender'],
            'email': data[index]['email'],
            'mobile_number': data[index]['mobile_number'],
            'attended': 'no'
          });

          // Get the document ID
          final String docId = docRef.id;

          final String qrData = "Guest_details;;List;;$docId";

          MailService mail = MailService();

          bool response = await mail.mailGenerate(
              "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
              data[index]['email'],
              qrData,
              widget.eventDetails,
              0,
              backgroundImageResponse);

          // MailServiceByAPI mail = MailServiceByAPI();
          //
          // bool response = await mail.sendEmailViaAppScript(
          //     "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          //     data[index]['email'],
          //     qrData,
          //     widget.eventDetails,
          //     backgroundImageResponse);

          if (response != true) {
            final FirebaseFirestore _firestore = FirebaseFirestore.instance;
            await _firestore
                .collection(widget.eventDetails['name'])
                .doc('Guest_details')
                .collection('List')
                .doc(docId)
                .delete();

            final DocumentReference docRef = await _firestore
                .collection(widget.eventDetails['name'])
                .doc('Guest_details')
                .collection('List_error')
                .add({
              'name': data[index]['name'],
              'college_name': data[index]['college'],
              'institution_name': data[index]['institution'],
              'designation': data[index]['designation'],
              'number_of_guest': data[index]['number_of_guest'],
              'gender': data[index]['gender'],
              'email': data[index]['email'],
              'mobile_number': data[index]['mobile_number'],
              'attended': 'no'
            });

            const snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Getting Error!',
                message: "Cannot able to send Email.",
                contentType: ContentType.warning,
              ),
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
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
        }
        setState(() {
          index;
        });
      }
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      await _firestore
          .collection(widget.eventDetails['name'])
          .doc('Guest_details')
          .collection('List')
          .doc("QuickAdd_details")
          .set({
        'sheet_id': sheet_id_Controller.text,
        'count': count + data.length
      });
      setState(() {
        updatingLoadingScreen = false;
        data.clear;
      });
    } else {
      setState(() {
        loadingScreen = true;
      });
      Map<String, dynamic> jsonData = {};

      // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      //     .collection(widget.eventDetails[
      //         'name']) // Assume eventDetails contains 'name' of the event
      //     .doc('Guest_details')
      //     .collection('List')
      //     .get();
      //
      // int i = 0;
      //
      // for (var doc in querySnapshot.docs) {
      //   i++;
      //   if (i <= 488) {
      //     continue;
      //   }
      //   jsonData.addAll({"${doc['name']}": "Guest_details;;List;;${doc.id}"});
      // }
      //
      // jsonData.addAll({"event_name": "p", "folder_name": "pass"});

      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      for (int index = 0; index < data.length; index++) {
        final DocumentReference docRef = await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Guest_details')
            .collection('List')
            .add({
          'name': data[index]['name'],
          'college_name': data[index]['college'],
          'institution_name': data[index]['institution'],
          'designation': data[index]['designation'],
          'number_of_guest': data[index]['number_of_guest'],
          'gender': data[index]['gender'],
          'email': data[index]['email'],
          'mobile_number': data[index]['mobile_number'],
          'attended': 'no'
        });

        // Get the document ID
        final String docId = docRef.id;

        final String qrData = "Guest_details;;List;;$docId";

        jsonData.addAll({data[index]['name']: qrData});
      }
      jsonData.addAll({"event_name": "p", "folder_name": "pass"});
      print("uploading Data");
      // print(jsonData);
      await generatePassLocally(jsonData);
      setState(() {
        loadingScreen = false;
      });
    }
  }

  Future<void> _addGuest(int index) async {
    setState(() {
      loadingScreen = true;
    });
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      final DocumentReference docRef = await _firestore
          .collection(widget.eventDetails['name'])
          .doc('Guest_details')
          .collection('List')
          .add({
        'name': data[index]['name'],
        'college_name': data[index]['college'],
        'institution_name': data[index]['institution'],
        'designation': data[index]['designation'],
        'number_of_guest': data[index]['number_of_guest'],
        'gender': data[index]['gender'],
        'email': data[index]['email'],
        'mobile_number': data[index]['mobile_number'],
        'attended': 'no'
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "Guest_details;;List;;$docId";

      MailServiceByAPI mail = MailServiceByAPI();

      bool response = await mail.sendEmailViaAppScript(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          data[index]['email'],
          qrData,
          widget.eventDetails,
          backgroundImageResponse);

      if (response == true) {
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Successfully added student',
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        setState(() {
          loadingScreen = false;
        });
      } else {
        await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Guest_details')
            .collection('List')
            .doc(docId)
            .delete();
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Getting Error!',
            message: "Cannot able to send Email check your connection once!",
            contentType: ContentType.warning,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        setState(() {
          loadingScreen = false;
        });
      }
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
    }
  }

  Future<void> _addRangeOnSpot() async {
    setState(() {
      updatingLoadingScreen = true;
    });
    for (index = int.parse(start_Controller.text);
        index < int.parse(end_Controller.text);
        index++) {
      try {
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;

        final DocumentReference docRef = await _firestore
            .collection(widget.eventDetails['name'])
            .doc('OnSpotEntry_details')
            .collection('List')
            .add({
          'name': data[index]['name'],
          'gender': data[index]['gender'],
          'email': data[index]['email'],
          'mobile_number': data[index]['mobile_number'],
          'transaction_id': data[index]['transaction_id'],
          'attended': 'no'
        });

        // Get the document ID
        final String docId = docRef.id;

        final String qrData = "OnSpotEntry_details;;List;;$docId";

        MailService mail = MailService();

        bool response = await mail.mailGenerate(
            "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
            data[index]['email'],
            qrData,
            widget.eventDetails,
            0,
            backgroundImageResponse);

        // MailServiceByAPI mail = MailServiceByAPI();
        //
        // bool response = await mail.sendEmailViaAppScript(
        //     "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
        //     data[index]['email'],
        //     qrData,
        //     widget.eventDetails,
        //     backgroundImageResponse);

        if (response != true) {
          final FirebaseFirestore _firestore = FirebaseFirestore.instance;
          await _firestore
              .collection(widget.eventDetails['name'])
              .doc('OnSpotEntry_details')
              .collection('List')
              .doc(docId)
              .delete();

          final DocumentReference docRef = await _firestore
              .collection(widget.eventDetails['name'])
              .doc('OnSpotEntry_details')
              .collection('List_error')
              .add({
            'name': data[index]['name'],
            'gender': data[index]['gender'],
            'email': data[index]['email'],
            'mobile_number': data[index]['mobile_number'],
            'transaction_id': data[index]['transaction_id'],
            'attended': 'no'
          });

          const snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Getting Error!',
              message: "Cannot able to send Email.",
              contentType: ContentType.warning,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
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
      }
      setState(() {
        index;
      });
    }
    setState(() {
      updatingLoadingScreen = false;
    });
  }

  Future<void> _addAllOnSpot() async {
    if (widget.eventDetails['email']) {
      setState(() {
        updatingLoadingScreen = true;
      });
      int count = 0;
      if (quickAddDetails.isNotEmpty) {
        count = quickAddDetails['count'];
      }
      for (index = 0; index < data.length; index++) {
        try {
          final FirebaseFirestore _firestore = FirebaseFirestore.instance;

          final DocumentReference docRef = await _firestore
              .collection(widget.eventDetails['name'])
              .doc('OnSpotEntry_details')
              .collection('List')
              .add({
            'name': data[index]['name'],
            'gender': data[index]['gender'],
            'email': data[index]['email'],
            'mobile_number': data[index]['mobile_number'],
            'transaction_id': data[index]['transaction_id'],
            'attended': 'no'
          });

          // Get the document ID
          final String docId = docRef.id;

          final String qrData = "OnSpotEntry_details;;List;;$docId";

          MailService mail = MailService();

          bool response = await mail.mailGenerate(
              "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
              data[index]['email'],
              qrData,
              widget.eventDetails,
              0,
              backgroundImageResponse);

          // MailServiceByAPI mail = MailServiceByAPI();
          //
          // bool response = await mail.sendEmailViaAppScript(
          //     "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          //     data[index]['email'],
          //     qrData,
          //     widget.eventDetails,
          //     backgroundImageResponse);

          if (response != true) {
            final FirebaseFirestore _firestore = FirebaseFirestore.instance;
            await _firestore
                .collection(widget.eventDetails['name'])
                .doc('OnSpotEntry_details')
                .collection('List')
                .doc(docId)
                .delete();

            final DocumentReference docRef = await _firestore
                .collection(widget.eventDetails['name'])
                .doc('OnSpotEntry_details')
                .collection('List_error')
                .add({
              'name': data[index]['name'],
              'gender': data[index]['gender'],
              'email': data[index]['email'],
              'mobile_number': data[index]['mobile_number'],
              'transaction_id': data[index]['transaction_id'],
              'attended': 'no'
            });

            const snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Getting Error!',
                message: "Cannot able to send Email.",
                contentType: ContentType.warning,
              ),
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
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
        }
        setState(() {
          index;
        });
      }
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      await _firestore
          .collection(widget.eventDetails['name'])
          .doc('Guest_details')
          .collection('List')
          .doc("QuickAdd_details")
          .set({
        'sheet_id': sheet_id_Controller.text,
        'count': count + data.length
      });
      setState(() {
        updatingLoadingScreen = false;
        data.clear;
      });
    } else {
      setState(() {
        loadingScreen = true;
      });
      Map<String, dynamic> jsonData = {};

//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection(widget.eventDetails[
//       'name']) // Assume eventDetails contains 'name' of the event
//           .doc('Student_details')
//           .collection('Regular')
//           .get();
//
// // Convert documents to a list of pairs with 'name' converted to an integer and the document ID
//       List<MapEntry<int, String>> docEntries = querySnapshot.docs.map((doc) {
//         // Parse the 'name' field as an integer (assuming 'name' field is a continuous number in string form)
//         int numericName = int.parse(doc['name']);
//         return MapEntry(numericName, doc.id);
//       }).toList();
//
// // Sort the entries by the integer 'name' field
//       docEntries.sort((a, b) => a.key.compareTo(b.key));
//
// // Remove the first 4000 entries
//       if (docEntries.length > 4000) {
//         docEntries = docEntries.sublist(4000);
//       }
//
// // Populate jsonData with sorted entries
//       int i = 0;
//       for (var entry in docEntries) {
//         i++;
//         jsonData["$i"] = "Student_details;;Regular;;${entry.value}"; // doc.id
//       }
//
//       // print("Processed JSON data: $jsonData");
//       print(jsonData.length);
//
//       jsonData.addAll({"event_name": "p", "folder_name": "pass"});

      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      for (int index = 0; index < data.length; index++) {
        final DocumentReference docRef = await _firestore
            .collection(widget.eventDetails['name'])
            .doc('OnSpotEntry_details')
            .collection('List')
            .add({
          'name': data[index]['name'],
          'gender': data[index]['gender'],
          'email': data[index]['email'],
          'mobile_number': data[index]['mobile_number'],
          'transaction_id': data[index]['transaction_id'],
          'attended': 'no'
        });

        // Get the document ID
        final String docId = docRef.id;

        final String qrData = "OnSpotEntry_details;;List;;$docId";

        jsonData.addAll({data[index]['name']: qrData});
      }
      jsonData.addAll({"event_name": "p", "folder_name": "pass"});
      print("uploading Data");
      // print(jsonData);
      await generatePassLocally(jsonData);
      setState(() {
        loadingScreen = false;
      });
    }
  }

  Future<void> _addOnSpot(int index) async {
    setState(() {
      loadingScreen = true;
    });
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      final DocumentReference docRef = await _firestore
          .collection(widget.eventDetails['name'])
          .doc('OnSpotEntry_details')
          .collection('List')
          .add({
        'name': data[index]['name'],
        'gender': data[index]['gender'],
        'email': data[index]['email'],
        'mobile_number': data[index]['mobile_number'],
        'transaction_id': data[index]['transaction_id'],
        'attended': 'no'
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "OnSpotEntry_details;;List;;$docId";

      MailServiceByAPI mail = MailServiceByAPI();

      bool response = await mail.sendEmailViaAppScript(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          data[index]['email'],
          qrData,
          widget.eventDetails,
          backgroundImageResponse);

      if (response == true) {
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Successfully added student',
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        setState(() {
          loadingScreen = false;
        });
      } else {
        await _firestore
            .collection(widget.eventDetails['name'])
            .doc('OnSpotEntry_details')
            .collection('List')
            .doc(docId)
            .delete();
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Getting Error!',
            message: "Cannot able to send Email check your connection once!",
            contentType: ContentType.warning,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        setState(() {
          loadingScreen = false;
        });
      }
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
    }
  }

  Future<void> generatePassLocally(var data) async {
    Directory directory = await getApplicationDocumentsDirectory();

    // Add event_name and folder_name to the data
    String eventName = data['event_name']; // Replace with your event name
    String folderName = data['folder_name']; // Replace with your folder name

    // Split data into batches of 250 items each
    List<Map<String, dynamic>> batches =
        _createBatches(data, 250, eventName, folderName);

    // Process each batch sequentially (one by one)
    for (int i = 0; i < batches.length; i++) {
      debugPrint('Processing batch ${i + 1}/${batches.length}');
      bool success = await _processBatch(
          batches[i], directory); // Wait for the current batch to finish
      if (!success) {
        debugPrint(
            'Error: Failed to process batch ${i + 1}. Stopping further execution.');
        return; // Stop further batches if any batch fails
      }
    }

    debugPrint('All batches processed successfully.');
  }

  /// Helper function to split data into batches of given size
  List<Map<String, dynamic>> _createBatches(Map<String, dynamic> data,
      int batchSize, String eventName, String folderName) {
    List<Map<String, dynamic>> batches = [];
    List<MapEntry<String, dynamic>> entries = data.entries.toList();

    for (int i = 0; i < entries.length; i += batchSize) {
      Map<String, dynamic> batch =
          Map.fromEntries(entries.skip(i).take(batchSize));

      // Add event_name and folder_name to the batch
      batch['event_name'] = eventName;
      batch['folder_name'] = folderName;

      batches.add(batch);
    }

    return batches;
  }

  /// Helper function to process a single batch and send it to the server
  Future<bool> _processBatch(
      Map<String, dynamic> batch, Directory directory) async {
    try {
      String filePath = '${directory.path}/data.json';

      // Write the batch data to a JSON file
      File file = File(filePath);
      String jsonString = jsonEncode(batch);
      await file.writeAsString(jsonString);

      if (!file.existsSync()) {
        debugPrint('File not found at $filePath');
        return false;
      }

      debugPrint('File located at: $filePath');

      // Create the multipart request
      var uri =
          Uri.parse('http://192.168.0.105/event_management/generatePasses.php');
      var request = http.MultipartRequest('POST', uri);

      // Attach the JSON file to the request
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send the request and wait for the response
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();

        if (responseBody.trim() == "Done") {
          debugPrint('Success: Batch processed and QR codes generated.');
          return true; // Success, proceed to the next batch
        } else {
          _handleResponse(responseBody);
          return false; // Failed, stop further execution
        }
      } else {
        debugPrint(
            'Failed to upload file. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    } finally {
      // Delete the file after processing completes
      await _deleteFile('${directory.path}/data.json');
    }
  }

  /// Helper function to handle the server response
  void _handleResponse(String responseBody) {
    try {
      var jsonResponse = jsonDecode(responseBody);
      if (jsonResponse.containsKey('count')) {
        debugPrint('Data Count: ${jsonResponse['count']}');
      } else if (jsonResponse.containsKey('error')) {
        debugPrint('Error: ${jsonResponse['error']}');
      } else {
        debugPrint('Unexpected Response: $responseBody');
      }
    } catch (e) {
      debugPrint('Unexpected Response: $responseBody');
    }
  }

  /// Helper function to delete the JSON file
  Future<void> _deleteFile(String path) async {
    try {
      File file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('File deleted successfully.');
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  @override
  void initState() {
    _fetchCurrentDetails();
    _downloadImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.searchFor == "Regular") {
      return Scaffold(
        // Allows the body to extend behind the AppBar
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Makes the AppBar transparent
          elevation: 0, // Removes the shadow
          title: const Text(
            "Quick Add...",
            style: TextStyle(
              color: Color(0xFF7464bc), // Sets the title text color
              fontWeight: FontWeight.bold, // Optional: makes the text bold
              fontSize: 20, // Optional: sets the font size
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: errorData.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ErrorScreen(
                              errorData: errorData,
                              eventDetails: widget.eventDetails,
                              searchFor: widget.searchFor,
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
                      icon: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    )
                  : const Center(),
            )
          ],
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
                              "Sheet ID :",
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
                              controller: sheet_id_Controller,
                              focusNode: sheet_id,
                              onEditingComplete: () {
                                sheet_id.unfocus();
                              },
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFF7464bc), // Muted violet
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.link,
                                    color: Color(0xFF7464bc)),
                                suffix: GestureDetector(
                                  child: const Icon(Icons.clear,
                                      color: Color(0xFF7464bc)),
                                  onTap: () {
                                    sheet_id_Controller.clear();
                                  },
                                ),
                                filled: true,
                                fillColor:
                                    const Color(0xFFded9ee), // Light lavender
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
                                hintText: "Sheet ID",
                                hintStyle: TextStyle(
                                    color: const Color(0xFF7464bc)
                                        .withOpacity(0.5)),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 30,
                                bottom: 50,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _get_form_data();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  backgroundColor: const Color(0xFF7464bc),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text(
                                    "Get Data!",
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
                  ),
                  is_data_available
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Count : ${data.length}",
                                style: const TextStyle(
                                  color: Color(0xFF7464bc),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    end_count = data.length;
                                  });
                                  _addAllRegularStudents();
                                },
                                icon: const Icon(Icons.add_link),
                                label: const Text(
                                  "Add All",
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  getRangeModalBottomSheet(context);
                                },
                                icon: const Icon(Icons.add_link),
                                label: const Text(
                                  "Add Range",
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Center(),
                  is_data_available
                      ? Padding(
                          padding: const EdgeInsets.symmetric(),
                          child: ListView.builder(
                            shrinkWrap:
                                true, // This makes the ListView take only the required height
                            physics:
                                const NeverScrollableScrollPhysics(), // Disables the inner scrolling
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: Color(0xFF7464bc),
                                ),
                                title: Text(
                                  "${data[index]['name']}",
                                  style: const TextStyle(
                                    color: Color(0xFF7464bc),
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Request to join.',
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                                trailing: ElevatedButton.icon(
                                  onPressed: () async {
                                    await _addRegularStudent(index);
                                  },
                                  icon: const Icon(Icons.add_link),
                                  label: const Text(
                                    "Add",
                                    style: TextStyle(
                                      color: Color(0xFF7464bc),
                                    ),
                                  ),
                                ),
                                splashColor: const Color(0x91a291da),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Text(
                            "No Responses yet.",
                            style: TextStyle(
                              color: Color(0xFF7464bc),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            loadingScreen
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
                : const Center(),
            updatingLoadingScreen
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: const Color(0xFF7464bc),
                            size: 35,
                          ),
                        ),
                        Text(
                          "$index / $end_count added",
                          style: const TextStyle(
                            color:
                                Color(0xFF7464bc), // Sets the title text color
                            fontWeight: FontWeight
                                .bold, // Optional: makes the text bold
                            fontSize: 20, // Optional: sets the font size
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center()
          ],
        ),
      );
    } else if (widget.searchFor == "Alumni") {
      return Scaffold(
        // Allows the body to extend behind the AppBar
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Makes the AppBar transparent
          elevation: 0, // Removes the shadow
          title: const Text(
            "Quick Add...",
            style: TextStyle(
              color: Color(0xFF7464bc), // Sets the title text color
              fontWeight: FontWeight.bold, // Optional: makes the text bold
              fontSize: 20, // Optional: sets the font size
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: errorData.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ErrorScreen(
                              errorData: errorData,
                              eventDetails: widget.eventDetails,
                              searchFor: widget.searchFor,
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
                      icon: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    )
                  : const Center(),
            )
          ],
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
                              "Sheet ID :",
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
                              controller: sheet_id_Controller,
                              focusNode: sheet_id,
                              onEditingComplete: () {
                                sheet_id.unfocus();
                              },
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFF7464bc), // Muted violet
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.link,
                                    color: Color(0xFF7464bc)),
                                suffix: GestureDetector(
                                  child: const Icon(Icons.clear,
                                      color: Color(0xFF7464bc)),
                                  onTap: () {
                                    sheet_id_Controller.clear();
                                  },
                                ),
                                filled: true,
                                fillColor:
                                    const Color(0xFFded9ee), // Light lavender
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
                                hintText: "Sheet ID",
                                hintStyle: TextStyle(
                                    color: const Color(0xFF7464bc)
                                        .withOpacity(0.5)),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 30,
                                bottom: 50,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _get_form_data();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  backgroundColor: const Color(0xFF7464bc),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text(
                                    "Get Data!",
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
                  ),
                  is_data_available
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Count : ${data.length}",
                                style: const TextStyle(
                                  color: Color(0xFF7464bc),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    end_count = data.length;
                                  });
                                  _addAllAumniStudents();
                                },
                                icon: const Icon(Icons.add_link),
                                label: const Text(
                                  "Add All",
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  getRangeModalBottomSheet(context);
                                },
                                icon: const Icon(Icons.add_link),
                                label: const Text(
                                  "Add Range",
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Center(),
                  is_data_available
                      ? Padding(
                          padding: const EdgeInsets.symmetric(),
                          child: ListView.builder(
                            shrinkWrap:
                                true, // This makes the ListView take only the required height
                            physics:
                                const NeverScrollableScrollPhysics(), // Disables the inner scrolling
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: Color(0xFF7464bc),
                                ),
                                title: Text(
                                  "${data[index]['name']}",
                                  style: const TextStyle(
                                    color: Color(0xFF7464bc),
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Request to join.',
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                                trailing: ElevatedButton.icon(
                                  onPressed: () async {
                                    await _addAlumniStudent(index);
                                  },
                                  icon: const Icon(Icons.add_link),
                                  label: const Text(
                                    "Add",
                                    style: TextStyle(
                                      color: Color(0xFF7464bc),
                                    ),
                                  ),
                                ),
                                splashColor: const Color(0x91a291da),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Text(
                            "No Responses yet.",
                            style: TextStyle(
                              color: Color(0xFF7464bc),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            loadingScreen
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
                : const Center(),
            updatingLoadingScreen
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: const Color(0xFF7464bc),
                            size: 35,
                          ),
                        ),
                        Text(
                          "$index / $end_count added",
                          style: const TextStyle(
                            color:
                                Color(0xFF7464bc), // Sets the title text color
                            fontWeight: FontWeight
                                .bold, // Optional: makes the text bold
                            fontSize: 20, // Optional: sets the font size
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center()
          ],
        ),
      );
    } else if (widget.searchFor == "Faculty") {
      return Scaffold(
        // Allows the body to extend behind the AppBar
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Makes the AppBar transparent
          elevation: 0, // Removes the shadow
          title: const Text(
            "Quick Add...",
            style: TextStyle(
              color: Color(0xFF7464bc), // Sets the title text color
              fontWeight: FontWeight.bold, // Optional: makes the text bold
              fontSize: 20, // Optional: sets the font size
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: errorData.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ErrorScreen(
                              errorData: errorData,
                              eventDetails: widget.eventDetails,
                              searchFor: widget.searchFor,
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
                      icon: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    )
                  : const Center(),
            )
          ],
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
                              "Sheet ID :",
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
                              controller: sheet_id_Controller,
                              focusNode: sheet_id,
                              onEditingComplete: () {
                                sheet_id.unfocus();
                              },
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFF7464bc), // Muted violet
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.link,
                                    color: Color(0xFF7464bc)),
                                suffix: GestureDetector(
                                  child: const Icon(Icons.clear,
                                      color: Color(0xFF7464bc)),
                                  onTap: () {
                                    sheet_id_Controller.clear();
                                  },
                                ),
                                filled: true,
                                fillColor:
                                    const Color(0xFFded9ee), // Light lavender
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
                                hintText: "Sheet ID",
                                hintStyle: TextStyle(
                                    color: const Color(0xFF7464bc)
                                        .withOpacity(0.5)),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 30,
                                bottom: 50,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _get_form_data();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  backgroundColor: const Color(0xFF7464bc),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text(
                                    "Get Data!",
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
                  ),
                  is_data_available
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Count : ${data.length}",
                                style: const TextStyle(
                                  color: Color(0xFF7464bc),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    end_count = data.length;
                                  });
                                  _addAllFaculties();
                                },
                                icon: const Icon(Icons.add_link),
                                label: const Text(
                                  "Add All",
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  getRangeModalBottomSheet(context);
                                },
                                icon: const Icon(Icons.add_link),
                                label: const Text(
                                  "Add Range",
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Center(),
                  is_data_available
                      ? Padding(
                          padding: const EdgeInsets.symmetric(),
                          child: ListView.builder(
                            shrinkWrap:
                                true, // This makes the ListView take only the required height
                            physics:
                                const NeverScrollableScrollPhysics(), // Disables the inner scrolling
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.person_2,
                                  color: Color(0xFF7464bc),
                                ),
                                title: Text(
                                  "${data[index]['name']}",
                                  style: const TextStyle(
                                    color: Color(0xFF7464bc),
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Request to join.',
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                                trailing: ElevatedButton.icon(
                                  onPressed: () async {
                                    await _addFaculty(index);
                                  },
                                  icon: const Icon(Icons.add_link),
                                  label: const Text(
                                    "Add",
                                    style: TextStyle(
                                      color: Color(0xFF7464bc),
                                    ),
                                  ),
                                ),
                                splashColor: const Color(0x91a291da),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Text(
                            "No Responses yet.",
                            style: TextStyle(
                              color: Color(0xFF7464bc),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            loadingScreen
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
                : const Center(),
            updatingLoadingScreen
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: const Color(0xFF7464bc),
                            size: 35,
                          ),
                        ),
                        Text(
                          "$index / $end_count added",
                          style: const TextStyle(
                            color:
                                Color(0xFF7464bc), // Sets the title text color
                            fontWeight: FontWeight
                                .bold, // Optional: makes the text bold
                            fontSize: 20, // Optional: sets the font size
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center()
          ],
        ),
      );
    } else if (widget.searchFor == "Guest") {
      return Scaffold(
        // Allows the body to extend behind the AppBar
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Makes the AppBar transparent
          elevation: 0, // Removes the shadow
          title: const Text(
            "Quick Add...",
            style: TextStyle(
              color: Color(0xFF7464bc), // Sets the title text color
              fontWeight: FontWeight.bold, // Optional: makes the text bold
              fontSize: 20, // Optional: sets the font size
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: errorData.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ErrorScreen(
                              errorData: errorData,
                              eventDetails: widget.eventDetails,
                              searchFor: widget.searchFor,
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
                      icon: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    )
                  : const Center(),
            )
          ],
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
                              "Sheet ID :",
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
                              controller: sheet_id_Controller,
                              focusNode: sheet_id,
                              onEditingComplete: () {
                                sheet_id.unfocus();
                              },
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFF7464bc), // Muted violet
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.link,
                                    color: Color(0xFF7464bc)),
                                suffix: GestureDetector(
                                  child: const Icon(Icons.clear,
                                      color: Color(0xFF7464bc)),
                                  onTap: () {
                                    sheet_id_Controller.clear();
                                  },
                                ),
                                filled: true,
                                fillColor:
                                    const Color(0xFFded9ee), // Light lavender
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
                                hintText: "Sheet ID",
                                hintStyle: TextStyle(
                                    color: const Color(0xFF7464bc)
                                        .withOpacity(0.5)),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 30,
                                bottom: 50,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _get_form_data();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  backgroundColor: const Color(0xFF7464bc),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text(
                                    "Get Data!",
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
                  ),
                  is_data_available
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Count : ${data.length}",
                                style: const TextStyle(
                                  color: Color(0xFF7464bc),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    end_count = data.length;
                                  });
                                  _addAllGuest();
                                },
                                icon: const Icon(Icons.add_link),
                                label: const Text(
                                  "Add All",
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  getRangeModalBottomSheet(context);
                                },
                                icon: const Icon(Icons.add_link),
                                label: const Text(
                                  "Add Range",
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Center(),
                  is_data_available
                      ? Padding(
                          padding: const EdgeInsets.symmetric(),
                          child: ListView.builder(
                            shrinkWrap:
                                true, // This makes the ListView take only the required height
                            physics:
                                const NeverScrollableScrollPhysics(), // Disables the inner scrolling
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.perm_contact_calendar_sharp,
                                  color: Color(0xFF7464bc),
                                ),
                                title: Text(
                                  "${data[index]['name']}",
                                  style: const TextStyle(
                                    color: Color(0xFF7464bc),
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Request to join.',
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                                trailing: ElevatedButton.icon(
                                  onPressed: () async {
                                    await _addGuest(index);
                                  },
                                  icon: const Icon(Icons.add_link),
                                  label: const Text(
                                    "Add",
                                    style: TextStyle(
                                      color: Color(0xFF7464bc),
                                    ),
                                  ),
                                ),
                                splashColor: const Color(0x91a291da),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Text(
                            "No Responses yet.",
                            style: TextStyle(
                              color: Color(0xFF7464bc),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            loadingScreen
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
                : const Center(),
            updatingLoadingScreen
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: const Color(0xFF7464bc),
                            size: 35,
                          ),
                        ),
                        Text(
                          "$index / $end_count added",
                          style: const TextStyle(
                            color:
                                Color(0xFF7464bc), // Sets the title text color
                            fontWeight: FontWeight
                                .bold, // Optional: makes the text bold
                            fontSize: 20, // Optional: sets the font size
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center()
          ],
        ),
      );
    } else {
      return Scaffold(
        // Allows the body to extend behind the AppBar
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Makes the AppBar transparent
          elevation: 0, // Removes the shadow
          title: const Text(
            "Quick Add...",
            style: TextStyle(
              color: Color(0xFF7464bc), // Sets the title text color
              fontWeight: FontWeight.bold, // Optional: makes the text bold
              fontSize: 20, // Optional: sets the font size
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: errorData.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ErrorScreen(
                              errorData: errorData,
                              eventDetails: widget.eventDetails,
                              searchFor: widget.searchFor,
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
                      icon: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    )
                  : const Center(),
            )
          ],
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
                              "Sheet ID :",
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
                              controller: sheet_id_Controller,
                              focusNode: sheet_id,
                              onEditingComplete: () {
                                sheet_id.unfocus();
                              },
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFF7464bc), // Muted violet
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.link,
                                    color: Color(0xFF7464bc)),
                                suffix: GestureDetector(
                                  child: const Icon(Icons.clear,
                                      color: Color(0xFF7464bc)),
                                  onTap: () {
                                    sheet_id_Controller.clear();
                                  },
                                ),
                                filled: true,
                                fillColor:
                                    const Color(0xFFded9ee), // Light lavender
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
                                hintText: "Sheet ID",
                                hintStyle: TextStyle(
                                    color: const Color(0xFF7464bc)
                                        .withOpacity(0.5)),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 30,
                                bottom: 50,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _get_form_data();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  backgroundColor: const Color(0xFF7464bc),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text(
                                    "Get Data!",
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
                  ),
                  is_data_available
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Count : ${data.length}",
                                style: const TextStyle(
                                  color: Color(0xFF7464bc),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    end_count = data.length;
                                  });
                                  _addAllOnSpot();
                                },
                                icon: const Icon(Icons.add_link),
                                label: const Text(
                                  "Add All",
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  getRangeModalBottomSheet(context);
                                },
                                icon: const Icon(Icons.add_link),
                                label: const Text(
                                  "Add Range",
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Center(),
                  is_data_available
                      ? Padding(
                          padding: const EdgeInsets.symmetric(),
                          child: ListView.builder(
                            shrinkWrap:
                                true, // This makes the ListView take only the required height
                            physics:
                                const NeverScrollableScrollPhysics(), // Disables the inner scrolling
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.person_pin,
                                  color: Color(0xFF7464bc),
                                ),
                                title: Text(
                                  "${data[index]['name']}",
                                  style: const TextStyle(
                                    color: Color(0xFF7464bc),
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Request to join.',
                                  style: TextStyle(
                                    color: Color(0xFF7464bc),
                                  ),
                                ),
                                trailing: ElevatedButton.icon(
                                  onPressed: () async {
                                    await _addOnSpot(index);
                                  },
                                  icon: const Icon(Icons.add_link),
                                  label: const Text(
                                    "Add",
                                    style: TextStyle(
                                      color: Color(0xFF7464bc),
                                    ),
                                  ),
                                ),
                                splashColor: const Color(0x91a291da),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Text(
                            "No Responses yet.",
                            style: TextStyle(
                              color: Color(0xFF7464bc),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            loadingScreen
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
                : const Center(),
            updatingLoadingScreen
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: const Color(0xFF7464bc),
                            size: 35,
                          ),
                        ),
                        Text(
                          "$index / $end_count added",
                          style: const TextStyle(
                            color:
                                Color(0xFF7464bc), // Sets the title text color
                            fontWeight: FontWeight
                                .bold, // Optional: makes the text bold
                            fontSize: 20, // Optional: sets the font size
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center()
          ],
        ),
      );
    }
  }
}
