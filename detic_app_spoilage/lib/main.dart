//import 'dart:io';
//import 'package:detic_app2/api/firebase_api.dart';
//import 'package:detic_app2/firebase_options.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:flutter/services.dart' show rootBundle;

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:detic_app_rot/api/local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:restart_app/restart_app.dart';

final navigatorKey = GlobalKey<NavigatorState>();
const serverIP = "192.168.99.104";  //serverIP = "34.125.172.217";
var jsonFile =
    "/detic-runs-rot/esp32-cam.json"; //"/detic-runs-rot/esp32-cam.json";
var imageFile =
    "/detic-runs-rot/esp32-cam-mask.jpg"; //"/detic-runs-rot/esp32-cam.jpg";

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
                255, 252, 122, 90)), //Color.fromARGB(255, 255, 72, 0)),
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
  Future<String> readFile() async {
    try {
      // Read the file
      var urlLocal = Uri.http(serverIP, jsonFile);

      // Await the http get response, then decode the json-formatted response.
      var response = await http.get(urlLocal);

      print(response.statusCode);

      dynamic jsonResponse;

      String spoilingRate = "0";
      if (response.statusCode == 200) {
        jsonResponse = convert.jsonDecode(response.body);
        spoilingRate = jsonResponse["spoiling_rate"];

        print(jsonResponse);
        print('Item count in the detected picture: $spoilingRate.');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }

      var contents = spoilingRate;
      print(contents);

      return spoilingRate;
    } catch (e) {
      // If encountering an error, return 0
      return "";
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
  var data = "";
  var spoilingRate = "0";

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();

    widget.storage.readFile().then((str) {
      setState(() {
        spoilingRate = str;
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
          title: const Text('Spoiled Fruits'),
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
                  'Detected 1 object:\n',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      tileColor: theme.colorScheme.primary,
                      textColor: theme.colorScheme.onPrimary,
                      iconColor: theme.colorScheme.onPrimary,
                      leading: Text("Peach"), //const Icon(Icons.restaurant),
                      title: Text(
                          "Spoilage Rate: "), //Text(data.values.toList()[1][index]),
                      trailing: Text("$spoilingRate%"),
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
                body: '1 object!',
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
