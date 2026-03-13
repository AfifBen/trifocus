import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'app/bootstrap.dart';
import 'features/notifications/fcm_service.dart';
import 'features/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FcmService.init();
  await NotificationService.init();
  runApp(AppBootstrap.buildApp());
}
