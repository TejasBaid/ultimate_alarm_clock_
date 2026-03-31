import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/models/alarm_model.dart';
import 'package:ultimate_alarm_clock/app/data/providers/firestore_provider.dart';
import 'package:ultimate_alarm_clock/app/data/providers/isar_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/home/controllers/home_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/home/views/toggle_button.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class AlarmListItem extends StatelessWidget {
  final AlarmModel alarm;
  final int index;
  final HomeController controller;
  final ThemeController themeController;
  final SettingsController settingsController;
  final bool isLast;

  const AlarmListItem({
    Key? key,
    required this.alarm,
    required this.index,
    required this.controller,
    required this.themeController,
    required this.settingsController,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repeatDays = Utils.getRepeatDays(alarm.days);
    final timeParts = settingsController.is24HrsEnabled.value
        ? Utils.split24HourFormat(alarm.alarmTime)
        : Utils.convertTo12HourFormat(alarm.alarmTime);
    final clockStr = timeParts[0];
    final periodStr = timeParts.length > 1 ? timeParts[1].trim() : '';
    final repeatMain = repeatDays.replaceAll('Never'.tr, 'One Time'.tr);

    String timeUntilStr = 'Off'.tr;
    if (alarm.isEnabled) {
      try {
        timeUntilStr = Utils.timeUntilAlarm(
          Utils.stringToTimeOfDay(alarm.alarmTime),
          alarm.days,
        );
      } catch (e) {
        timeUntilStr = 'On'.tr;
      }
    }

    return Obx(
            () => GestureDetector(
          onTap: () {
            Utils.hapticFeedback();
            if (!controller.inMultipleSelectMode.value) {
              controller.isProfile.value = false;
              Get.toNamed('/add-update-alarm', arguments: alarm);
            }
          },
          onLongPress: () {
            controller.inMultipleSelectMode.value = true;
            controller.isAnyAlarmHolded.value = true;
            controller.alarmListPairs = Pair(
              controller.alarmListPairs?.first ?? [],
              List.generate(
                controller.alarmListPairs?.first.length ?? 0,
                    (i) => false.obs,
              ),
            );
            Utils.hapticFeedback();
          },
          onLongPressEnd: (_) {
            controller.isAnyAlarmHolded.value = false;
          },
          child: Container(
            color: Colors.transparent, // For gesture detector
            child: Column(
                children: [
            Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 8.0, 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            // Left Side
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Top Left: Time Until Alarm
                          Text(
                            timeUntilStr,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: themeController.primaryDisabledTextColor.value,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 2),
                          // Middle Left: Time
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                clockStr,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 46,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: -1.5,
                                      color: alarm.isEnabled
                                          ? themeController.primaryTextColor.value
                                          : themeController.primaryDisabledTextColor.value,
                                    ),
                              ),
                              if (periodStr.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Text(
                                  periodStr,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: alarm.isEnabled
                                            ? themeController.primaryTextColor.value
                                            : themeController.primaryDisabledTextColor.value,
                                      ),
                                ),
                              ]
                            ],
                          ),
                          // Label (if exists)
                          if (alarm.label.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              alarm.label,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: alarm.isEnabled
                                        ? themeController.primaryTextColor.value
                                        : themeController.primaryDisabledTextColor.value,
                                    fontWeight: FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                          const SizedBox(height: 4),
                          // Bottom Left: Repeat Days & Icons
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Text(
                                repeatMain,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: alarm.isEnabled
                                          ? themeController.primaryDisabledTextColor.value
                                          : themeController.primaryDisabledTextColor.value.withOpacity(0.5),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              _buildIcons(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right Side: Controls
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        controller.inMultipleSelectMode.value
                            ? ToggleButton(
                                controller: controller,
                                alarmIndex: index,
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.scale(
                                    scale: 0.9,
                                    child: Switch.adaptive(
                                      activeColor: ksecondaryColor,
                                      value: alarm.isEnabled,
                                      onChanged: (bool value) async {
                                        Utils.hapticFeedback();
                                        alarm.isEnabled = value;
                                        if (alarm.isSharedAlarmEnabled == true) {
                                          await FirestoreDb.updateAlarm(alarm.ownerId, alarm);
                                        } else {
                                          await IsarDb.updateAlarm(alarm);
                                        }
                                        controller.refreshTimer = true;
                                        controller.refreshUpcomingAlarms();
                                      },
                                    ),
                                  ),
                                  Transform.scale(
                                    scale: 0.9,
                                    child: PopupMenuButton(
                                      padding: EdgeInsets.zero,
                                      onSelected: (value) async {
                                        Utils.hapticFeedback();
                                        if (value == 0) {
                                          Get.toNamed('/alarm-ring', arguments: {
                                            'alarm': alarm,
                                            'preview': true
                                          });
                                        } else if (value == 1) {
                                          if (alarm.isSharedAlarmEnabled == true) {
                                            await FirestoreDb.deleteAlarm(controller.userModel.value, alarm.firestoreId!);
                                          } else {
                                            await IsarDb.deleteAlarm(alarm.isarId);
                                          }
                                          if (Get.isSnackbarOpen) {
                                            Get.closeAllSnackbars();
                                          }
                                          Get.snackbar(
                                            'Alarm deleted',
                                            'The alarm has been deleted.',
                                            duration: Duration(seconds: controller.duration.toInt()),
                                            snackPosition: SnackPosition.BOTTOM,
                                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                            mainButton: TextButton(
                                              onPressed: () async {
                                                if (alarm.isSharedAlarmEnabled == true) {
                                                  await FirestoreDb.addAlarm(controller.userModel.value, alarm);
                                                } else {
                                                  await IsarDb.addAlarm(alarm);
                                                }
                                              },
                                              child: const Text('Undo'),
                                            ),
                                          );
                                          controller.refreshTimer = true;
                                          controller.refreshUpcomingAlarms();
                                        }
                                      },
                                      color: themeController.primaryBackgroundColor.value,
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: alarm.isEnabled
                                            ? themeController.primaryTextColor.value
                                            : themeController.primaryDisabledTextColor.value,
                                      ),
                                      itemBuilder: (context) => [
                                        PopupMenuItem<int>(
                                          value: 0,
                                          child: Text(
                                            'Preview Alarm'.tr,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ),
                                        if (!alarm.isSharedAlarmEnabled || (alarm.isSharedAlarmEnabled && alarm.ownerId == controller.userModel.value?.id))
                                          PopupMenuItem<int>(
                                            value: 1,
                                            child: Text(
                                              'Delete Alarm'.tr,
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
    Divider(
      height: 1,
      thickness: 1,
      color: themeController.primaryTextColor.value.withOpacity(0.06),
      indent: 20,
      endIndent: 20,
    ),
    ],
    ),
    ),
    ),
    );
  }

  Widget _buildIcons() {
    final iconColor = alarm.isEnabled
        ? themeController.primaryTextColor.value.withOpacity(0.5)
        : themeController.primaryDisabledTextColor.value.withOpacity(0.5);

    List<Widget> icons = [];

    if (alarm.isSharedAlarmEnabled) {
      icons.add(Icon(Icons.share_arrival_time, size: 16, color: iconColor));
    }
    if (alarm.isLocationEnabled) {
      icons.add(Icon(Icons.location_pin, size: 16, color: iconColor));
    }
    if (alarm.isActivityEnabled) {
      icons.add(Icon(Icons.screen_lock_portrait, size: 16, color: iconColor));
    }
    if (alarm.isWeatherEnabled) {
      icons.add(Icon(Icons.cloudy_snowing, size: 16, color: iconColor));
    }
    if (alarm.isQrEnabled) {
      icons.add(Icon(Icons.qr_code_scanner, size: 16, color: iconColor));
    }
    if (alarm.isShakeEnabled) {
      icons.add(Icon(Icons.vibration, size: 16, color: iconColor));
    }
    if (alarm.isMathsEnabled) {
      icons.add(Icon(Icons.calculate, size: 16, color: iconColor));
    }
    if (alarm.isPedometerEnabled) {
      icons.add(Icon(Icons.directions_walk, size: 16, color: iconColor));
    }

    return Wrap(
      spacing: 4,
      children: icons,
    );
  }
}
