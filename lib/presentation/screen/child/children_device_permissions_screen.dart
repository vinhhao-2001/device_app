import 'package:flutter/material.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/permissions.dart';
import 'children_screen.dart';

class ChildPermissionsScreen extends StatefulWidget {
  const ChildPermissionsScreen({super.key});

  @override
  State<ChildPermissionsScreen> createState() => _ChildPermissionsScreenState();
}

class _ChildPermissionsScreenState extends State<ChildPermissionsScreen> {
  int currentIndex = 0;
  final Permissions permissionsHandler = Permissions();
  final permissions = AppText().permissions;
  final buttonLabels = AppText().buttonLabels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Thiết lập quyền thiết bị của trẻ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < permissions.length; i++) buildSection(i),
                if (currentIndex == permissions.length)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const ChildrenScreen(),
                            ),
                          );
                        },
                        child: const Text('Đã hoàn tất thiết lập'),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Xử lý khi thiết lập quyền sau
                          // Navigator.of(context).pushReplacement(
                          //   MaterialPageRoute(
                          //     builder: (_) => const ChildrenScreen(),
                          //   ),
                          // );
                        },
                        child: const Text('Thiết lập sau'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSection(int index) {
    return Opacity(
      opacity: currentIndex == index ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      permissions[index]['icon'],
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        permissions[index]['label'],
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (currentIndex == index)
                  ElevatedButton(
                    onPressed: () async {
                      bool granted = false;

                      // Yêu cầu quyền tương ứng
                      switch (index) {
                        case 0:
                          granted =
                              await permissionsHandler.notificationPermission();
                          break;
                        case 1:
                          granted =
                              await permissionsHandler.overlayPermission();
                          break;
                        case 2:
                          granted =
                              await permissionsHandler.usageStatsPermission();
                          break;
                        case 3:
                          granted = await permissionsHandler.adminPermission();
                          break;
                        case 4:
                          granted = await permissionsHandler
                              .accessibilityPermission();
                          break;
                        case 5:
                          granted =
                              await permissionsHandler.locationPermission();
                          break;
                      }
                      if (granted) {
                        setState(() {
                          currentIndex++;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: Text(buttonLabels[index]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
