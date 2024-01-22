//import 'dart:io';
//import 'package:detic_app2/api/firebase_api.dart';
//import 'package:detic_app2/firebase_options.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:flutter/services.dart' show rootBundle;

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:detic_app2/api/local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:restart_app/restart_app.dart';

final navigatorKey = GlobalKey<NavigatorState>();
const serverIP = "192.168.99.104"; //serverIP = "34.125.172.217";
//var jsonFile = "/detic-runs/esp32-cam.json";
//var imageFile = "/detic-runs/esp32-cam.jpg";
//var latestFileName = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await FirebaseApi().initNotifications();

  runApp(
    MaterialApp(
      title: 'Reading and Writing Files',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromARGB(
                255, 90, 166, 252)), //Color.fromARGB(255, 255, 72, 0)),
        // You can set the theme of listTile from here but it cannot relate to the app theme
        //listTileTheme: ListTileThemeData(
        //  tileColor: const Color.fromARGB(255, 255, 228, 228),
        //  textColor: Colors.white,
        //  iconColor: Colors.white,
        //),
      ),
      home: DeticApp(storage: FileStorage()),
    ),
  );
}

class FileStorage {
  Future<String> readPHP() async {
    try {
      // Await phpScript response
      var phpScriptUrl = "http://$serverIP/php-scripts/latestfile.php";
      var phpScriptResponse = await http.get(Uri.parse(phpScriptUrl));
      dynamic latestFileName;

      if (phpScriptResponse.statusCode == 200) {
        var phpResponseData = convert.jsonDecode(phpScriptResponse.body);
        latestFileName = phpResponseData['latestFile'];
        print('Latest file name: $latestFileName');
      } else {
        print(
            'Failed to load data. Status code: ${phpScriptResponse.statusCode}');
      }

      return latestFileName;
    } catch (e) {
      print('Error: $e');
      return "";
    }
  }

  Future<Map> readFile() async {
    try {
      String latestFileName = await readPHP();
      print(latestFileName);
      var jsonFile = "/detic-runs/$latestFileName.json";
      print(jsonFile);
      //imageFile = "/detic-runs/$latestFileName.jpg";

      // Read the file
      var urlLocal = Uri.http(serverIP, jsonFile);

      // Await the http get response, then decode the json-formatted response.
      var response = await http.get(urlLocal);

      print(response.statusCode);

      Map<dynamic, dynamic> jsonResponse = {};

      var itemCount, uniqueObjects = 0;
      if (response.statusCode == 200) {
        jsonResponse = convert.jsonDecode(response.body);
        //itemCount = jsonResponse['totalItems'];
        uniqueObjects = jsonResponse['uniqueObjects'];
        itemCount = uniqueObjects;
        Map<String, dynamic> objects = jsonResponse['objects'];

        print(jsonResponse);
        print('Item count in the detected picture: $itemCount.');
        print('Unique objects in the detected picture: $uniqueObjects.');
        print('Objects:');
        objects.forEach((key, value) {
          print('$key: $value');
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }

      var contents = itemCount;
      print(contents);

      return jsonResponse;
    } catch (e) {
      // If encountering an error, return 0
      return {0: 0};
    }
  }
}

DateTime scheduleTime = DateTime.now();

class DeticApp extends StatefulWidget {
  const DeticApp({super.key, required this.storage});

  final FileStorage storage;

  @override
  State<DeticApp> createState() => DeticAppState();
}

class DeticAppState extends State<DeticApp> {
  var data = {};
  Map<String, dynamic> objects = {};
  int itemCount = 0;
  int uniqueObjects = 0;
  var latestFileName = "";
  var imageFile = "";

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();

    widget.storage.readFile().then((str) {
      setState(() {
        data = str;
        objects = data['objects'];
        itemCount = data['totalItems'];
        uniqueObjects = data['uniqueObjects'];
      });
    });

    widget.storage.readPHP().then((filename) {
      setState(() {
        latestFileName = filename;
        imageFile = "/detic-runs/$latestFileName.jpg";
        print(imageFile);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Detected Objects'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                  child: InteractiveViewer(
                    panEnabled: true, // Set it to false
                    boundaryMargin: EdgeInsets.all(100),
                    minScale: 1,
                    maxScale: 2,
                    alignment: Alignment.center,
                    child: Image.network(
                      'http://$serverIP$imageFile',
                      fit: BoxFit.contain, // Adjust the width as needed
                      width: 300,
                      height: 300,
                    ),
                  ),
                ),
                SizedBox(height: 10), // Add spacing between image and text
                Text(
                  'Detected $itemCount objects:\n',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: uniqueObjects,
                  itemBuilder: (context, index) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      tileColor: theme.colorScheme.primary,
                      textColor: theme.colorScheme.onPrimary,
                      iconColor: theme.colorScheme.onPrimary,
                      leading: const Icon(Icons.restaurant),
                      title: Text(data["objects"].keys.toList()[
                          index]), //Text(data.values.toList()[1][index]),
                      trailing: Text(
                          data["objects"].values.toList()[index].toString()),
                    );
                    //child: Text(data.values.toList()[1][index]));
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            NotificationService().scheduleNotification(
                title: 'Detected',
                body: '$itemCount objects!',
                scheduledNotificationDateTime: scheduleTime);
            print('Button pressed!');
            Restart.restartApp();
            //NotificationService().showNotification(
            //  title:
            //      'Attention: Your ${objects[0]} are plotting a sticky revolution',
            //  body:
            //      'Either make ${objects[0]} bread or face the consequences of mushy anarchy!',
            //);
          },
          tooltip: 'Send notification',
          child: const Icon(Icons.rocket),
        ),
      ),
    );
  }
}
