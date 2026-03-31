import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/widgets/appearance_system_shell.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class ThemeValueTile extends StatelessWidget {
  const ThemeValueTile({
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
  Widget build(BuildContext context) {
    return Obx(() {
      final isLight = themeController.currentTheme.value == ThemeMode.light;
      final accent = themeController.primaryColor.value;
      final text = themeController.primaryTextColor.value;
      final muted = text.withOpacity(0.4);

      return AppearanceSystemShell(
        themeController: themeController,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppearanceBlockHeader(
              tag: 'DISPLAY',
              title: 'Enable Light Mode',
              themeController: themeController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Dark'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isLight ? FontWeight.w500 : FontWeight.w800,
                      letterSpacing: 0.6,
                      color: isLight ? muted : text,
                    ),
                  ),
                ),
                _EdgeThemeToggle(
                  isLight: isLight,
                  accent: accent,
                  primaryText: text,
                  trackMuted: text.withOpacity(0.12),
                  onToggle: (toLight) {
                    Utils.hapticFeedback();
                    themeController.toggleThemeValue(toLight);
                    Get.changeThemeMode(themeController.currentTheme.value);
                  },
                ),
                Expanded(
                  child: Text(
                    'Light'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isLight ? FontWeight.w800 : FontWeight.w500,
                      letterSpacing: 0.6,
                      color: isLight ? text : muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _EdgeThemeToggle extends StatelessWidget {
  const _EdgeThemeToggle({
    required this.isLight,
    required this.accent,
    required this.primaryText,
    required this.trackMuted,
    required this.onToggle,
  });

  final bool isLight;
  final Color accent;
  final Color primaryText;
  final Color trackMuted;
  final void Function(bool toLight) onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isLight),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 64,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isLight ? accent.withOpacity(0.22) : trackMuted,
          border: Border.all(
            color: isLight
                ? accent.withOpacity(0.55)
                : primaryText.withOpacity(0.14),
            width: 1.2,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: isLight ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: isLight ? accent : primaryText.withOpacity(0.88),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isLight ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                  size: 16,
                  color: isLight
                      ? Colors.black.withOpacity(0.82)
                      : Colors.white.withOpacity(0.92),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
