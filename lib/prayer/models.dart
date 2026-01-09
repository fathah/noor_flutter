class PrayerTimeModel {
  final int day;
  final int month;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimeModel({
    required this.day,
    required this.month,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimeModel.fromJson(Map<dynamic, dynamic> json) {
    return PrayerTimeModel(
      day: json['day'] ?? 0,
      month: json['month'] ?? 0,
      fajr: json['fajr'] ?? '00:00',
      sunrise: json['sunrise'] ?? '00:00',
      dhuhr: json['dhuhr'] ?? '00:00',
      asr: json['asr'] ?? '00:00',
      maghrib: json['maghrib'] ?? '00:00',
      isha: json['isha'] ?? '00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'month': month,
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }
}
