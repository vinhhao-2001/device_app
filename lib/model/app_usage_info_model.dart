import 'dart:convert';
import 'dart:typed_data';

class AppUsageInfoModel {
  final String name;
  final String packageName;
  final String icon;
  final int usageTime;

  AppUsageInfoModel({
    required this.name,
    required this.packageName,
    required this.icon,
    required this.usageTime,
  });

  factory AppUsageInfoModel.fromJson(Map<String, dynamic> map) {
    String iconBase64 =
        base64Encode(Uint8List.fromList(map['icon'].cast<int>()));
    return AppUsageInfoModel(
      name: map['name'],
      packageName: map['packageName'],
      icon: iconBase64,
      usageTime: map['usageTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'packageName': packageName,
      'icon': icon,
      'usageTime': usageTime,
    };
  }

  factory AppUsageInfoModel.fromMap(Map<String, dynamic> map) {
    return AppUsageInfoModel(
      name: map['name'],
      packageName: map['packageName'],
      icon: map['icon'],
      usageTime: map['usageTime'] ?? 0,
    );
  }
}
