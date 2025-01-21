import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:event_management/screens/EventlistScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vibration/vibration.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddEventScreen();
}

class _AddEventScreen extends State<AddEventScreen>
    with SingleTickerProviderStateMixin {
  final event_name_Controller = TextEditingController();
  final event_name = FocusNode();
  String? selectedDate;
  String? selectedTime;
  final textController = TextEditingController();
  final FocusNode textFocusNode = FocusNode();
  int wordCount = 0;
  final int maxWords = 50;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool loadingScreen = false;
  bool email = false;

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

  Future<void> _addEvent() async {
    try {
      setState(() {
        loadingScreen = true;
      });

      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      if (event_name_Controller.text.isEmpty) {
        Vibration.vibrate(duration: 50);
        FocusScope.of(context).requestFocus(event_name);
        setState(() {
          loadingScreen = false;
        });
        return;
      }

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

      // add event in the firebase

      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      await _firestore.collection('Events').doc('EventList').update({
        event_name_Controller.text: selectedDate, // Add a new field here
      });

      DocumentReference docRef =
          _firestore.collection(event_name_Controller.text).doc("EventDetails");
      await docRef.set({
        'name': event_name_Controller.text,
        'date': selectedDate,
        'time': selectedTime,
        'description': textController.text,
        'email': email,
      });

      // await _firestore
      //     .collection(event_name_Controller.text)
      //     .doc('Student_details')
      //     .collection('Regular')
      //     .doc('None')
      //     .set({});
      //
      // await _firestore
      //     .collection(event_name_Controller.text)
      //     .doc('Student_details')
      //     .collection('Alumni')
      //     .doc('None')
      //     .set({});
      //
      // await _firestore
      //     .collection(event_name_Controller.text)
      //     .doc('Faculty_details')
      //     .collection('List')
      //     .doc('None')
      //     .set({});
      //
      // await _firestore
      //     .collection(event_name_Controller.text)
      //     .doc('Guest_details')
      //     .collection('List')
      //     .doc('None')
      //     .set({});

      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Success',
          message: 'You successfully added new event..',
          contentType: ContentType.success,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      setState(() {
        loadingScreen = false;
      });
      Navigator.pop(context); // Pop the current screen
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const EventlistScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
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
      return;
    }

    if (textController.text.isEmpty) {
      Vibration.vibrate(duration: 50);
      FocusScope.of(context).requestFocus(textFocusNode);
      return;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allows the body to extend behind the AppBar
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
                    "Add event name :",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF7464bc),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: TextField(
                    controller: event_name_Controller,
                    focusNode: event_name,
                    onEditingComplete: () {
                      // if (password_Controller.text == "") {
                      //   FocusScope.of(context).requestFocus(password);
                      // } else {
                      event_name.unfocus();
                      // }
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
                        child:
                            const Icon(Icons.clear, color: Color(0xFF7464bc)),
                        onTap: () {
                          event_name_Controller.clear();
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
                      hintText: "Event Name",
                      hintStyle: TextStyle(
                          color: const Color(0xFF7464bc).withOpacity(0.5)),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Add event Date & Time :",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF7464bc),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
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
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: GestureDetector(
                                  onTap: _selectDate,
                                  child: TextField(
                                    enabled: false,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF7464bc), // Muted violet
                                    ),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                          Icons.calendar_today,
                                          color: Color(0xFF7464bc)),
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
                                      hintText: selectedDate,
                                      hintStyle: TextStyle(
                                          color: const Color(0xFF7464bc)
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
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: GestureDetector(
                                  onTap: _selectTime,
                                  child: TextField(
                                    enabled: false,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF7464bc), // Muted violet
                                    ),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.access_time,
                                          color: Color(0xFF7464bc)),
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
                                      hintText: selectedTime,
                                      hintStyle: TextStyle(
                                          color: const Color(0xFF7464bc)
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
                    "Add event Description :",
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
                        maxLines: null,
                        onChanged: _onTextChanged,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF7464bc), // Muted violet
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.text_fields,
                              color: Color(0xFF7464bc)),
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
                          hintText: "Enter Description (Max 50 words)",
                          hintStyle: TextStyle(
                              color: const Color(0xFF7464bc).withOpacity(0.5)),
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
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Checkbox(
                        value: email,
                        onChanged: (bool? value) {
                          setState(() {
                            email = value ?? false;
                          });
                        },
                      ),
                      const Flexible(
                        child: Text(
                          "Do you want to send the pass of the event on the Emails?",
                          style:
                              TextStyle(color: Color(0xFF7464bc), fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
                  child: ScaleTransition(
                    scale: _animation,
                    child: ElevatedButton(
                      onPressed: () {
                        _addEvent();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        backgroundColor: const Color(0xFF8e75e4),
                        shape: const StadiumBorder(), // Soft purple
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          "Add Event",
                          style: TextStyle(
                              fontSize: 25,
                              color: Color(0xFFEAE7DD)), // Light lavender
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
