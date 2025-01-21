import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentDetailsScreen extends StatefulWidget {
  bool regular = true;
  var studentInformation;
  StudentDetailsScreen({required this.regular, required this.studentInformation, super.key});

  @override
  State<StatefulWidget> createState() => _StudentDetailsScreen();
}

class _StudentDetailsScreen extends State<StudentDetailsScreen> {

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (widget.regular) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Student Details...",
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
                        // _buildContainer(Icons.add_photo_alternate),
                        _buildQRImageContainer("Student_details;;Regular;;${widget.studentInformation['docId']}", size: 100),
                      ],
                    ),
                  ),
                  _buildInfoRow("Name : ", '${widget.studentInformation['name']}'),
                  _buildInfoRow("College : ", '${widget.studentInformation['college_name']}'),
                  _buildInfoRow("Department : ", '${widget.studentInformation['department_name']}'),
                  _buildInfoRow("Semester : ", '${widget.studentInformation['sem']}'),
                  _buildInfoRow("Enrollment Number : ", '${widget.studentInformation['enrollment_number']}'),
                  _buildInfoRow("Gender : ", '${widget.studentInformation['gender']}'),
                  _buildInfoRow("Email : ", '${widget.studentInformation['email']}'),
                  _buildInfoRow("Mobile Number : ", '${widget.studentInformation['mobile_number']}'),
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
                            "Remove Student",
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
    } else {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Student Details...",
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
                        // _buildContainer(Icons.add_photo_alternate),
                        _buildQRImageContainer("Student_details;;Alumni;;${widget.studentInformation['docId']}", size: 140),
                      ],
                    ),
                  ),
                  _buildInfoRow("Name : ", "${widget.studentInformation['name']}"),
                  _buildInfoRow("College : ", "${widget.studentInformation['college_name']}"),
                  _buildInfoRow("Department : ", "${widget.studentInformation['department_name']}"),
                  _buildInfoRow("Passout Year : ", "${widget.studentInformation['passout_year']}"),
                  _buildInfoRow("Company Name : ", "${widget.studentInformation['company_name']}"),
                  _buildInfoRow("Designation : ", "${widget.studentInformation['designation']}"),
                  _buildInfoRow("Gender : ", "${widget.studentInformation['gender']}"),
                  _buildInfoRow("Mobile Number : ", "${widget.studentInformation['mobile_number']}"),
                  _buildInfoRow("Email : ", "${widget.studentInformation['email']}"),
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
                            "Remove Student",
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
  }

  Widget _buildContainer(IconData icon, {double size = 30}) {
    return AnimatedContainer(
      duration: const Duration(),
      height: 200,
      width: 160,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: const Color(0xFF7464bc)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(icon, color: const Color(0xFF7464bc), size: size),
      ),
    );
  }

  Widget _buildQRImageContainer(String data, {double size = 30}) {
    return AnimatedContainer(
      duration: const Duration(),
      height: 200,
      width: 160,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: const Color(0xFF7464bc)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: QrImageView(
          data: data, // QR code data passed in the parameter
          version: QrVersions.auto, // Automatically adjust the version based on the data
          size: 160, // Adjust size to fit inside the container
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
