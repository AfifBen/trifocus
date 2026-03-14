import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'app/bootstrap.dart';
import 'features/notifications/fcm_service.dart';
import 'features/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable immersive / edge-to-edge layouts that can cause content to render
  // under system bars on some devices.
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );

  await Firebase.initializeApp();
  await FcmService.init();
  await NotificationService.init();
  runApp(AppBootstrap.buildApp());
}
