import 'package:flutter/material.dart';

class AppText {
  // Danh sách xin quyền
  final List<Map<String, dynamic>> permissions = [
    {
      'label': 'Cho phép gửi thông báo đến trẻ.',
      'icon': Icons.notifications,
    },
    {
      'label': 'Cho phép hiển thị trên ứng dụng khác.',
      'icon': Icons.window_outlined,
    },
    {
      'label':
          'Cho phép truy cập thời gian sử dụng: Lấy thời gian sử dụng của các ứng dụng.',
      'icon': Icons.access_time_outlined,
    },
    {
      'label': 'Quyền quản trị viên: Cấp quyền để cài đặt thiết bị của trẻ.',
      'icon': Icons.admin_panel_settings_outlined,
    },
    {
      'label': 'Cho phép sử dụng dịch vụ trợ năng.',
      'icon': Icons.accessibility,
    },
    {
      'label':
          'Quyền truy cập vị trí: Cho phép ứng dụng biết vị trí hiện tại của bạn.',
      'icon': Icons.location_on_outlined,
    },
  ];
  // Các button xin quyền
  final List<String> buttonLabels = [
    'Cấp quyền thông báo',
    'Cấp quyền hiển thị trên ứng dụng khác',
    'Cấp quyền lấy thời gian sử dụng',
    'Cấp quyền quản trị viên',
    'Cấp quyền dịch vụ trợ năng',
    'Cấp quyền vị trí',
  ];

  // button
  static const String update = 'Cập nhật';

  static const String childAppUsageAppBar = 'Quản lý thời gian sử dụng của trẻ';
  static const String other = 'Khác';

  // vị trí
  static const String loadingAddress = 'Loading address...';
  static const String safeZone = 'Vùng an toàn';
}
