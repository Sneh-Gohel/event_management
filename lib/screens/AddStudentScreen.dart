// ignore_for_file: file_names

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:event_management/services/MailService.dart';
import 'package:event_management/services/MailServiceByAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

const List<String> collegeList = <String>[
  'SPCP (Pharmacy)',
  'SPCE (B.Ed)',
  'SPCAM (MBA)',
  'SPCE (Engineering)',
  'SPCC (Commerce)',
  'SPIAS (Applied Science)',
  'SPCAM',
];
const List<String> genderList = <String>[
  'Male',
  'Female',
  'Others...',
];

String college = collegeList.first;
String gender = genderList.first;

class AddStudentScreen extends StatefulWidget {
  bool regular = true;
  var eventDetails;
  AddStudentScreen(
      {required this.regular, required this.eventDetails, super.key});

  @override
  State<StatefulWidget> createState() => _AddStudentScreen();
}

class _AddStudentScreen extends State<AddStudentScreen>
    with SingleTickerProviderStateMixin {
  final student_name_Controller = TextEditingController();
  final student_name = FocusNode();
  final department_name_Controller = TextEditingController();
  final department_name = FocusNode();
  final sem_Controller = TextEditingController();
  final sem = FocusNode();
  final enrollment_number_Controller = TextEditingController();
  final enrollment_number = FocusNode();
  final email_Controller = TextEditingController();
  final email = FocusNode();
  final mobile_number_Controller = TextEditingController();
  final mobile_number = FocusNode();
  final passout_year_Controller = TextEditingController();
  final passout_year = FocusNode();
  final company_name_Controller = TextEditingController();
  final company_name = FocusNode();
  final designation_Controller = TextEditingController();
  final designation = FocusNode();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isIncludePhoto = false;
  bool loadingScreen = false;
  var backgroundImageResponse;

  Future<void> _addRegularStudent() async {
    if (student_name_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(student_name);
      return;
    }

    if (department_name_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(department_name);
      return;
    }

    if (sem_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(sem);
      return;
    }

    if (enrollment_number_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(enrollment_number);
      return;
    }

    if (email_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(email);
      return;
    }

    if (mobile_number_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(mobile_number);
      return;
    }

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
        'name': student_name_Controller.text,
        'college_name': college,
        'department_name': department_name_Controller.text,
        'sem': sem_Controller.text,
        'enrollment_number': enrollment_number_Controller.text,
        'gender': gender,
        'email': email_Controller.text,
        'mobile_number': mobile_number_Controller.text,
        'attended': 'no'
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "Student_details;;Regular;;$docId";

      MailService mail = MailService();

      bool response = await mail.mailGenerate(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          email_Controller.text,
          qrData,
          widget.eventDetails,
          0,
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
    Navigator.pop(context);
  }

  Future<void> _addAlumniStudent() async {
    if (student_name_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(student_name);
      return;
    }

    if (department_name_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(department_name);
      return;
    }

    if (passout_year_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(passout_year);
      return;
    }

    if (company_name_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(company_name);
      return;
    }

    if (designation_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(designation);
      return;
    }

    if (email_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(email);
      return;
    }

    if (mobile_number_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(mobile_number);
      return;
    }

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
        'name': student_name_Controller.text,
        'college_name': college,
        'department_name': department_name_Controller.text,
        'passout_year': passout_year_Controller.text,
        'company_name': company_name_Controller.text,
        'designation': designation_Controller.text,
        'gender': gender,
        'email': email_Controller.text,
        'mobile_number': mobile_number_Controller.text,
        'attended': 'no'
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "Student_details;;Alumni;;$docId";

      // MailService mail = MailService();
      //
      // bool response = await mail.mailGenerate(
      //     "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
      //     email_Controller.text,
      //     qrData,widget.eventDetails,0,backgroundImageResponse);

      MailServiceByAPI mail = MailServiceByAPI();

      bool response = await mail.sendEmailViaAppScript(
          "https://drive.google.com/uc?export=download&id=1NucYbojbilh_4C-ppgOfR5B9k62B-XCO",
          email_Controller.text,
          qrData,
          widget.eventDetails,
          backgroundImageResponse);

      if (response) {
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
            title: 'Error',
            message: "Can't send mail",
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        setState(() {
          loadingScreen = false;
        });
      }

      // if(response == true)
      // {
      //   const snackBar = SnackBar(
      //     elevation: 0,
      //     behavior: SnackBarBehavior.floating,
      //     backgroundColor: Colors.transparent,
      //     content: AwesomeSnackbarContent(
      //       title: 'Success',
      //       message: 'Successfully added student',
      //       contentType: ContentType.success,
      //     ),
      //   );
      //
      //   ScaffoldMessenger.of(context)
      //     ..hideCurrentSnackBar()
      //     ..showSnackBar(snackBar);
      //   setState(() {
      //     loadingScreen = false;
      //   });
      // } else
      // {
      //   await _firestore.collection(widget.eventDetails['name'])
      //       .doc('Student_details')
      //       .collection('Alumni').doc(docId).delete();
      //   const snackBar = SnackBar(
      //     elevation: 0,
      //     behavior: SnackBarBehavior.floating,
      //     backgroundColor: Colors.transparent,
      //     content: AwesomeSnackbarContent(
      //       title: 'Getting Error!',
      //       message: "Cannot able to send Email check your connection once!",
      //       contentType: ContentType.warning,
      //     ),
      //   );
      //
      //   ScaffoldMessenger.of(context)
      //     ..hideCurrentSnackBar()
      //     ..showSnackBar(snackBar);
      //   setState(() {
      //     loadingScreen = false;
      //   });
      // }
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
    Navigator.pop(context);
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
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _downloadImage();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (widget.regular) {
      return Scaffold(
        // Allows the body to extend behind the AppBar
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Makes the AppBar transparent
          elevation: 0, // Removes the shadow
          title: const Text(
            "Add Student...",
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
                    padding: const EdgeInsets.only(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isIncludePhoto,
                          onChanged: (bool? value) {
                            setState(() {
                              isIncludePhoto = value ?? false;
                            });
                          },
                        ),
                        const Text(
                          'Include Photo?',
                          style:
                              TextStyle(color: Color(0xFF7464bc), fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  isIncludePhoto
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: (size.width - 200) / 2, vertical: 20),
                          child: AnimatedContainer(
                            duration: const Duration(),
                            height: 250,
                            width: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFF7464bc),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_photo_alternate,
                                color: Color(0xFF7464bc),
                                size: 30,
                              ),
                            ),
                          ),
                        )
                      : const Center(),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Add Student name :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: student_name_Controller,
                      focusNode: student_name,
                      onEditingComplete: () {
                        student_name.unfocus();
                      },
                      keyboardType: TextInputType.name,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.person, color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            student_name_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student Name",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "College Name :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child:  Row(
                      children: [DropdownButtonForCollege()],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Department name :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: department_name_Controller,
                      focusNode: department_name,
                      onEditingComplete: () {
                        department_name.unfocus();
                      },
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_city,
                            color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            department_name_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student's Department'",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Add Student's semester :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: sem_Controller,
                      focusNode: sem,
                      onEditingComplete: () {
                        sem.unfocus();
                      },
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.onetwothree,
                            color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            sem_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student's Semester'",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Add Student's enrollment number :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: enrollment_number_Controller,
                      focusNode: enrollment_number,
                      onEditingComplete: () {
                        enrollment_number.unfocus();
                      },
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.onetwothree_outlined,
                            color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            enrollment_number_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student's enrollment number",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Gender :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [DropdownButtonForGender()],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Add Student email :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: email_Controller,
                      focusNode: email,
                      onEditingComplete: () {
                        email.unfocus();
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.mail, color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            email_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student's email",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Add Student mobile number :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: mobile_number_Controller,
                      focusNode: mobile_number,
                      onEditingComplete: () {
                        mobile_number.unfocus();
                      },
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.call, color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            mobile_number_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student's mobile_number'",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 50, horizontal: 70),
                    child: ScaleTransition(
                      scale: _animation,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _addRegularStudent();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          backgroundColor: const Color(0xFF8e75e4),
                          shape: const StadiumBorder(), // Soft purple
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            "Add Student",
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
            "Add Student...",
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
                    padding: const EdgeInsets.only(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isIncludePhoto,
                          onChanged: (bool? value) {
                            setState(() {
                              isIncludePhoto = value ?? false;
                            });
                          },
                        ),
                        const Text(
                          'Include Photo?',
                          style:
                              TextStyle(color: Color(0xFF7464bc), fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  isIncludePhoto
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: (size.width - 200) / 2, vertical: 20),
                          child: AnimatedContainer(
                            duration: const Duration(),
                            height: 250,
                            width: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFF7464bc),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_photo_alternate,
                                color: Color(0xFF7464bc),
                                size: 30,
                              ),
                            ),
                          ),
                        )
                      : const Center(),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Add Student name :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: student_name_Controller,
                      focusNode: student_name,
                      onEditingComplete: () {
                        student_name.unfocus();
                      },
                      keyboardType: TextInputType.name,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.person, color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            student_name_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student Name",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "College Name :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [DropdownButtonForCollege()],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Department name :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: department_name_Controller,
                      focusNode: department_name,
                      onEditingComplete: () {
                        department_name.unfocus();
                      },
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_city,
                            color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            department_name_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student's Department'",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Add Student's passout year :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: passout_year_Controller,
                      focusNode: passout_year,
                      onEditingComplete: () {
                        passout_year.unfocus();
                      },
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.onetwothree,
                            color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            passout_year_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student's passout year'",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Add Student's company name :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: company_name_Controller,
                      focusNode: company_name,
                      onEditingComplete: () {
                        company_name.unfocus();
                      },
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.apartment,
                            color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            company_name_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student's company name",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Add Student's designation :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: designation_Controller,
                      focusNode: designation,
                      onEditingComplete: () {
                        designation.unfocus();
                      },
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.engineering,
                            color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            designation_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student's current designation",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Gender :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [DropdownButtonForGender()],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Add Student email :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: email_Controller,
                      focusNode: email,
                      onEditingComplete: () {
                        email.unfocus();
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.mail, color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            email_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student's email",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "Add Student mobile number :",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7464bc),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: mobile_number_Controller,
                      focusNode: mobile_number,
                      onEditingComplete: () {
                        mobile_number.unfocus();
                      },
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF7464bc), // Muted violet
                      ),
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.call, color: Color(0xFF7464bc)),
                        suffix: GestureDetector(
                          child:
                              const Icon(Icons.clear, color: Color(0xFF7464bc)),
                          onTap: () {
                            mobile_number_Controller.clear();
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFded9ee), // Light lavender
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF7464bc)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Student's mobile_number'",
                        hintStyle: TextStyle(
                            color: const Color(0xFF7464bc).withOpacity(0.5)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 50, horizontal: 70),
                    child: ScaleTransition(
                      scale: _animation,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _addAlumniStudent();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          backgroundColor: const Color(0xFF8e75e4),
                          shape: const StadiumBorder(), // Soft purple
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            "Add Student",
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
                : const Center()
          ],
        ),
      );
    }
  }
}

