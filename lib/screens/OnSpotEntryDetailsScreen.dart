import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OnSpotEntryDetailsScreen extends StatefulWidget {
  var data;
  OnSpotEntryDetailsScreen({required this.data, super.key});

  @override
  State<StatefulWidget> createState() => _OnSpotEntryDetailsScreen();
}

class _OnSpotEntryDetailsScreen extends State<OnSpotEntryDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Details...",
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
                      _buildQRImageContainer("OnSpotEntry_details;;List;;${widget.data['docId']}", size: 200),
                    ],
                  ),
                ),
                _buildInfoRow("Name : ", "${widget.data['name']}"),
                _buildInfoRow("Gender : ", "${widget.data['gender']}"),
                _buildInfoRow("Mobile Number : ", "${widget.data['mobile_number']}"),
                _buildInfoRow("Email : ", "${widget.data['email']}"),
                _buildInfoRow("Transaction ID : ", "${widget.data['transaction_id']}"),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 50),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        backgroundColor: Colors.red,
                        shape: const StadiumBorder(),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          "Remove Entry",
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
