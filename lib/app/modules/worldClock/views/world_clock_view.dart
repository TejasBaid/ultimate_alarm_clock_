import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/worldClock/controllers/world_clock_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/worldClock/models/world_clock_city.dart';
import 'package:ultimate_alarm_clock/app/utils/end_drawer.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class WorldClockView extends GetView<WorldClockController> {
  const WorldClockView({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return Obx(
      () => Scaffold(
        backgroundColor: tc.primaryBackgroundColor.value,
        endDrawer: buildEndDrawer(context),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  children: [
                    _CircleAction(
                      icon: Icons.more_horiz_rounded,
                      onTap: () {
                        Utils.hapticFeedback();
                        Scaffold.of(context).openEndDrawer();
                      },
                      theme: tc,
                    ),
                    const Spacer(),
                    _CircleAction(
                      icon: Icons.add_rounded,
                      onTap: () => _showAddCity(context),
                      theme: tc,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Time Zones'.tr,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: tc.primaryTextColor.value,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(
                    () {
                      controller.tick.value;
                      return _ClockListCard(
                        theme: tc,
                        cities: controller.cities,
                        controller: controller,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCity(BuildContext context) {
    Utils.hapticFeedback();
    final opts = controller.availablePresets();
    if (opts.isEmpty) {
      Get.snackbar('World clock'.tr, 'All preset cities are already added.'.tr);
      return;
    }
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.find<ThemeController>().secondaryBackgroundColor.value,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add city'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            ...opts.map(
              (name) => ListTile(
                title: Text(name),
                onTap: () {
                  controller.addPreset(name);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final VoidCallback onTap;
  final ThemeController theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.secondaryBackgroundColor.value,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: theme.primaryTextColor.value.withOpacity(0.85),
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _ClockListCard extends StatelessWidget {
  const _ClockListCard({
    required this.theme,
    required this.cities,
    required this.controller,
  });

  static const double _fadeHeight = 52;
  static const double _panelStackBottom = 96;
  static const double _listBottomPadding = 128;

  final ThemeController theme;
  final List<WorldClockCity> cities;
  final WorldClockController controller;

  @override
  Widget build(BuildContext context) {
    final accent = theme.primaryColor.value;
    final cardBg = theme.secondaryBackgroundColor.value;
    final text = theme.primaryTextColor.value;
    final muted = theme.primaryDisabledTextColor.value;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent.withOpacity(0.12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  accent,
                  accent.withOpacity(0.35),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                ListView.separated(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: _listBottomPadding,
                  ),
                  itemCount: cities.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 1,
                    color: text.withOpacity(0.06),
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    final clockParts = controller.formatClockAndPeriod(city);
                    final clock = clockParts[0];
                    final period = clockParts[1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.relativeVersusDevice(city),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: muted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      city.cityName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: text,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    if (city.isDeviceZone) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: accent.withOpacity(0.65),
                                          ),
                                        ),
                                        child: Text(
                                          'Device time zone'.tr,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.4,
                                            color: accent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (city.subtitle.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      city.subtitle,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: muted,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        clock,
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                          color: text,
                                        ),
                                      ),
                                      if (period.isNotEmpty) ...[
                                        const SizedBox(width: 5),
                                        Text(
                                          period,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: text.withOpacity(0.88),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    controller.formatZoneLine(city),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: muted.withOpacity(0.5),
                                size: 22,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: _panelStackBottom,
                  height: _fadeHeight,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            cardBg.withOpacity(0),
                            cardBg,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 6,
                  child: _TimeTravelPanel(
                    controller: controller,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeTravelPanel extends StatelessWidget {
  const _TimeTravelPanel({
    required this.controller,
    required this.theme,
  });

  final WorldClockController controller;
  final ThemeController theme;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        controller.tick.value;
        final accent = theme.primaryColor.value;
        final bg = theme.secondaryBackgroundColor.value;
        final text = theme.primaryTextColor.value;
        final muted = theme.primaryDisabledTextColor.value;

        return Material(
          color: bg,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: accent.withOpacity(0.12)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: muted.withOpacity(0.6),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.history_toggle_off_rounded,
                      color: accent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Time Travel'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: text,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Utils.hapticFeedback();
                        controller.resetTravel();
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.restart_alt_rounded,
                            size: 16,
                            color: muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reset'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: text.withOpacity(0.35),
                    inactiveTrackColor: text.withOpacity(0.1),
                    thumbColor: text,
                    overlayColor: accent.withOpacity(0.12),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                      elevation: 2,
                    ),
                  ),
                  child: Slider(
                    value: controller.travelHours.value,
                    min: WorldClockController.travelMin,
                    max: WorldClockController.travelMax,
                    divisions: 48,
                    onChanged: (v) {
                      controller.setTravel(v);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4, bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '-12h',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: text.withOpacity(0.75),
                        ),
                      ),
                      Text(
                        '+12h',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: text.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
