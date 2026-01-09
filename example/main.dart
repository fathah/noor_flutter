import 'package:flutter/material.dart';
import 'package:noor/noor.dart';
import 'package:noor/utils/extensions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize SDK
  await Noor.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PrayerTimeModel? _today;
  String _status = "Idle";

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _today = Noor.prayer.today());
  }

  Future<void> _setupAndSync() async {
    setState(() => _status = "Setting Location...");

    // 2. Set Location (Dubai Example)
    await Noor.setCoordinates(lat: 25.2048, lng: 55.2708);
    // await Noor.setCountryId(1); // Optional: Set IDs if you have them

    setState(() => _status = "Syncing...");

    // 3. Sync Data
    await Noor.prayer.sync(force: true); // Force for demo purposes

    setState(() => _status = "Done");
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Noor SDK Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Status: $_status"),
              const SizedBox(height: 20),
              if (_today != null) ...[
                Text("Date: ${_today!.day}/${_today!.month}"),
                const Divider(),
                _Row("Fajr", _today!.fajr12h),
                _Row("Sunrise", _today!.sunrise12h),
                _Row("Dhuhr", _today!.dhuhr12h),
                _Row("Asr", _today!.asr12h),
                _Row("Maghrib", _today!.maghrib12h),
                _Row("Isha", _today!.isha12h),
              ] else
                const Text("No Data. Click Sync."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _setupAndSync,
                child: const Text("Set Location & Sync"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String time;
  const _Row(this.label, this.time);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(time),
        ],
      ),
    );
  }
}
