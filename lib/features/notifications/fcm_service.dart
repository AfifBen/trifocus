import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // iOS will prompt; Android 13+ also needs runtime permission.
    await _messaging.requestPermission();
  }

  static Future<String?> getToken() async {
    return _messaging.getToken();
  }
}
