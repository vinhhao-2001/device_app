import 'dart:io';

import 'package:device_app/core/utils/background_service.dart';
import 'package:device_app/core/widget/lifecycle_observer.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends LifecycleObserver<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        try {
          didPop = await confirmExit(context, 'nameScreen');
          if (didPop) {
            if (!(context).mounted) return;
            Navigator.of(context).pop();
          }
        } catch (e) {
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Test Screen'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('hello world!'),
              TextButton(
                onPressed: () async {
                  await didRequestAppExit();
                  exit(0);
                },
                child: const Text('Thoát'),
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () async {
                  initializeService();
                },
                child: const Text('a'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onStart() {
    checkError();
    print('Bắt đầu giao diện');
  }

  @override
  void onEnd() async {
    print('ứng dụng bị đóng');
  }
}
