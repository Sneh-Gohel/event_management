import 'package:event_management/screens/InvalidScreen.dart';
import 'package:event_management/screens/VerifiedScreen.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class QRScanninScreen extends StatefulWidget {
  var eventDetails;
  QRScanninScreen({required this.eventDetails, super.key});

  @override
  State<StatefulWidget> createState() => _QRScanningScreen();
}

class _QRScanningScreen extends State<QRScanninScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  String result = '';
  late List<String> slicedStrings;
  Map<String, dynamic> details = {};

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen(
      (scanData) {
        setState(() {
          result = scanData.code!;
          print(result);
          sliceInformation();
        });
        controller.pauseCamera();
      },
    );
  }

  Future<void> sliceInformation() async {
    setState(() {
      slicedStrings = result.split(";;");
    });
    verifyUser();
  }

  Future<void> verifyUser() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    try {

      if(slicedStrings[0]=="Student_details" && slicedStrings[1]=="Alumni")
        {
          try
              {
                DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
                    .collection(widget.eventDetails['name'])
                    .doc(slicedStrings[0])
                    .collection(slicedStrings[1])
                    .doc(slicedStrings[2])
                    .get();
                setState(() {
                  details = docSnapshot.data() as Map<String, dynamic>;
                  details.addAll({'docId': slicedStrings[2]});
                });
              } catch(e){
            print("Yes");
            DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
                .collection(widget.eventDetails['name'])
                .doc("Faculty_details")
                .collection("List")
                .doc(slicedStrings[2])
                .get();
            setState(() {
              details = docSnapshot.data() as Map<String, dynamic>;
              details.addAll({'docId': slicedStrings[2]});
              slicedStrings[0] = "Faculty_details";
              slicedStrings[1] = "List";
            });
            print(details);
          }
        } else{
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection(widget.eventDetails['name'])
            .doc(slicedStrings[0])
            .collection(slicedStrings[1])
            .doc(slicedStrings[2])
            .get();
        setState(() {
          details = docSnapshot.data() as Map<String, dynamic>;
          details.addAll({'docId': slicedStrings[2]});
        });
      }


      await FirebaseFirestore.instance
          .collection(widget.eventDetails['name'])
          .doc(slicedStrings[0])
          .collection(slicedStrings[1])
          .doc(slicedStrings[2])
          .update({'attended': 'yes'});

      if(slicedStrings[0] == "Guest_details"){
        setState((){
          details['attended'] = 'no';
        });
      }

      if (slicedStrings[0] == "Faculty_details" && details['count'] > 0) {
        await FirebaseFirestore.instance
            .collection(widget.eventDetails['name'])
            .doc(slicedStrings[0])
            .collection(slicedStrings[1])
            .doc(slicedStrings[2])
            .update({'count': details['count'] - 1});
        setState(() {
          details['attended'] = 'no';
        });
      }
      if (details['attended'] == 'no') {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                VerifiedScreen(
              details: details,
              slicedStrings: slicedStrings,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
      } else {
        throw Exception();
      }
    } catch (e) {
      setState(() {
        details = {};
      });
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              InvalidScreen(),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Makes the AppBar transparent
        elevation: 0, // Removes the shadow
        iconTheme: const IconThemeData(
          color: Color(0xFF7464bc),
        ),
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(222, 217, 238, 1),
                  Color.fromRGBO(233, 230, 239, 0.89),
                ],
              ),
            ),
          ),
          // Camera QR Scanner with Rounded Corners
          Center(
            child: Container(
              height: 350,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.transparent, // Camera will be shown through
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color.fromRGBO(
                      116, 100, 188, 1), // Foreground color
                  width: 4,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30), // Rounded camera view
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
            ),
          ),
          // Overlay with instructions and a modern look
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const Text(
                  "Scan the QR code",
                  style: TextStyle(
                    color: Color.fromRGBO(116, 100, 188, 1),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    controller?.toggleFlash();
                  },
                  icon: const Icon(Icons.flash_on),
                  label: const Text("Toggle Flash"),
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: const Color.fromRGBO(116, 100, 188, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
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
