import 'package:intl/intl.dart';

class NoorDateUtils {
  static String formatTime24(DateTime dt) {
    return DateFormat('HH:mm').format(dt);
  }

  static DateTime timeToDateTime(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    if (parts.length != 2) return now;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return DateTime(now.year, now.month, now.day, h, m);
  }
}
