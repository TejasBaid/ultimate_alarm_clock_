class WorldClockCity {
  const WorldClockCity({
    required this.id,
    required this.cityName,
    required this.subtitle,
    this.ianaName,
    this.isDeviceZone = false,
  });

  final String id;
  final String cityName;
  final String subtitle;

  final String? ianaName;
  final bool isDeviceZone;

  bool get isLocal => ianaName == null;
}
