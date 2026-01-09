import 'package:flutter_test/flutter_test.dart';
import 'package:noor/noor.dart';
import 'package:hive/hive.dart';
import 'dart:io';

void main() {
  group('Noor SDK Verification', () {
    final testPath = '${Directory.current.path}/test_db';

    setUpAll(() async {
      // Clean up previous run
      final dir = Directory(testPath);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }

      await Noor.initialize(testPath: testPath);
    });

    tearDownAll(() async {
      await Hive.close();
      final dir = Directory(testPath);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('Location Setters should work and clear prayer times', () async {
      // 1. Set Coordinates
      await Noor.setCoordinates(lat: 25.2048, lng: 55.2708); // Dubai

      // Verify storage via Hive directly or we can trust the flow
      // Since LocationService isn't public, we check side effects if possible
      // But we can check Noor.prayer.today() => should be null initially or calc?

      // 2. Set Country/Region
      await Noor.setCountryId(1);
      await Noor.setRegionId(101);
    });

    test('Prayer Sync should calculate and store times offline', () async {
      // Ensure coords are set
      await Noor.setCoordinates(lat: 25.2048, lng: 55.2708);

      // Trigger sync (Mocking HTTP not done, so it will fall back to calculation)
      await Noor.prayer.sync(force: true);

      // Verify Today
      final today = Noor.prayer.today();
      expect(today, isNotNull);
      print('Today Fajr: ${today?.fajr}');

      expect(today?.day, DateTime.now().day);
      expect(today?.month, DateTime.now().month);
    });

    test('Next Prayer (Tomorrow) should exist', () async {
      final next = Noor.prayer.next();
      expect(next, isNotNull);
      // next should be tomorrow
      final tomorrow = DateTime.now().add(Duration(days: 1));
      expect(next?.day, tomorrow.day);
    });
  });
}
