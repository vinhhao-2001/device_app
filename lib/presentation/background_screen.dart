import 'dart:io';

import 'package:flutter/material.dart';

import '../core/widget/lifecycle_observer.dart';
import '../data/api/local/background_service/children_service.dart';

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
          didPop = await confirmExit(context, 'Background Screen');
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
          title: const Text('Khởi động chạy nền'),
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
                  await initializeService();
                },
                child: const Text('Bắt đầu chạy nền'),
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
