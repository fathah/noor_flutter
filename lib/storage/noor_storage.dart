import 'package:hive_flutter/hive_flutter.dart';
import '../core/configs.dart';

class NoorStorage {
  static final NoorStorage _instance = NoorStorage._internal();
  factory NoorStorage() => _instance;
  NoorStorage._internal();

  late Box _metaBox;
  late Box _prayerTimesBox;

  Future<void> init({String? testPath}) async {
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }
    _metaBox = await Hive.openBox(NoorConfig.metaBoxName);
    _prayerTimesBox = await Hive.openBox(NoorConfig.prayerTimesBoxName);
  }

  // --- Meta Box Accessors ---
  Box get meta => _metaBox;

  // --- Prayer Times Box Accessors ---
  Box get prayerTimes => _prayerTimesBox;

  /// Clear prayer times DB.
  Future<void> clearPrayerTimes() async {
    await _prayerTimesBox.clear();
  }

  /// Close all boxes.
  Future<void> close() async {
    await _metaBox.close();
    await _prayerTimesBox.close();
  }
}
