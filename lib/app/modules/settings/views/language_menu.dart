import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/widgets/appearance_system_shell.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class LanguageMenu extends StatelessWidget {
  const LanguageMenu({
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

  String _labelForKey(String key) {
    final map = controller.optionslocales[key];
    if (map == null) return key;
    return map['description'] as String;
  }

  void _openPicker(BuildContext context) {
    Utils.hapticFeedback();
    Get.bottomSheet(
      Obx(() {
        final accent = themeController.primaryColor.value;
        final bg = themeController.secondaryBackgroundColor.value;
        final text = themeController.primaryTextColor.value;
        final current = controller.currentLanguage.value;

        return SizedBox(
          height: Get.height * 0.58,
          child: Container(
            decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(color: accent.withOpacity(0.35), width: 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
            ),
            child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: text.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'LOCALE',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w800,
                    color: accent.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Change Language'.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: text,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    children: controller.optionslocales.entries.map((e) {
                      final key = e.key;
                      final desc = e.value['description'] as String;
                      final selected = current == key;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Utils.hapticFeedback();
                              controller.updateLocale(key);
                              Get.back();
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? accent.withOpacity(0.55)
                                      : text.withOpacity(0.08),
                                  width: selected ? 1.5 : 1,
                                ),
                                color: selected
                                    ? accent.withOpacity(0.12)
                                    : text.withOpacity(0.03),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: accent.withOpacity(0.15),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      desc,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: selected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        letterSpacing: -0.2,
                                        color: text,
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: accent,
                                      size: 24,
                                    )
                                  else
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: text.withOpacity(0.25),
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppearanceSystemShell(
        themeController: themeController,
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openPicker(context),
            borderRadius: BorderRadius.circular(14),
            splashColor: themeController.primaryColor.value.withOpacity(0.08),
            child: AppearanceBlockHeader(
              tag: 'LOCALE',
              title: 'Change Language',
              themeController: themeController,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width * 0.38),
                    child: Text(
                      _labelForKey(controller.currentLanguage.value),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: themeController.primaryColor.value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 22,
                    color: themeController.primaryTextColor.value
                        .withOpacity(0.45),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
