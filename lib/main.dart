import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keysprintx/splash_screen.dart';
import 'package:keysprintx/storage_service.dart';
import 'app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar, dark icons (light bg app)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await StorageService().init();

  runApp(const KeySprintXApp());
}

class KeySprintXApp extends StatelessWidget {
  const KeySprintXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KeySprintX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}