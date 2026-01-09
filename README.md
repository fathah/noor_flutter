# Noor Flutter Package

`noor` is a standard, offline-first, region-aware Islamic data engine for Flutter. It is designed to be the authoritative source for prayer times, ensuring correctness across different regions and madhabs while maintaining offline capabilities.

## Features

*   **Authoritative & Region-Aware**: Prioritizes local region rules over pure mathematical calculation.
*   **Offline-First**: Local database is the Source of Truth.
*   **Smart Sync**: Fetches only what's needed (current + next month) and caches it.
*   **Offline Fallback**: Automatically calculates prayer times if the API is unreachable.
*   **Deterministic**: Same input always results in the same output.
*   **Hive Storage**: Efficient, fast, and persistent local storage.

## Getting Started

Add dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  noor:
    path: ./ # Or git/pub version
  hive_flutter: ^1.1.0
```

## Usage

### 1. Initialization

Initialize the SDK before using it, ideally in your `main()` function.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Noor.initialize();
  runApp(MyApp());
}
```

### 2. Set Location

Configure the location to get accurate times. Changing location automatically wipes old data to ensure correctness.

```dart
// Set high-level location IDs (preferred for accuracy)
await Noor.setCountryId(1);
await Noor.setRegionId(101);

// AND/OR Set Coordinates (required for offline calculation fallback)
await Noor.setCoordinates(lat: 25.2048, lng: 55.2708);
```

### 3. Sync Data

Trigger a sync to fetch data from the API or calculate it locally.

```dart
await Noor.prayer.sync();
```

### 4. Read Prayer Times

Access the stored prayer times synchronously.

```dart
final today = Noor.prayer.today();

if (today != null) {
  print("Fajr: ${today.fajr}");      // 24h format: "05:12"
  print("Fajr: ${today.fajr12h}");   // 12h format: "5:12 AM"
  print("Isha: ${today.isha12h}");   // 12h format: "7:25 PM"
}

final nextDay = Noor.prayer.next(); // Tomorrow's times
```

## Architecture

*   **Source of Truth**: `Hive` (Local DB).
*   **API**: Used only to populate the DB.
*   **Calculation**: Used only as a fallback when API is unavailable.
