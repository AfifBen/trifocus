import 'package:flutter/widgets.dart';
import 'app/bootstrap.dart';
import 'features/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(AppBootstrap.buildApp());
}
