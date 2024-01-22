/*import 'package:detic_app2/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  // Create an instance of Firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Function to init notifications
  Future<void> initNotifications() async {
    // Request permission from user (will prompt user)
    await _firebaseMessaging.requestPermission();

    // Fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();

    // Print the token (normally you would send this to your server)
    print('Token: $fCMToken');

    // Initialise further setting for push notif
    initNotifications();
  }

  // Function to handle received messages
  void handleMessage(RemoteMessage? message) {
    // if the message is null, do nothing
    if (message == null) return;

    // Navigate to new screen
    navigatorKey.currentState?.pushNamed(
      '',
      arguments: message,
    );
  }

  // Function to initialise background settings
  Future initPushNotifications() async {
    // Handle notification if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // Attach event listeners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
*/