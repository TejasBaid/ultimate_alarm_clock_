import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/widgets/appearance_system_shell.dart';
import 'package:ultimate_alarm_clock/app/utils/app_theme_sets.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class ThemeSetTile extends StatefulWidget {
  const ThemeSetTile({
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
  State<ThemeSetTile> createState() => _ThemeSetTileState();
}

class _ThemeSetTileState extends State<ThemeSetTile> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLight =
          widget.themeController.currentTheme.value == ThemeMode.light;
      final currentAccent = widget.themeController.primaryColor.value;
      final textColor = widget.themeController.primaryTextColor.value;
      final selectedIndex = widget.themeController.colorThemeIndex.value;

      return AppearanceSystemShell(
        themeController: widget.themeController,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppearanceBlockHeader(
              tag: 'THEMES',
              title: 'Theme set',
              themeController: widget.themeController,
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: currentAccent.withOpacity(0.35),
                  ),
                  color: currentAccent.withOpacity(0.08),
                ),
                child: Text(
                  kThemeSetNames[selectedIndex],
                  style: TextStyle(
                    color: currentAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 14,
              children: List.generate(kAppThemeSets.length, (index) {
                final set = kAppThemeSets[index];
                final surface = isLight ? set.light : set.dark;
                final isSelected = selectedIndex == index;
                final accent = set.accent;

                final shadowSoft = isLight ? 0.1 : 0.05;

                return GestureDetector(
                  onTap: () {
                    Utils.hapticFeedback();
                    widget.themeController.setColorTheme(index);
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          surface.primaryBackground,
                          surface.secondaryBackground,
                        ],
                      ),
                      border: Border.all(
                        color: isSelected
                            ? accent.withOpacity(0.95)
                            : textColor.withOpacity(
                                isLight ? 0.08 : 0.14,
                              ),
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            shadowSoft,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: 7,
                          bottom: 7,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.45),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            left: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.45),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: accent,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              'Theme set hint'.tr,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.38),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    });
  }
}
