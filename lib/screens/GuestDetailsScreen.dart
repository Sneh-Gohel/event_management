import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GuestDetailsScreen extends StatefulWidget {
  var guestDetails;
  GuestDetailsScreen({required this.guestDetails, super.key});

  @override
  State<StatefulWidget> createState() => _GuestDetailsScreen();
}

class _GuestDetailsScreen extends State<GuestDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Guest Details...",
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
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQRImageContainer("Guest_details;;List;;${widget.guestDetails['docId']}", size: 200),
                    ],
                  ),
                ),
                _buildInfoRow("Name : ", "${widget.guestDetails['name']}"),
                _buildInfoRow(
                    "College Name : ", "${widget.guestDetails['college_name']}"),
                _buildInfoRow("Institution : ", "${widget.guestDetails['institution_name']}"),
                _buildInfoRow("Designation : ", "${widget.guestDetails['designation']}"),
                _buildInfoRow("Gender : ", "${widget.guestDetails['gender']}"),
                _buildInfoRow("Mobile Number : ", "${widget.guestDetails['mobile_number']}"),
                _buildInfoRow("Email : ", "${widget.guestDetails['email']}"),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 50),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0), backgroundColor: Colors.red,
                        shape: const StadiumBorder(),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          "Remove Guest",
                          style: TextStyle(
                            fontSize: 25,
                            color: Color(0xFFEAE7DD),
                          ),
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

  Widget _buildQRImageContainer(String data, {double size = 30}) {
    return AnimatedContainer(
      duration: const Duration(),
      height: 220,
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: const Color(0xFF7464bc)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: QrImageView(
          data: data, // QR code data passed in the parameter
          version: QrVersions.auto, // Automatically adjust the version based on the data
          size: size, // Adjust size to fit inside the container
          gapless: true, // Whether to add a border around the QR code
          foregroundColor: const Color(0xFF7464bc), // Set QR code color
          errorCorrectionLevel: QrErrorCorrectLevel.Q, // Error correction level (optional)
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xff3f3f9c),
              fontWeight: FontWeight.w900,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF7464bc),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}
