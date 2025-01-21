import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;

class MailService {
  Future<String> generatePdf(String background_image, String data, var backgroundImageResponse) async {
    Stopwatch stopwatch = Stopwatch();

    if (backgroundImageResponse == "")
      {
        final backgroundImageUri = Uri.parse(background_image);

        // Fetch the background image
        stopwatch.start();
        final backgroundImageResponse = await http.get(backgroundImageUri);
        stopwatch.stop();
        print('Time taken to download background image: ${stopwatch.elapsedMilliseconds} ms');
        stopwatch.reset();

        if (backgroundImageResponse.statusCode != 200) {
          throw Exception('Failed to load background image from network');
        }
      }

    // Fetch the QR code image
    final qrCodeImageUri = Uri.parse('https://quickchart.io/qr?text=$data&size=150');
    stopwatch.start();
    final qrCodeResponse = await http.get(qrCodeImageUri);
    stopwatch.stop();
    print('Time taken to download QR code image: ${stopwatch.elapsedMilliseconds} ms');
    stopwatch.reset();

    if (qrCodeResponse.statusCode != 200) {
      throw Exception('Failed to load QR code from network');
    }

    // Start measuring time for image processing
    stopwatch.start();
    Uint8List backgroundBytes = backgroundImageResponse.bodyBytes;
    Uint8List qrCodeBytes = qrCodeResponse.bodyBytes;

    // Decode images
    img.Image? backgroundImage = img.decodeImage(backgroundBytes);
    img.Image? qrCodeImage = img.decodeImage(qrCodeBytes);

    if (backgroundImage == null || qrCodeImage == null) {
      throw Exception('Failed to decode images');
    }

    // Resize QR code and overlay it
    img.Image resizedQrCodeImage = img.copyResize(qrCodeImage, width: 200, height: 200);
    img.drawImage(backgroundImage, resizedQrCodeImage, dstX: 60,dstY:1210);

    // Encode final image
    Uint8List combinedImageBlob = Uint8List.fromList(img.encodePng(backgroundImage));

    stopwatch.stop();
    print('Time taken for image processing: ${stopwatch.elapsedMilliseconds} ms');
    stopwatch.reset();

    // Start measuring time for PDF generation
    stopwatch.start();
    final pdf = pw.Document();
    final pdfImage = pw.MemoryImage(combinedImageBlob);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(pdfImage),  // Add the image to the PDF
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    if (directory == null) {
      throw Exception('Failed to get application documents directory');
    }

    final filePath = '${directory.path}/output.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    stopwatch.stop();
    print('Time taken to generate PDF: ${stopwatch.elapsedMilliseconds} ms');

    return filePath;
  }

