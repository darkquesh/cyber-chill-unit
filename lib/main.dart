import 'dart:async';
//import 'dart:io';
import 'dart:convert' as convert;

//import 'package:detic_app2/api/firebase_api.dart';
//import 'package:detic_app2/firebase_options.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:detic_app2/api/local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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
      home: FlutterDemo(storage: FileStorage()),
    ),
  );
}

class FileStorage {
  Future<String> get localFile async {
    return await rootBundle.loadString('assets/run_log.txt');
  }

  Future<int> readFile() async {
    try {
      final file = await localFile;

      print(file);
      //var url = Uri.https('https://example.com/foobar.txt');
      //var response = await http.get(url);

      //var url = Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});

      var urlLocal = Uri.https(
          'raw.githubusercontent.com', '/darkquesh/s-f/main/volumes.json');

      // Await the http get response, then decode the json-formatted response.
      var response = await http.get(urlLocal);
      //final response = await http.get(url);

      print(response.statusCode);

      var itemCount = 0;
      if (response.statusCode == 200) {
        var jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        itemCount = jsonResponse['totalItems'];
        print('Number of books about http: $itemCount.');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }

      //print(await http.read(Uri.https('example.com', 'foobar.txt')));

      // Read the file
      var contents = itemCount;
      print(contents);

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }
  /*
  Future<File> writeFile(int counter) async {
    final file = await localFile;

    // Write the file
    return file.writeAsString('$counter');
  }*/
}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({super.key, required this.storage});

  final FileStorage storage;

  @override
  State<FlutterDemo> createState() => FlutterDemoState();
}

class FlutterDemoState extends State<FlutterDemo> {
  int counter = 0;
  int data = 1;

  @override
  void initState() {
    super.initState();

    widget.storage.readFile().then((str) {
      setState(() {
        data = str;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detected Objects'),
      ),
      body: Center(
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
                fit: BoxFit.scaleDown, // Adjust the width as needed
                width: 300,
                height: 300,
              ),
            ),
            SizedBox(height: 16), // Add spacing between image and text
            Text(
              'Objects:\n'
              '$data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        //   child: Text('Objects:\n'
        //       '$data'
        //       //'Button tapped $counter time${counter == 1 ? '' : 's'}.',
        //       ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NotificationService().showNotification(
            title: 'Attention: Your bananas are plotting a sticky revolution',
            body:
                'Either make banana bread or face the consequences of mushy anarchy!',
          );
          print('Button pressed!');
        },
        //onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.abc),
      ),
    );
  }
}
