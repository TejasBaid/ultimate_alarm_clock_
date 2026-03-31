import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/home/controllers/home_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/widgets/appearance_system_shell.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class CustomizeUndoDuration extends StatelessWidget {
  CustomizeUndoDuration({
    super.key,
    required this.themeController,
    required this.height,
    required this.width,
  });

  final ThemeController themeController;
  final double width;
  final double height;

  final HomeController homeController = Get.find<HomeController>();

  void _openSheet(BuildContext context) {
    Utils.hapticFeedback();
    final initial = homeController.duration.value;
    var applied = false;

    Get.bottomSheet(
      Obx(
        () {
          final accent = themeController.primaryColor.value;
          final bg = themeController.secondaryBackgroundColor.value;
          final text = themeController.primaryTextColor.value;
          final sec = themeController.secondaryTextColor.value;

          return Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: text.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'UNDO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w800,
                      color: accent.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize Undo Duration'.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: text,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${homeController.duration.value} seconds'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: accent,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: accent,
                      inactiveTrackColor: text.withOpacity(0.12),
                      thumbColor: accent,
                      overlayColor: accent.withOpacity(0.18),
                      trackHeight: 5,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 11,
                        elevation: 4,
                      ),
                    ),
                    child: Slider(
                      value: homeController.selecteddurationDouble.value,
                      onChanged: (double value) {
                        homeController.selecteddurationDouble.value = value;
                        homeController.duration.value = value.toInt();
                      },
                      min: 0,
                      max: 20,
                      divisions: 20,
                      label: '${homeController.duration.value}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            homeController.duration.value = initial;
                            homeController.selecteddurationDouble.value =
                                initial.toDouble();
                            Get.back();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: text.withOpacity(0.7),
                            side: BorderSide(color: text.withOpacity(0.2)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Cancel'.tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            applied = true;
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: sec,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: accent.withOpacity(0.5),
                          ),
                          child: Text(
                            'Apply Duration'.tr,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    ).then((_) {
      if (!applied) {
        homeController.duration.value = initial;
        homeController.selecteddurationDouble.value = initial.toDouble();
      }
    });
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
            onTap: () => _openSheet(context),
            borderRadius: BorderRadius.circular(14),
            splashColor: themeController.primaryColor.value.withOpacity(0.08),
            child: AppearanceBlockHeader(
              tag: 'WINDOW',
              title: 'Undo Duration',
              themeController: themeController,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: themeController.primaryColor.value
                        .withOpacity(0.25),
                  ),
                  color: themeController.primaryColor.value
                      .withOpacity(0.07),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${homeController.duration.value.round()}s',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: themeController.primaryColor.value,
                      ),
                    ),
                    const SizedBox(width: 6),
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
      ),
    );
  }
}
