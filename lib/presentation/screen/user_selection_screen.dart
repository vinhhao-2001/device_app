import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/native/native_communicator.dart';
import 'child/children_screen.dart';
import 'parent/parent_screen.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

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
                Navigator.push(
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
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setInt('user', 2);
                if (!context.mounted) return;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChildrenScreen(userType: 'Trẻ')));
              },
              child: const Text('Trẻ'),
            ),
          ],
        ),
      ),
    );
  }
}
