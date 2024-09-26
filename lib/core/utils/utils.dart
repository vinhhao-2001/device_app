import 'package:device_app/data/api/local/db_helper/database_helper.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'local_notification.dart';

class Utils {
  // gửi packageName lên firebase
  String sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[.#$[\]]'), '_');
  }

  // Định dạng lịch sử cài ứng dụng
  String formatTime(String time) {
    DateTime dateTime = DateTime.parse(time);
    return DateFormat('HH:mm, dd/MM/yyyy').format(dateTime);
  }

  // Định dạng thời gian sử dụng
  String formatUsageTime(int millis) {
    Duration duration = Duration(milliseconds: millis);
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    List<String> parts = [];

    if (hours > 0) {
      parts.add("$hours giờ");
    }
    if (minutes > 0) {
      parts.add("$minutes phút");
    }
    parts.add("$seconds giây");

    return parts.join(" ");
  }

  // Định dạng địa chỉ
  String formatAddress(Placemark placeMark) {
    return "Vị trí của trẻ: ${placeMark.street ?? ''}, ${placeMark.locality ?? ''}, "
            "${placeMark.subAdministrativeArea ?? ''}, ${placeMark.administrativeArea ?? ''}, "
            "${placeMark.country ?? ''}"
        .replaceAll(RegExp(', +'), ', ')
        .trim();
  }

  // Vẽ phạm vi an toàn của trẻ
  List<LatLng> getConvexHull(List<LatLng> points) {
    points.sort((a, b) {
      if (a.latitude == b.latitude) return a.longitude.compareTo(b.longitude);
      return a.latitude.compareTo(b.latitude);
    });

    List<LatLng> hull = [];

    for (var p in points) {
      while (
          hull.length > 1 && _cross(hull[hull.length - 2], hull.last, p) <= 0) {
        hull.removeLast();
      }
      hull.add(p);
    }

    int t = hull.length + 1;
    for (var i = points.length - 2; i >= 0; i--) {
      LatLng p = points[i];
      while (hull.length >= t &&
          _cross(hull[hull.length - 2], hull.last, p) <= 0) {
        hull.removeLast();
      }
      hull.add(p);
    }

    hull.removeLast();
    return hull;
  }

  double _cross(LatLng o, LatLng a, LatLng b) {
    return (a.longitude - o.longitude) * (b.latitude - o.latitude) -
        (a.latitude - o.latitude) * (b.longitude - o.longitude);
  }

  // kiểm tra trẻ có ở trong phạm vi an toàn không
  Future<void> checkChildLocation(LatLng childLocation) async {
    final polygonPoints = await DatabaseHelper().getSafeZone();
    if (polygonPoints.length < 3) return;
    int intersections = 0;
    for (int i = 0; i < polygonPoints.length; i++) {
      LatLng p1 = polygonPoints[i],
          p2 = polygonPoints[(i + 1) % polygonPoints.length];
      if (((p1.latitude <= childLocation.latitude &&
                  childLocation.latitude < p2.latitude) ||
              (p2.latitude <= childLocation.latitude &&
                  childLocation.latitude < p1.latitude)) &&
          (childLocation.longitude <
              (p2.longitude - p1.longitude) *
                      (childLocation.latitude - p1.latitude) /
                      (p2.latitude - p1.latitude) +
                  p1.longitude)) {
        intersections++;
      }
    }

    if (intersections.isOdd) {
    } else {
      LocalNotification().outsideSafeZoneNotification();
    }
  }
}
