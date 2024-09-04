import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await FirebaseAppCheck.instance
  //     .activate(androidProvider: AndroidProvider.playIntegrity,
  // appleProvider: AppleProvider.debug);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final int user = prefs.getInt('user') ?? 0;

  runApp(MaterialApp(
    home: SplashScreen(initialUser: user),
  ));
}
