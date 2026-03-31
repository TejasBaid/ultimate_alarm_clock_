import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/widgets/appearance_system_shell.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

class EnableFlipToSnooze extends StatefulWidget {
  const EnableFlipToSnooze({
    super.key,
    required this.controller,
    required this.height,
    required this.width,
    required this.themeController,
  });

  final SettingsController controller;
  final ThemeController themeController;

  final double height;
  final double width;

  @override
  State<EnableFlipToSnooze> createState() => _EnableFlipToSnoozeState();
}

class _EnableFlipToSnoozeState extends State<EnableFlipToSnooze> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppearanceSystemShell(
        themeController: widget.themeController,
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
        child: AppearanceBlockHeader(
          tag: 'GESTURES',
          title: 'Enable Flip To Snooze',
          themeController: widget.themeController,
          trailing: Switch.adaptive(
            value: widget.controller.isFlipToSnooze.value,
            activeColor: widget.themeController.primaryColor.value,
            onChanged: (bool value) async {
              widget.controller.toggleFlipToSnooze(value);
              Utils.hapticFeedback();
            },
          ),
        ),
      ),
    );
  }
}
