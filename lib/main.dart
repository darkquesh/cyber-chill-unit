//import 'dart:io';
//import 'package:detic_app2/api/firebase_api.dart';
//import 'package:detic_app2/firebase_options.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:flutter/services.dart' show rootBundle;

import 'dart:async';
import 'dart:convert' as convert;
import 'package:detic_app2/api/local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:path_provider/path_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await FirebaseApi().initNotifications();
  NotificationService().initNotification();

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
      home: FlutterDemo(storage: FileStorage()),
    ),
  );
}

class FileStorage {
  Future<Map> readFile() async {
    try {
      // Read the file
      var urlLocal = Uri.http('https://raw.githubusercontent.com',
          '/darkquesh/s-f/main/run_log.json');

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
      // If encountering an error, return 0
      return {0: 0};
    }
  }
}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({super.key, required this.storage});

  final FileStorage storage;

  @override
  State<FlutterDemo> createState() => FlutterDemoState();
}

class FlutterDemoState extends State<FlutterDemo> {
  int counter = 0;
  //int data = 1;
  var data = {};
  List objects = [];
  int itemCount = 0;

  @override
  void initState() {
    super.initState();

    widget.storage.readFile().then((str) {
      setState(() {
        data = str;
        objects = data['objects'];
        itemCount = data['totalItems'];
        //counter = value;
      });
    });
  }

  void _incrementCounter() {
    setState(() {
      counter++;
    });
    //print(counter);
    // Write the variable as a string to the file.
    //return widget.storage.writeFile(counter);
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
                  child: Image.network(
                    'https://raw.githubusercontent.com/darkquesh/s-f/main/apple1.jpg',
                    fit: BoxFit.contain, // Adjust the width as needed
                    width: 200,
                    height: 200,
                  ),
                ),
                SizedBox(height: 16), // Add spacing between image and text
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
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      tileColor: theme.colorScheme.primary,
                      textColor: theme.colorScheme.onPrimary,
                      iconColor: theme.colorScheme.onPrimary,
                      leading: const Icon(Icons.restaurant),
                      title: Text(data.values.toList()[1][index]),
                      trailing: Text(""),
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
          //   child: Text('Objects:\n'
          //       '$data'
          //       //'Button tapped $counter time${counter == 1 ? '' : 's'}.',
          //       ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            NotificationService().showNotification(
              title:
                  'Attention: Your ${objects[0]} are plotting a sticky revolution',
              body:
                  'Either make ${objects[0]} bread or face the consequences of mushy anarchy!',
            );
            print('Button pressed!');
          },
          //onPressed: _incrementCounter,
          tooltip: 'Send notification',
          child: const Icon(Icons.rocket),
        ),
      ),
    );
  }
}
