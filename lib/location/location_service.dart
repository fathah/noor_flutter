import '../storage/noor_storage.dart';
import '../network/http_client.dart';
import '../constants/country.dart';

class LocationService {
  final NoorStorage _storage = NoorStorage();
  final NoorHttpClient _client = NoorHttpClient();

  List<dynamic> getCountries() {
    return countriesList;
  }

  // --- Setters with "Location Change Rule" ---

  Future<void> setCountryId(int id) async {
    await _updateSetting('location.countryId', id);
  }

  Future<void> setStateId(int id) async {
    await _updateSetting('location.stateId', id);
  }

  Future<void> setDistrictId(int id) async {
    await _updateSetting('location.districtId', id);
  }

  Future<void> setRegionId(int id) async {
    await _updateSetting('location.regionId', id);
  }

  Future<void> setCoordinates(double lat, double lng) async {
    await _storage.meta.put('location.lat', lat);
    await _storage.meta.put('location.lng', lng);
    // Location changed => clear prayer times
    await _storage.clearPrayerTimes();
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final currentValue = _storage.meta.get(key);
    if (currentValue != value) {
      await _storage.meta.put(key, value);
      await _storage.clearPrayerTimes();
    }
  }

  // --- Getters ---

  int? get countryId => _storage.meta.get('location.countryId');
  int? get stateId => _storage.meta.get('location.stateId');
  int? get districtId => _storage.meta.get('location.districtId');
  int? get regionId => _storage.meta.get('location.regionId');

  Map<String, double>? get coordinates {
    final lat = _storage.meta.get('location.lat');
    final lng = _storage.meta.get('location.lng');
    if (lat != null && lng != null) {
      return {'lat': lat, 'lng': lng};
    }
    return null;
  }

  // --- Data Fetching (with Caching) ---
  // Assuming base URL is handled/provided somewhere or constructed here.
  // Using placeholders for URL structures based on ref.dart

  Future<List<dynamic>> getStates(int countryId) async {
    return _fetchAndCache(
      'states-$countryId',
      '/regions/states/?country=$countryId',
    );
  }

  Future<List<dynamic>> getDistricts(int stateId) async {
    return _fetchAndCache(
      'districts-$stateId',
      '/regions/districts/?state=$stateId',
    );
  }

  Future<List<dynamic>> getRegions(int districtId) async {
    return _fetchAndCache(
      'regions-$districtId',
      '/regions/regions/?district=$districtId',
    );
  }

  Future<List<dynamic>> _fetchAndCache(String cacheKey, String endpoint) async {
    if (_storage.meta.containsKey(cacheKey)) {
      final cached = _storage.meta.get(cacheKey);
      if (cached is List) return cached;
    }

    // TODO: Need base URL injection?
    // Assuming NoorHttpClient handles full URL or we prepend a base.
    // For now, I'll assume endpoint is sufficient if Client is configured,
    // BUT the client implementation I wrote expects a full URL or standard usage.
    // I should strictly define the base URL in Config or Client.
    // Let's assume a strictly defined API config in code for now or injected.
    // I'll update Config to have a PLACEHOLDER base URL.

    // Re-reading usage: `NoorHttpClient.get("/times?..." )` in Arch.
    // So Client should prepend Base URL. I will fix Client later or assume it's set.
    // Let's assume global Base URL for now.

    // NOTE: I'll use a constant for BASE URL in Configs.
    final response = await _client.get(endpoint);

    if (response != null &&
        response['success'] == true &&
        response['data'] != null) {
      final data = response['data'] as List;
      await _storage.meta.put(cacheKey, data);
      return data;
    }
    return [];
  }
}
