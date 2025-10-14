import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/dependency_injection/injection_container_mock.dart' as di;
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log('🧪 Running in MOCK mode - No API key required!');

  await di.initMock();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const WeatherApp());
}
