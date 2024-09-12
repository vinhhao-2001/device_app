import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'child/children_screen.dart';
import 'parent/parent_screen.dart';
import 'user_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // màn hình chờ
    Future.delayed(const Duration(seconds: 1), () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int user = prefs.getInt('user') ?? 0;
      _navigateScreen(user);
    });
  }
  // chuyển trang
  Future<void> _navigateScreen(int user) async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => user == 1
            ? const ParentScreen()
            : user == 2
                ? const ChildrenScreen()
                : const UserSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Device app \n Ứng dụng quản lý trẻ',
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
