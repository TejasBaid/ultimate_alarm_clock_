import 'dart:async';

import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/worldClock/models/world_clock_city.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class WorldClockController extends GetxController {
  static const double travelMin = -12;
  static const double travelMax = 12;

  final RxList<WorldClockCity> cities = <WorldClockCity>[].obs;
  final RxDouble travelHours = 0.0.obs;
  final Rx<DateTime> tick = DateTime.now().obs;

  Timer? _timer;
  SettingsController get _settings => Get.find<SettingsController>();

  @override
  void onInit() {
    super.onInit();
    tzdata.initializeTimeZones();
    _seedCities();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      tick.value = DateTime.now();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _seedCities() {
    cities.assignAll(const [
      WorldClockCity(
        id: 'local',
        cityName: 'Local',
        subtitle: '',
        ianaName: null,
        isDeviceZone: true,
      ),
      WorldClockCity(
        id: 'phoenix',
        cityName: 'Phoenix',
        subtitle: 'AZ, United States',
        ianaName: 'America/Phoenix',
      ),
      WorldClockCity(
        id: 'nyc',
        cityName: 'New York',
        subtitle: 'NY, United States',
        ianaName: 'America/New_York',
      ),
      WorldClockCity(
        id: 'london',
        cityName: 'London',
        subtitle: 'United Kingdom',
        ianaName: 'Europe/London',
      ),
      WorldClockCity(
        id: 'tokyo',
        cityName: 'Tokyo',
        subtitle: 'Japan',
        ianaName: 'Asia/Tokyo',
      ),
    ]);
  }

  DateTime get shiftedUtc {
    final ms = DateTime.now().toUtc().millisecondsSinceEpoch +
        (travelHours.value * 3600 * 1000).round();
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  String formatTime(WorldClockCity city) => formatClockAndPeriod(city)[0];

  List<String> formatClockAndPeriod(WorldClockCity city) {
    tick.value;
    final utc = shiftedUtc;
    if (city.isLocal) {
      final d = utc.toLocal();
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      final wall = '$hh:$mm';
      if (_settings.is24HrsEnabled.value) {
        final parts = Utils.split24HourFormat(wall);
        return [parts[0], ''];
      }
      final parts = Utils.convertTo12HourFormat(wall);
      return [parts[0], parts[1]];
    }
    final loc = tz.getLocation(city.ianaName!);
    final t = tz.TZDateTime.from(utc, loc);
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    final wall = '$hh:$mm';
    if (_settings.is24HrsEnabled.value) {
      final parts = Utils.split24HourFormat(wall);
      return [parts[0], ''];
    }
    final parts = Utils.convertTo12HourFormat(wall);
    return [parts[0], parts[1]];
  }

  String formatZoneLine(WorldClockCity city) {
    tick.value;
    final utc = shiftedUtc;
    if (city.isLocal) {
      final d = utc.toLocal();
      final name = d.timeZoneName;
      if (name.isNotEmpty) {
        return name;
      }
      return _offsetLabel(d.timeZoneOffset);
    }
    final loc = tz.getLocation(city.ianaName!);
    final t = tz.TZDateTime.from(utc, loc);
    return t.timeZoneName;
  }

  String relativeVersusDevice(WorldClockCity city) {
    tick.value;
    if (city.isDeviceZone) {
      return 'Device time zone'.tr;
    }
    final utc = shiftedUtc;
    final deviceLocal = utc.toLocal();
    final loc = tz.getLocation(city.ianaName!);
    final cityT = tz.TZDateTime.from(utc, loc);
    final diffMin = cityT.timeZoneOffset.inMinutes -
        deviceLocal.timeZoneOffset.inMinutes;
    if (diffMin == 0) {
      return 'Same as device'.tr;
    }
    final sign = diffMin > 0 ? '+' : '';
    final h = diffMin ~/ 60;
    final m = diffMin.abs() % 60;
    if (m == 0) {
      return '${'Today'.tr}, $sign${h}h';
    }
    return '${'Today'.tr}, $sign${h}h ${m}min';
  }

  String _offsetLabel(Duration d) {
    final sign = d.isNegative ? '-' : '+';
    final total = d.inMinutes.abs();
    final h = total ~/ 60;
    final m = total % 60;
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    return 'GMT$sign$hh:$mm';
  }

  void setTravel(double hours) {
    travelHours.value = hours.clamp(travelMin, travelMax);
  }

  void resetTravel() {
    travelHours.value = 0;
  }

  String shiftedLocalSummary() {
    tick.value;
    final d = shiftedUtc.toLocal();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    String timeStr;
    if (_settings.is24HrsEnabled.value) {
      timeStr = '$hh:$mm';
    } else {
      final parts = Utils.convertTo12HourFormat('$hh:$mm');
      timeStr = '${parts[0]} ${parts[1]}';
    }
    final h = travelHours.value;
    if (h == 0) return timeStr;
    final sign = h > 0 ? '+' : '';
    return '$timeStr ($sign${h.toStringAsFixed(1)}h)';
  }

  static final _presets = <String, WorldClockCity>{
    'Paris': const WorldClockCity(
      id: 'paris',
      cityName: 'Paris',
      subtitle: 'France',
      ianaName: 'Europe/Paris',
    ),
    'Dubai': const WorldClockCity(
      id: 'dubai',
      cityName: 'Dubai',
      subtitle: 'UAE',
      ianaName: 'Asia/Dubai',
    ),
    'Sydney': const WorldClockCity(
      id: 'sydney',
      cityName: 'Sydney',
      subtitle: 'Australia',
      ianaName: 'Australia/Sydney',
    ),
    'Los Angeles': const WorldClockCity(
      id: 'la',
      cityName: 'Los Angeles',
      subtitle: 'CA, United States',
      ianaName: 'America/Los_Angeles',
    ),
  };

  void addPreset(String name) {
    final c = _presets[name];
    if (c == null) return;
    if (cities.any((e) => e.id == c.id)) return;
    cities.add(c);
  }

  List<String> availablePresets() {
    return _presets.keys
        .where((k) => !cities.any((c) => c.id == _presets[k]!.id))
        .toList();
  }
}
