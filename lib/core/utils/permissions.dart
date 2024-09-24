import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static const _permissionChannel =
      MethodChannel('request_permissions_channel');

  Future<bool> requestPermission(String method) async {
    try {
      final result = await _permissionChannel.invokeMethod(method);
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  // Xin quyền gửi thông báo
  Future<bool> notificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      var result = await Permission.notification.request();
      return result.isGranted;
    }
    return true;
  }

  // Xin quyền quản trị viên
  Future<bool> adminPermission() => requestPermission('adminPermission');

  // Xin quyền truy cập thời gian sử dụng
  Future<bool> usageStatsPermission() =>
      requestPermission('usageStatsPermission');

  // Xin quyền hiển thị trên ứng dụng khác
  Future<bool> overlayPermission() => requestPermission('overlayPermission');

  // xin quyền sử dụng trợ năng
  Future<bool> accessibilityPermission() =>
      requestPermission('accessibilityPermission');

  // Xin quyền truy cập vị trí
  // Future<bool> locationPermission() => requestPermission('locationPermission');

  Future<bool> locationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }
    return false;
  }

  Future<Position> determinePosition() async {
    LocationPermission permission;

    // Kiểm tra quyền
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    // Lấy vị trí hiện tại
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
