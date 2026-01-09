library noor;

import 'storage/noor_storage.dart';
import 'prayer/prayer_service.dart';
import 'location/location_service.dart';

export 'prayer/models.dart';
export 'location/models.dart';

class Noor {
  static final LocationService _location = LocationService();
  static final PrayerService _prayer = PrayerService();

  /// Initialize the Noor SDK.
  /// Must be called before accessing other methods.
  static Future<void> initialize({String? testPath}) async {
    await NoorStorage().init(testPath: testPath);
  }

  /// Access Prayer related functions
  static PrayerService get prayer => _prayer;

  // --- Location Setters ---

  static List<dynamic> getCountries() => _location.getCountries();

  static Future<void> setCountryId(int id) => _location.setCountryId(id);
  static Future<void> setStateId(int id) => _location.setStateId(id);
  static Future<void> setDistrictId(int id) => _location.setDistrictId(id);
  static Future<void> setRegionId(int id) => _location.setRegionId(id);

  static Future<void> setCoordinates({
    required double lat,
    required double lng,
  }) => _location.setCoordinates(lat, lng);
}
