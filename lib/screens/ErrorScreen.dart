import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:event_management/services/MailService.dart';
import 'package:event_management/services/MailServiceByAPI.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class ErrorScreen extends StatefulWidget {
  var errorData;
  var eventDetails;
  var searchFor;
  ErrorScreen(
      {required this.errorData,
      required this.eventDetails,
      required this.searchFor,
      super.key});

  @override
  State<StatefulWidget> createState() => _ErrorScreen();
}

class _ErrorScreen extends State<ErrorScreen> {
  bool loadingScreen = false;
  var backgroundImageResponse;

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
        'name': widget.errorData[index]['name'],
        'college_name': widget.errorData[index]['college'],
        'department_name': widget.errorData[index]['department'],
        'sem': widget.errorData[index]['sem'],
        'enrollment_number': widget.errorData[index]['enrollment_number'],
        'gender': widget.errorData[index]['gender'],
        'email': widget.errorData[index]['email'],
        'mobile_number': widget.errorData[index]['mobile_number'],
        'attended': 'no'
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "Student_details;;Regular;;$docId";

      MailService mail = MailService();

      bool response = await mail.mailGenerate(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          widget.errorData[index]['email'],
          qrData,
          widget.eventDetails,
          0,
          backgroundImageResponse);

      if (response == true) {
        // Remove the successfully added student from the errorData list

        await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Student_details')
            .collection('Regular_error')
            .doc(widget.errorData[index]['docId'])
            .delete();

        setState(() {
          widget.errorData.removeAt(index); // Remove student from the list
          loadingScreen = false;
        });

        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Successfully added student and sent the mail',
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } else {
        await _firestore
            .collection(widget.eventDetails['name'])
            .doc('Student_details')
            .collection('Regular')
            .doc(docId)
            .delete();

        setState(() {
          loadingScreen = false;
        });

        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: "Unable to send Email. Please check your connection.",
            contentType: ContentType.warning,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      setState(() {
        loadingScreen = false;
      });

      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error!',
          message: e.toString(),
          contentType: ContentType.warning,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
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
        'name': widget.errorData[index]['name'],
        'college_name': widget.errorData[index]['college'],
        'department_name': widget.errorData[index]['department'],
        'passout_year': widget.errorData[index]['passout_year'],
        'company_name': widget.errorData[index]['company_name'],
        'designation': widget.errorData[index]['designation'],
        'gender': widget.errorData[index]['gender'],
        'email': widget.errorData[index]['email'],
        'mobile_number': widget.errorData[index]['mobile_number'],
        'attended': 'no'
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "Student_details;;Alumni;;$docId";

      MailServiceByAPI mail = MailServiceByAPI();

      bool response = await mail.sendEmailViaAppScript(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          widget.errorData[index]['email'],
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
        'name': widget.errorData[index]['name'],
        'college_name': widget.errorData[index]['college'],
        'department_name': widget.errorData[index]['department'],
        'designation': widget.errorData[index]['designation'],
        'gender': widget.errorData[index]['gender'],
        'employee_id': widget.errorData[index]['employee_id'],
        'number_of_guest': widget.errorData[index]['number_of_guest'],
        'email': widget.errorData[index]['email'],
        'mobile_number': widget.errorData[index]['mobile_number'],
        'attended': 'no',
        'count': countCommas(widget.errorData[index]['number_of_guest']) + 1,
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "Faculty_details;;List;;$docId";

      MailServiceByAPI mail = MailServiceByAPI();

      bool response = await mail.sendEmailViaAppScript(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          widget.errorData[index]['email'],
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
        'name': widget.errorData[index]['name'],
        'college_name': widget.errorData[index]['college'],
        'institution_name': widget.errorData[index]['institution'],
        'designation': widget.errorData[index]['designation'],
        'number_of_guest': widget.errorData[index]['number_of_guest'],
        'gender': widget.errorData[index]['gender'],
        'email': widget.errorData[index]['email'],
        'mobile_number': widget.errorData[index]['mobile_number'],
        'attended': 'no'
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "Guest_details;;List;;$docId";

      MailServiceByAPI mail = MailServiceByAPI();

      bool response = await mail.sendEmailViaAppScript(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          widget.errorData[index]['email'],
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
        'name': widget.errorData[index]['name'],
        'gender': widget.errorData[index]['gender'],
        'email': widget.errorData[index]['email'],
        'mobile_number': widget.errorData[index]['mobile_number'],
        'transaction_id': widget.errorData[index]['transaction_id'],
        'attended': 'no'
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "OnSpotEntry_details;;List;;$docId";

      MailServiceByAPI mail = MailServiceByAPI();

      bool response = await mail.sendEmailViaAppScript(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          widget.errorData[index]['email'],
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

  @override
  void initState() {
    super.initState();
    _downloadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Didn't get mail...",
          style: TextStyle(
            color: Color(0xFF7464bc),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF7464bc),
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
            child: widget.errorData.length != 0
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.errorData.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Color(0xFF7464bc),
                              ),
                              title: Text(
                                "${widget.errorData[index]['name']}",
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
                                  if (widget.searchFor == "Regular") {
                                    _addRegularStudent(index);
                                  } else if (widget.searchFor == "Alumni") {
                                    _addAlumniStudent(index);
                                  } else if (widget.searchFor == "Faculty") {
                                    _addFaculty(index);
                                  } else if (widget.searchFor == "Guest") {
                                    _addGuest(index);
                                  } else {
                                    _addOnSpot(index);
                                  }
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
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      "No Data Found...",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
          ),
          loadingScreen
              ? AnimatedContainer(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
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
        ],
      ),
    );
  }
}
