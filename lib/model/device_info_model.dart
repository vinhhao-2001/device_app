class DeviceInfoModel {
  String deviceName;
  String batteryLevel;
  String screenBrightness;
  String volume;

  DeviceInfoModel({
    required this.deviceName,
    required this.batteryLevel,
    required this.screenBrightness,
    required this.volume,
  });

  Map<String, dynamic> toMap() {
    return {
      'deviceName': deviceName,
      'batteryLevel': batteryLevel,
      'screenBrightness': screenBrightness,
      'volume': volume,
    };
  }

  factory DeviceInfoModel.fromMap(Map<String, dynamic> map) {
    return DeviceInfoModel(
      deviceName: map['deviceName'] ?? '',
      batteryLevel: map['batteryLevel'] ?? '',
      screenBrightness: map['screenBrightness'] ?? '',
      volume: map['volume'] ?? '',
    );
  }
}
