import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChildLocationModel {
  final LatLng position;
  final DateTime timestamp;

  ChildLocationModel({
    required this.position,
    required this.timestamp,
  });

  factory ChildLocationModel.fromMap(Map<dynamic, dynamic> map) {
    return ChildLocationModel(
      position: LatLng(map['latitude'], map['longitude']),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
