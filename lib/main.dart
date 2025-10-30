import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/dependency_injection/injection_container.dart' as di;
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up things before the app starts
  await di.init();

  // Make status bar blend with the app
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const WeatherApp());
}
