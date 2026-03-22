import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ✅ I-pre-warm ang translator sa background habang nag-lo-load ang app
  // Hindi naghihintay — tuloy ang app, nagda-download sa background
  ApiService().preWarm();

  runApp(const TagaLookApp());
}

class TagaLookApp extends StatelessWidget {
  const TagaLookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TagaLook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB32A)),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}