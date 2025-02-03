import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:event_management/services/MailService.dart';
import 'package:flutter/material.dart';
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

class AddGuestScreen extends StatefulWidget {
  var eventDetails;
  AddGuestScreen({required this.eventDetails, super.key});

  @override
  State<StatefulWidget> createState() => _AddGuestScreen();
}

class _AddGuestScreen extends State<AddGuestScreen>
    with SingleTickerProviderStateMixin {
  final guest_name_Controller = TextEditingController();
  final guest_name = FocusNode();
  final institution_Controller = TextEditingController();
  final institution = FocusNode();
  final designation_Controller = TextEditingController();
  final designation = FocusNode();
  final number_of_guest_Controller = TextEditingController();
  final number_of_guest = FocusNode();
  final email_Controller = TextEditingController();
  final email = FocusNode();
  final mobile_number_Controller = TextEditingController();
  final mobile_number = FocusNode();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool loadingScreen = false;
  var backgroundImageResponse;

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

  Future<void> _addGuest() async {
    if (guest_name_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(guest_name);
      return;
    }

    if (institution_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(institution);
      return;
    }

    if (designation_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(designation);
      return;
    }

    if (number_of_guest_Controller.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(number_of_guest);
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
          .doc('Guest_details')
          .collection('List')
          .add({
        'name': guest_name_Controller.text,
        'college_name': college,
        'institution_name': institution_Controller.text,
        'designation': designation_Controller.text,
        'number_of_guest': number_of_guest_Controller.text,
        'gender': gender,
        'email': email_Controller.text,
        'mobile_number': mobile_number_Controller.text,
        'attended': 'no'
      });

      // Get the document ID
      final String docId = docRef.id;

      final String qrData = "Guest_details;;List;;$docId";

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
            message: 'Successfully added guest',
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
    Navigator.pop(context);
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
          "Add Guest...",
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
                const Padding(
                  padding: EdgeInsets.only(top: 20, left: 20),
                  child: Text(
                    "Add Guest Name :",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF7464bc),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: guest_name_Controller,
                    focusNode: guest_name,
                    onEditingComplete: () {
                      guest_name.unfocus();
                    },
                    keyboardType: TextInputType.name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF7464bc), // Muted violet
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.perm_contact_calendar_sharp,
                          color: Color(0xFF7464bc)),
                      suffix: GestureDetector(
                        child:
                            const Icon(Icons.clear, color: Color(0xFF7464bc)),
                        onTap: () {
                          guest_name_Controller.clear();
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
                      hintText: "Guest Name",
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
                    "Institution name :",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF7464bc),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: institution_Controller,
                    focusNode: institution,
                    onEditingComplete: () {
                      institution.unfocus();
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
                          institution_Controller.clear();
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
                      hintText: "Guest's Institution",
                      hintStyle: TextStyle(
                          color: const Color(0xFF7464bc).withOpacity(0.5)),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20, left: 20),
                  child: Text(
                    "Designation :",
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
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF7464bc)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: "Guest's Designation'",
                      hintStyle: TextStyle(
                          color: const Color(0xFF7464bc).withOpacity(0.5)),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20, left: 20),
                  child: Text(
                    "Number of Guests :",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF7464bc),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: number_of_guest_Controller,
                    focusNode: number_of_guest,
                    onEditingComplete: () {
                      number_of_guest.unfocus();
                    },
                    keyboardType: TextInputType.text,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF7464bc), // Muted violet
                    ),
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.man, color: Color(0xFF7464bc)),
                      suffix: GestureDetector(
                        child:
                            const Icon(Icons.clear, color: Color(0xFF7464bc)),
                        onTap: () {
                          number_of_guest_Controller.clear();
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
                      hintText: "eg. Self, Husband/Wife, Child 1, Child 2",
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
                    "Add Guest's email :",
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
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF7464bc)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: "Guest's email",
                      hintStyle: TextStyle(
                          color: const Color(0xFF7464bc).withOpacity(0.5)),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20, left: 20),
                  child: Text(
                    "Add Guest's mobile number :",
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
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF7464bc)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: "Guest's mobile_number",
                      hintStyle: TextStyle(
                          color: const Color(0xFF7464bc).withOpacity(0.5)),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 50, horizontal: 70),
                  child: ScaleTransition(
                    scale: _animation,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _addGuest();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        backgroundColor: const Color(0xFF8e75e4),
                        shape: const StadiumBorder(), // Soft purple
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          "Add Guest",
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

class DropdownButtonForCollege extends StatefulWidget {
  const DropdownButtonForCollege({super.key});

  @override
  State<DropdownButtonForCollege> createState() => _DropdownButtonForCollege();
}

class _DropdownButtonForCollege extends State<DropdownButtonForCollege> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = college;  // Initialize with global variable
  }

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
          college = value;  // Update global variable
        });
      },
      items: collegeList.map<DropdownMenuItem<String>>(
            (String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
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
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = gender;  // Initialize with global variable
  }

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
          gender = value;  // Update global variable
        });
      },
      items: genderList.map<DropdownMenuItem<String>>(
            (String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        },
      ).toList(),
    );
  }
}