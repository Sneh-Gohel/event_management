import 'dart:convert'; // Required for jsonDecode
import 'package:http/http.dart' as http;

class FetchDataFromSheets {
  Future<dynamic> fetchData(String sheetId, int count, String searchFor) async {
    print("Fetching the data");

    // var uri = Uri.parse(
    //         "https://script.google.com/macros/s/AKfycbxSLQ2xRpiIYg5SeTvTQ0H_kpx0rKp4KJoMl7yp0xVQsxw7hrLg8WFRVOjxqU8R6W7v/exec")
    //     .replace(queryParameters: {
    //   "sheetId": "1rT9guaDOr1IEZNIk15xaORu68jbqfbbdhM9q3nlsdTc",
    //   // "count":"0",
    // });

    var uri;

    // Construct the URI with the sheetId and count as query parameters
    if (searchFor == "Regular") {
      uri = Uri.parse(
          "https://script.google.com/macros/s/AKfycbyDHaUUylwhiMRBEX_uR1u7EafEmmroKOBnoPyvJR7E9vTYQzbc5Po_jv9MDOMIn_t4/exec")
          .replace(queryParameters: {
        "sheetId": sheetId,
      });
    } else if (searchFor == "Alumni") {
      uri = Uri.parse(
          "https://script.google.com/macros/s/AKfycbyGLtkAxVJy1mbLO1H1kGnYodm0mF-T0jUuUZjG9eSEWlQRSMBDrp588k0BYzaXYNSlAA/exec")
          .replace(queryParameters: {
        "sheetId": sheetId,
      });
    } else if (searchFor == "Faculty") {
      uri = Uri.parse(
          "https://script.google.com/macros/s/AKfycbwwI8v3AouzKiPpS9qQDt23Ay5YVSqRFgADn2rTSqqwvkPbkInArFs88Hlgl01ZHhwL/exec")
          .replace(queryParameters: {
        "sheetId": sheetId,
      });
    } else if (searchFor == "Guest") {
      uri = Uri.parse(
          "https://script.google.com/macros/s/AKfycbz46ptbb4XnoYZAmlhM1UmGcHJChEYHcD0Z53upZ-fHvCldc64CV9SVdVw71sT12Xk_/exec")
          .replace(queryParameters: {
        "sheetId": sheetId,
      });
    } else {
      uri = Uri.parse(
          "https://script.google.com/macros/s/AKfycbwOrfH6KDyFQSc0fZSOjIPV6OgzNp25DLye7ycNRoY2ABLrQHgN9SFnnGOkHazD5QHoYg/exec")
          .replace(queryParameters: {
        "sheetId": sheetId,
      });
    }

    // Sending the request
    try{
      var response = await http.get(
        uri,
        // headers: {
        // //   'Content-Type': 'application/json',
        // //   'Connection':'keep-alive'
        // },
      );
      if (response.statusCode == 200 || response.statusCode == 302) {
        // Convert the JSON response to a List of Maps
        print(response.body);
        List<dynamic> dataList = jsonDecode(response.body);
        // Directly store each entry as a Map<String, dynamic>
        List<Map<String, dynamic>> dataMapList = dataList.map((item) {
          return Map<String, dynamic>.from(
              item); // Automatically converts each item
        }).toList();

        // Return data starting from the specified count
        return dataMapList.skip(count).toList();
      } else {
        print("Error: ${response.statusCode}");
        return null; // Return null or handle the error as needed
      }
    } catch(e){
      print(e);
    }
  }
}
