import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;

class MailServiceByAPI {
  Future<String> generatePdf(String backgroundImageUrl, String qrData,
      var backgroundImageResponse) async {
    Stopwatch totalStopwatch = Stopwatch();
    totalStopwatch.start();

    if (backgroundImageResponse == "") {
      final backgroundImageUri = Uri.parse(backgroundImageUrl);
      backgroundImageResponse = await http.get(backgroundImageUri);

      if (backgroundImageResponse.statusCode != 200) {
        throw Exception('Failed to load background image from network');
      }
    }

    final qrCodeImageUri =
    Uri.parse('https://quickchart.io/qr?text=$qrData&size=150');
    final qrCodeResponse = await http.get(qrCodeImageUri);

    if (qrCodeResponse.statusCode != 200) {
      throw Exception('Failed to load QR code from network');
    }

    Uint8List backgroundBytes = backgroundImageResponse.bodyBytes;
    Uint8List qrCodeBytes = qrCodeResponse.bodyBytes;

    img.Image? backgroundImage = img.decodeImage(backgroundBytes);
    img.Image? qrCodeImage = img.decodeImage(qrCodeBytes);

    if (backgroundImage == null || qrCodeImage == null) {
      throw Exception('Failed to decode images');
    }

    img.Image resizedQrCodeImage =
    img.copyResize(qrCodeImage, width: 200, height: 200);
    img.drawImage(backgroundImage, resizedQrCodeImage, dstX: 60, dstY: 1210);

    Uint8List combinedImageBlob =
    Uint8List.fromList(img.encodePng(backgroundImage));

    final pdf = pw.Document();
    final pdfImage = pw.MemoryImage(combinedImageBlob);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(pdfImage),
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/output.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    totalStopwatch.stop();
    print('Total time taken: ${totalStopwatch.elapsedMilliseconds} ms');

    return filePath;
  }

  Future<String> pdfToBase64(String pdfPath) async {
    final file = File(pdfPath);
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<bool> sendEmailViaAppScript(
      String backgroundImage,
      String emailAddress,
      String qrData,
      var eventDetails,
      var backgroundImageResponse) async {
    try {
      String pdfPath =
      await generatePdf(backgroundImage, qrData, backgroundImageResponse);
      String base64Pdf = await pdfToBase64(pdfPath);

      var data = {
        "emailAddress": emailAddress,
        "eventDetails": {
          "name": eventDetails['name'],
          "date": eventDetails['date'],
          "time": eventDetails['time'],
          "description": eventDetails['description'],
        },
        "qrData": qrData,
        "base64Pdf": base64Pdf,
      };

      final response = await http.post(
        Uri.parse(
            "https://script.google.com/macros/s/AKfycbzfXSkz1YPVfYdtHixbCeui3MnegySts-y7XeyMxgxnkM5SDqeo692EswQKeB2kSQvyEQ/exec"), // Your URL here
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      // Check if the response is successful
      if (response.statusCode == 200 || response.statusCode == 302) {
        try {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status'] == 'success') {
            print('Email sent successfully!');
            return true;
          } else {
            print('Error sending email: ${jsonResponse['message']}');
            return false;
          }
        } catch (e) {
          print(e);
          // Handle case where response body is not a JSON
          print('Email sent successfully with status code 302!');
          return true;
        }
      } else {
        print('Failed to send email. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  Future<void> deletePdf(String filePath) async {
    final file = File(filePath);
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}
