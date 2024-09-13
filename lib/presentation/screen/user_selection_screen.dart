import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/local/native/native_communicator.dart';
import 'child/children_screen.dart';
import 'parent/parent_screen.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ai là người sử dụng thiết bị này?',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ParentScreen(),
                    ));
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setInt('user', 1);
              },
              child: const Text('Phụ huynh'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (Platform.isIOS) await NativeCommunicator().initChannel();
                if (!context.mounted) return;
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const ChildrenScreen()));
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setInt('user', 2);
              },
              child: const Text('Trẻ'),
            ),
          ],
        ),
      ),
    );
  }
}