class DropdownButtonForCollege extends StatefulWidget {
  const DropdownButtonForCollege({super.key});

  @override
  State<DropdownButtonForCollege> createState() => _DropdownButtonForCollege();
}

class _DropdownButtonForCollege extends State<DropdownButtonForCollege> {
  String dropdownValue = collegeList.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      elevation: 16,
      style: const TextStyle(color: Color(0xFF8e75e4)),
      underline: Container(
        height: 2,
        color: const Color(0xFF8e75e4),
      ),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
          college = value;
        });
      },
      items: collegeList.map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              overflow:
                  TextOverflow.ellipsis, // Shows "..." when text overflows
              maxLines: 1, // Limits to one line
            ),
          );
        },
      ).toList(),
    );
  }
}

class DropdownButtonForGender extends StatefulWidget {
  const DropdownButtonForGender({super.key});

  @override
  State<DropdownButtonForGender> createState() => _DropdownButtonForGender();
}

class _DropdownButtonForGender extends State<DropdownButtonForGender> {
  String dropdownValue = genderList.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      elevation: 16,
      style: const TextStyle(color: Color(0xFF8e75e4)),
      underline: Container(
        height: 2,
        color: const Color(0xFF8e75e4),
      ),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
          gender = value;
        });
      },
      items: genderList.map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              overflow:
                  TextOverflow.ellipsis, // Shows "..." when text overflows
              maxLines: 1, // Limits to one line
            ),
          );
        },
      ).toList(),
    );
  }
}
