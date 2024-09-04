import 'package:flutter/material.dart';

import 'child/children_screen.dart';
import 'parent/parent_screen.dart';
import 'user_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  final int initialUser;

  const SplashScreen({super.key, required this.initialUser});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!(context).mounted) return;
      if (widget.initialUser == 0) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const UserSelectionScreen()));
      } else if (widget.initialUser == 1) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ParentScreen()));
      } else if (widget.initialUser == 2) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const ChildrenScreen(userType: 'Trẻ')));
      }
    });

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
