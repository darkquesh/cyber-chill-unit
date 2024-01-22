import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

const serverIP = "51.20.72.77";
const jsonFile = "/uploads/json_files/run_log.json";

class FileStorage {
  var data = {};
  List objects = [];
  int itemCount = 0;

  Future<Map> readFile() async {
    print("Inside FileStorage!");
    try {
      // Read the file
      var urlLocal = Uri.http(serverIP, jsonFile);

      // Await the http get response, then decode the json-formatted response.
      var response = await http.get(urlLocal);

      print(response.statusCode);

      Map<dynamic, dynamic> jsonResponse = {};

      var itemCount = 0;
      if (response.statusCode == 200) {
        jsonResponse = convert.jsonDecode(response.body);
        itemCount = jsonResponse['totalItems'];

        print(jsonResponse);
        print('Item count in the detected picture: $itemCount.');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }

      var contents = itemCount;
      print(contents);

      return jsonResponse;
    } catch (e) {
      print("Error");
      // If encountering an error, return 0
      return {0: 0};
    }
  }

  void initState() {
    readFile().then((str) {
      data = str;
      objects = data['objects'];
      itemCount = data['totalItems'];

      //print(data);
      //print(objects);
      //print(itemCount);
    });
  }
}
