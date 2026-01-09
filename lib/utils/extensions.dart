import '../prayer/models.dart';
import 'date_utils.dart';
import 'package:intl/intl.dart';

extension PrayerTimeExtensions on PrayerTimeModel {
  String get fajr12h => _to12h(fajr);
  String get sunrise12h => _to12h(sunrise);
  String get dhuhr12h => _to12h(dhuhr);
  String get asr12h => _to12h(asr);
  String get maghrib12h => _to12h(maghrib);
  String get isha12h => _to12h(isha);

  String _to12h(String time24) {
    try {
      final dt = NoorDateUtils.timeToDateTime(time24);
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return time24;
    }
  }
}
