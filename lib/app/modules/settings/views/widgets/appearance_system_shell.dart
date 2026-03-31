import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class AppearanceSystemShell extends StatelessWidget {
  const AppearanceSystemShell({
    super.key,
    required this.child,
    required this.themeController,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 22),
  });

  final Widget child;
  final ThemeController themeController;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLightMode = themeController.currentTheme.value == ThemeMode.light;
      
      return Center(
        child: Container(
          width: Get.width * 0.92,
          decoration: Utils.getCustomTileBoxDecoration(isLightMode: isLightMode),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      );
    });
  }
}

class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({
    super.key,
    required this.themeController,
    required this.title,
    required this.tagline,
  });

  final ThemeController themeController;
  final String title;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final text = themeController.primaryTextColor.value;

      return Center(
        child: SizedBox(
          width: Get.width * 0.92,
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.tr,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.1,
                    color: text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tagline.tr,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1,
                    color: text.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class AppearanceBlockHeader extends StatelessWidget {
  const AppearanceBlockHeader({
    super.key,
    required this.tag,
    required this.title,
    required this.themeController,
    this.trailing,
  });

  final String tag;
  final String title;
  final ThemeController themeController;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final accent = themeController.primaryColor.value;
      final text = themeController.primaryTextColor.value;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 2.6,
                    fontWeight: FontWeight.w800,
                    color: accent.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: text,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      );
    });
  }
}
