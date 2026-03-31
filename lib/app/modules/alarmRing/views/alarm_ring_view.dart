import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import 'package:ultimate_alarm_clock/app/data/providers/isar_provider.dart';
import 'package:ultimate_alarm_clock/app/data/providers/firestore_provider.dart';
import 'package:ultimate_alarm_clock/app/data/models/alarm_model.dart';
import 'package:ultimate_alarm_clock/app/modules/alarmRing/views/sunrise_effect_widget.dart';

import '../controllers/alarm_ring_controller.dart';

// ignore: must_be_immutable
class AlarmRingView extends GetView<AlarmRingController> {
  AlarmRingView({Key? key}) : super(key: key);

  ThemeController themeController = Get.find<ThemeController>();

  Obx getAddSnoozeButtons(
      BuildContext context, int snoozeMinutes, String title) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            backgroundColor: MaterialStateProperty.all(
              themeController.secondaryBackgroundColor.value,
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: Text(
            title.tr,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: themeController.primaryTextColor.value,
                  fontWeight: FontWeight.w600,
                ),
          ),
          onPressed: () {
            Utils.hapticFeedback();
            controller.addMinutes(snoozeMinutes);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }

        Get.snackbar(
          'Note'.tr,
          "You can't go back while the alarm is ringing".tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
      child: SafeArea(
        child: Obx(() => Scaffold(
          backgroundColor: themeController.primaryBackgroundColor.value,
          body: Stack(
            children: [
              // Sunrise Effect Background
              Obx(() => SunriseEffectWidget(
                isEnabled: controller.currentlyRingingAlarm.value.isSunriseEnabled,
                durationMinutes: controller.currentlyRingingAlarm.value.sunriseDuration,
                maxIntensity: controller.currentlyRingingAlarm.value.sunriseIntensity,
                colorScheme: SunriseColorScheme.values[controller.currentlyRingingAlarm.value.sunriseColorScheme.clamp(0, 2)],
                onComplete: () {
                  debugPrint('Sunrise effect completed');
                },
              )),
              
              // Original UI Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(
                      () => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.formattedDate.value.toUpperCase(),
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2.0,
                                  color: themeController.primaryTextColor.value
                                      .withOpacity(0.8),
                                ),
                          ),
                          const SizedBox(height: 10),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                (controller.isSnoozing.value)
                                    ? "${controller.minutes.toString().padLeft(2, '0')}"
                                        ":${controller.seconds.toString().padLeft(2, '0')}"
                                    : (controller.is24HourFormat.value)
                                        ? '${controller.timeNow24Hr}'
                                        : '${controller.timeNow[0]} ${controller.timeNow[1]}',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                      fontSize: 96,
                                      fontWeight: FontWeight.w300,
                                      height: 1.0,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Obx(
                            () => Visibility(
                              visible: controller.isSnoozing.value,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  getAddSnoozeButtons(context, 1, '+1 min'),
                                  getAddSnoozeButtons(context, 2, '+2 min'),
                                  getAddSnoozeButtons(context, 5, '+5 min'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () {
                        return Visibility(
                          visible: controller
                              .currentlyRingingAlarm.value.note.isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Text(
                              controller.currentlyRingingAlarm.value.note,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: themeController.primaryTextColor.value,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w300,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                    Obx(
                      () => Visibility(
                        visible: !controller.isSnoozing.value,
                        child: Obx(
                          () => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 65,
                                width: width * 0.55,
                                child: OutlinedButton.icon(
                                  style: ButtonStyle(
                                    side: MaterialStateProperty.all(
                                      BorderSide(
                                        color: themeController.primaryTextColor.value.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    backgroundColor: MaterialStateProperty.all(
                                      themeController
                                          .secondaryBackgroundColor.value.withOpacity(0.5),
                                    ),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.snooze,
                                    color: themeController.primaryTextColor.value,
                                    size: 24,
                                  ),
                                  label: Text(
                                    'Snooze'.tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: themeController
                                              .primaryTextColor.value,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        ),
                                  ),
                                  onPressed: () {
                                    Utils.hapticFeedback();
                                    controller.startSnooze();
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              Obx(
                                () => Text(
                                  'Snooze ${controller.snoozeCount.value}/${controller.maxSnoozeCount.value}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: themeController
                                            .primaryTextColor.value.withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 80,
                left: width * 0.1,
                right: width * 0.1,
                child: Obx(
                  () => Visibility(
                    visible: controller.showButton.value,
                    child: SizedBox(
                      height: 70,
                      width: width * 0.8,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Get.find<ThemeController>().primaryColor.value),
                          foregroundColor: MaterialStateProperty.all(themeController.secondaryTextColor.value),
                          elevation: MaterialStateProperty.all(8),
                          shadowColor: MaterialStateProperty.all(Get.find<ThemeController>().primaryColor.value.withOpacity(0.4)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          Utils.hapticFeedback();
                          debugPrint('🔔 Dismiss button pressed');
                          
                          // Handle preview mode differently
                          if (controller.isPreviewMode.value) {
                            debugPrint('🔔 Preview mode - simple navigation back');
                            controller.cancelForegroundLock();
                            Get.offAllNamed('/bottom-navigation-bar');
                            return;
                          } 
                          controller.cancelForegroundLock();

                          if (controller.currentlyRingingAlarm.value.isGuardian) {
                            controller.guardianTimer.cancel();
                            debugPrint('🔔 Guardian timer canceled');
                          }
                          
                          
                          if (controller.currentlyRingingAlarm.value.isSharedAlarmEnabled) {
                            controller.rememberDismissedAlarm();
                            debugPrint('🔔 Blocked shared alarm: ${controller.currentlyRingingAlarm.value.alarmTime}, ID: ${controller.currentlyRingingAlarm.value.firestoreId}');
                          }
                          
                          
                          await controller.homeController.clearLastScheduledAlarm();
                          debugPrint('🔔 Cleared all scheduled alarms');
                          
                          
                          controller.homeController.refreshTimer = true;
                          debugPrint('🔔 Set refresh flag for alarm scheduling');
                          
                          
                          if (Utils.isChallengeEnabled(
                            controller.currentlyRingingAlarm.value,
                          )) {
                            debugPrint('🔔 Navigating to challenge screen');
                            Get.toNamed(
                              '/alarm-challenge',
                              arguments: controller.currentlyRingingAlarm.value,
                            );
                          } else {
                            debugPrint('🔔 Navigating to home screen');
                            Get.offAllNamed(
                              '/bottom-navigation-bar',
                              arguments: controller.currentlyRingingAlarm.value,
                            );
                          }
                        },
                        icon: Icon(
                          Utils.isChallengeEnabled(
                            controller.currentlyRingingAlarm.value,
                          )
                              ? Icons.directions_run
                              : Icons.alarm_off,
                          size: 26,
                          color: themeController.secondaryTextColor.value,
                        ),
                        label: Text(
                          Utils.isChallengeEnabled(
                            controller.currentlyRingingAlarm.value,
                          )
                              ? 'Start Challenge'.tr
                              : 'Dismiss'.tr,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                color: themeController.secondaryTextColor.value,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Exit Preview button - only show in preview mode
              if (controller.isPreviewMode.value)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    color: Colors.red,
                    child: TextButton(
                      onPressed: () {
                        Utils.hapticFeedback();
                        controller.cancelForegroundLock();
                        Get.offAllNamed('/bottom-navigation-bar');
                      },
                      child: Text(
                        'Exit Preview'.tr,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        )),
      ),
    );
  }
}