import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/widgets/appearance_system_shell.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

class EnableHapticFeedback extends StatefulWidget {
  const EnableHapticFeedback({
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
  State<EnableHapticFeedback> createState() => _EnableHapticFeedbackState();
}

class _EnableHapticFeedbackState extends State<EnableHapticFeedback> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppearanceSystemShell(
        themeController: widget.themeController,
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
        child: AppearanceBlockHeader(
          tag: 'HAPTICS',
          title: 'Enable Haptic Feedback',
          themeController: widget.themeController,
          trailing: Switch.adaptive(
            value: widget.controller.isHapticFeedbackEnabled.value,
            activeColor: widget.themeController.primaryColor.value,
            onChanged: (bool value) async {
              widget.controller.toggleHapticFeedback(value);
              Utils.hapticFeedback();
            },
          ),
        ),
      ),
    );
  }
}
