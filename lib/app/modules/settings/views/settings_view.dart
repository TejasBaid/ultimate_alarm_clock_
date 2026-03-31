import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/customize_undo_duration.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/enable_24Hour_format.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/enable_flip_to_snooze.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/enable_haptic_feedback.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/enable_sorted_alarm_list.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/language_menu.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/theme_value_tile.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/theme_set_tile.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/widgets/appearance_system_shell.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import '../controllers/settings_controller.dart';
import 'google_sign_in.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;
    return Obx(() => Scaffold(
      backgroundColor: controller.themeController.primaryBackgroundColor.value,
      appBar: AppBar(
        backgroundColor: controller.themeController.primaryBackgroundColor.value,
        title: Text(
            'Settings'.tr,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: controller.themeController.primaryTextColor.value,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: Obx(
            () => Icon(
              Icons.adaptive.arrow_back,
              color: controller.themeController.primaryTextColor.value,
            ),
          ),

          onPressed: () {
            Utils.hapticFeedback();
            Get.back();
          },
        ),
      ),
      
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Column(
              children: [
                SettingsSectionHeader(
                  themeController: controller.themeController,
                  title: 'Account',
                  tagline: 'Manage your cloud sync and sign-in',
                ),
                GoogleSignIn(
                  controller: controller,
                  width: width,
                  height: height,
                  themeController: controller.themeController,
                ),
                const SizedBox(height: 24),
                SettingsSectionHeader(
                  themeController: controller.themeController,
                  title: 'Preferences',
                  tagline: 'Customize alarm behaviors and formats',
                ),
                EnableHapticFeedback(
                  height: height,
                  width: width,
                  controller: controller,
                  themeController: controller.themeController,
                ),
                const SizedBox(height: 14),
                Enable24HourFormat(
                  height: height,
                  width: width,
                  controller: controller,
                  themeController: controller.themeController,
                ),
                const SizedBox(height: 14),
                EnableSortedAlarmList(
                  controller: controller,
                  height: height,
                  width: width,
                  themeController: controller.themeController,
                ),
                const SizedBox(height: 14),
                EnableFlipToSnooze(
                  controller: controller,
                  height: height,
                  width: width,
                  themeController: controller.themeController,
                ),
                const SizedBox(height: 24),

                SettingsSectionHeader(
                  themeController: controller.themeController,
                  title: 'Appearance & System',
                  tagline: 'Appearance system tagline',
                ),
                ThemeSetTile(
                  controller: controller,
                  height: height,
                  width: width,
                  themeController: controller.themeController,
                ),
                const SizedBox(height: 14),
                ThemeValueTile(
                  controller: controller,
                  height: height,
                  width: width,
                  themeController: controller.themeController,
                ),
                const SizedBox(height: 14),
                CustomizeUndoDuration(
                  width: width,
                  height: height,
                  themeController: controller.themeController,
                ),
                const SizedBox(height: 14),
                LanguageMenu(
                  controller: controller,
                  height: height,
                  width: width,
                  themeController: controller.themeController,
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
