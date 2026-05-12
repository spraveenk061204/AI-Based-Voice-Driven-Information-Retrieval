import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ REQUIRED

  await Permission.audio.request(); // ✅ safe now

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}