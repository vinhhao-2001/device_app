import 'package:intl/intl.dart';

class Utils {
  String sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[.#$[\]]'), '_');
  }

  String formatTime(String time) {
    DateTime dateTime = DateTime.parse(time);
    return DateFormat('HH:mm, dd/MM/yyyy').format(dateTime);
  }

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
}
