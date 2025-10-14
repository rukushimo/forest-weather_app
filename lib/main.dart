import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/dependency_injection/injection_container.dart' as di;
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 Starting app...');

  // Initialize dependency injection
  await di.init();

  debugPrint('✅ DI complete, starting app!');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const WeatherApp());
}