  // Function to send email with attachment
  Future<bool> mailGenerate(String background_image, String mail, String data, var eventDetails, int count, var backgroundImageResponse) async {
    bool isGenerated = false;
    String username = 'spec.event124@gmail.com';
    String password = 'srsd ybvf aahu myml';
    // String username = 'gohelsneh21@gmail.com';
    // String password = 'craz nbge puak ywts';
    // String username = 'nrvaghela3898@gmail.com';
    // String password = 'pepf unbz jhxn gyea';
    // String username = 'spec.event4@gmail.com';
    // String password = 'sswm bkqq bymq stce';

    final smtpServer = gmail(username, password);

    try {
      // Measure time for PDF generation
      Stopwatch stopwatch = Stopwatch();
      stopwatch.start();

      // Generate the PDF and get the file path
      String pdfPath = await generatePdf(background_image, data, backgroundImageResponse);

      stopwatch.stop();
      print('Total time taken for PDF generation and image download: ${stopwatch.elapsedMilliseconds} ms');

      // Measure time for email sending
      stopwatch.reset();
      stopwatch.start();

      // Create a message with an attachment
      final message = Message()
        ..from = Address(username, 'SPEC')
        ..recipients.add(mail)
        ..subject = 'Event Pass'
        ..html = ''' <html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style>
      body {
        font-family: Arial, sans-serif;
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 3% 3% 3% 3%;
        /* height: 100vh; */
        margin: 0;
      }

      .card-container {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        gap: 20px;
      }

      /* Card Styles */
      .card {
        min-width: 300px;
        min-height: 500px;
        padding: 20px; /* Background Gradient */
        background: linear-gradient(
          135deg,
          rgba(222, 217, 238, 1),
          rgba(233, 230, 239, 0.89)
        );
        border: 6px solid #000;
        box-shadow: 12px 12px 0 #000;
        transition: transform 0.3s, box-shadow 0.3s;
      }

      .card:hover {
        transform: translate(-5px, -5px);
        box-shadow: 17px 17px 0 #000;
      }

      .card__title {
        font-size: 24px;
        font-weight: 900;
        color: rgba(116, 100, 188, 1);
        text-transform: uppercase;
        margin-bottom: 15px;
        display: block;
        position: relative;
        overflow: hidden;
      }

      .card__title-2 {
        font-size: 20px;
        font-weight: 900;
        color: rgba(116, 100, 188, 1);
        text-transform: uppercase;
        margin-bottom: 15px;
        display: block;
        position: relative;
        overflow: hidden;
      }

      .card__title::after {
        content: "";
        position: absolute;
        bottom: 0;
        left: 0;
        width: 90%;
        height: 3px;
        background-color: #000;
        transform: translateX(-100%);
        transition: transform 0.3s;
      }

      .card:hover .card__title::after {
        transform: translateX(0);
      }

      .card__content {
        font-size: 16px;
        line-height: 1.4;
        color: rgba(116, 100, 188, 1);
        margin-bottom: 20px;
      }

      .qr-code {
        width: 250px;
        height: 250px;
        margin: 20px auto;
        display: block;
      }

      .description {
        margin-top: 10px;
        font-size: 14px;
        text-align: center;
        color: rgba(116, 100, 188, 1);
      }

      .divider {
        border-top: 1px solid rgba(116, 100, 188, 1);
        margin: 15px 0;
      }

      .person_Details {
        color: rgba(116, 100, 188, 1);
      }

      #event-details {
        width: 95%;
      }
    </style>
  </head>
  <body>
    <div class="card-container">
      <!-- First Card with QR Code -->
      <div class="card">
        <span id="event-name" class="card__title">${eventDetails['name']}</span>
        <div class="divider"></div>
        <span id="event-pass" class="card__title-2">Event pass</span>
        <div id="event-details" class="card__content">
          <p>Date: <span id="event-date">${eventDetails['date']}</span></p>
          <p>Time: <span id="event-time">${eventDetails['time']}</span></p>
          <p>Description: <span id="event-description">${eventDetails['description']}</span></p>
        </div>

        <div class="divider"></div>

        <div class="description">Scan This QR 👇</div>

        <img
          id="qr-code"
          src="https://quickchart.io/qr?text=$data&size=150"
          alt="QR Code"
          class="qr-code"
        />
      </div>
    </div>
  </body>
</html>'''
        ..attachments.add(FileAttachment(File(pdfPath)));

      // Attempt to send the email
      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' + sendReport.toString());

        stopwatch.stop();
        print('Time taken to send email: ${stopwatch.elapsedMilliseconds} ms');

        isGenerated = true; // Set isGenerated to true if email is sent successfully

        await deletePdf(pdfPath);
      } catch (e) {
        stopwatch.stop();
        print('Message not sent. Time taken to send email: ${stopwatch.elapsedMilliseconds} ms');
        print('Error: $e');
      }
    } catch (e) {
      print('Error generating PDF or sending email: $e');
      if(count == 3)
        {
          isGenerated = false;
        } else{
        mailGenerate(background_image, mail, data, eventDetails, count+1,backgroundImageResponse);
      }
    }

    return isGenerated; // Return whether the email was generated successfully
  }

  Future<void> deletePdf(String filePath) async {
    final file = File(filePath);
    try {
      if (await file.exists()) {
        await file.delete();
        print('File deleted: $filePath');
      } else {
        print('File not found: $filePath');
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

}
