import 'package:adhan_dart/adhan_dart.dart';
import '../storage/noor_storage.dart';
import '../network/http_client.dart';
import '../location/location_service.dart';
import '../utils/date_utils.dart';
import 'models.dart';

class PrayerService {
  final NoorStorage _storage = NoorStorage();
  final NoorHttpClient _client = NoorHttpClient();
  final LocationService _locationService = LocationService();

  // --- Public API ---

  PrayerTimeModel? today() {
    final now = DateTime.now();
    return _getPrayerTime(now.day, now.month);
  }

  PrayerTimeModel? next() {
    final now = DateTime.now().add(const Duration(days: 1));
    return _getPrayerTime(now.day, now.month);
  }

  // --- Sync Logic ---

  Future<void> sync({bool force = false}) async {
    final countryId = _locationService.countryId;
    final regionId = _locationService.regionId;
    final coords = _locationService.coordinates;

    if (coords == null && countryId == null) {
      return;
    }

    final now = DateTime.now();
    final currentMonth = now.month;
    final nextMonthIs = currentMonth == 12 ? 1 : currentMonth + 1;

    final daysInCurrent = DateTime(now.year, currentMonth + 1, 0).day;
    final daysInNext = DateTime(now.year, nextMonthIs + 1, 0).day;

    final hasCurrentMonth = _storage.prayerTimes.containsKey(
      "${daysInCurrent}-$currentMonth",
    );
    final hasNextMonth = _storage.prayerTimes.containsKey(
      "${daysInNext}-$nextMonthIs",
    );

    if (!force && hasCurrentMonth && hasNextMonth) {
      return;
    }

    if (force || !hasCurrentMonth) {
      await _fetchOrCalculate(
        now.year,
        currentMonth,
        daysInCurrent,
        countryId,
        regionId,
        coords,
      );
    }

    if (force || !hasNextMonth) {
      await _fetchOrCalculate(
        now.year,
        nextMonthIs,
        daysInNext,
        countryId,
        regionId,
        coords,
      );
    }
  }

  Future<void> _fetchOrCalculate(
    int year,
    int month,
    int daysInMonth,
    int? countryId,
    int? regionId,
    Map<String, double>? coords,
  ) async {
    bool success = false;

    if (countryId != null && regionId != null) {
      final url = "times/?countryId=$countryId&regionId=$regionId&month=$month";
      final data = await _client.get(url);
      if (data != null && data['success'] == true && data['data'] != null) {
        final list = data['data'] as List;
        for (var item in list) {
          await _saveToDB(item);
        }
        success = true;
      }
    }

    if (!success && coords != null) {
      _calculateAndStore(
        year,
        month,
        daysInMonth,
        coords['lat']!,
        coords['lng']!,
      );
    }
  }

  void _calculateAndStore(
    int year,
    int month,
    int daysTotal,
    double lat,
    double lng,
  ) {
    final coordinates = Coordinates(lat, lng);
    final params = CalculationMethodParameters.muslimWorldLeague();
    params.madhab = Madhab.shafi;

    for (int i = 1; i <= daysTotal; i++) {
      final date = DateTime(year, month, i);
      // Corrected for named parameters
      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
        precision: true,
      );

      final model = PrayerTimeModel(
        day: i,
        month: month,
        fajr: NoorDateUtils.formatTime24(prayerTimes.fajr.toLocal()),
        sunrise: NoorDateUtils.formatTime24(prayerTimes.sunrise.toLocal()),
        dhuhr: NoorDateUtils.formatTime24(prayerTimes.dhuhr.toLocal()),
        asr: NoorDateUtils.formatTime24(prayerTimes.asr.toLocal()),
        maghrib: NoorDateUtils.formatTime24(prayerTimes.maghrib.toLocal()),
        isha: NoorDateUtils.formatTime24(prayerTimes.isha.toLocal()),
      );

      _saveToDB(model.toJson());
    }
  }

  Future<void> _saveToDB(Map<dynamic, dynamic> data) async {
    final day = data['day'];
    final month = data['month'];
    final key = "$day-$month";
    await _storage.prayerTimes.put(key, data);
  }

  PrayerTimeModel? _getPrayerTime(int day, int month) {
    final key = "$day-$month";
    final data = _storage.prayerTimes.get(key);
    if (data != null) {
      return PrayerTimeModel.fromJson(Map<dynamic, dynamic>.from(data));
    }
    return null;
  }
}
