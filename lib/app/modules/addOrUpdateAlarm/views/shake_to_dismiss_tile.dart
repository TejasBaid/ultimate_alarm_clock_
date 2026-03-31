import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class ShakeToDismiss extends StatelessWidget {
  const ShakeToDismiss({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    int shakeTimes;
    bool isShakeEnabled;
    return Obx(
      () => InkWell(
        onTap: () {
          Utils.hapticFeedback();
          // storing initial state
          shakeTimes = controller.shakeTimes.value;
          isShakeEnabled = controller.isShakeEnabled.value;

          if (!controller.isShakeEnabled.value) {
            controller.isShakeEnabled.value = true;
            if (controller.shakeTimes.value == 0) {
              controller.shakeTimes.value = 5;
            }
          }
          
          _showShakeSettingsBottomSheet(context, shakeTimes, isShakeEnabled);
        },
        child: ListTile(
          leading: Icon(
            controller.isShakeEnabled.value ? Icons.vibration : Icons.vibration_outlined,
            color: controller.isShakeEnabled.value 
                ? Get.find<ThemeController>().primaryColor.value 
                : themeController.primaryDisabledTextColor.value,
          ),
          title: Text(
            'Shake to Dismiss'.tr,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
            ),
          ),
          subtitle: Text(
            controller.isShakeEnabled.value && controller.shakeTimes.value > 0
                ? controller.shakeTimes.value > 1
                    ? '${controller.shakeTimes.value} shakes required'.tr
                    : '${controller.shakeTimes.value} shake required'.tr
                : 'Disabled'.tr,
            style: TextStyle(
              color: themeController.primaryDisabledTextColor.value,
            ),
          ),
          trailing: Switch.adaptive(
            value: controller.isShakeEnabled.value,
            activeColor: Get.find<ThemeController>().primaryColor.value,
            onChanged: (value) {
              Utils.hapticFeedback();
              controller.isShakeEnabled.value = value;
              if (!value) {
                controller.shakeTimes.value = 0;
              } else if (controller.shakeTimes.value == 0) {
                controller.shakeTimes.value = 5;
                // Auto open settings when enabled for the first time
                _showShakeSettingsBottomSheet(context, 0, false);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showShakeSettingsBottomSheet(BuildContext context, int initialShakeTimes, bool initialIsShakeEnabled) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeController.secondaryBackgroundColor.value,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: themeController.primaryDisabledTextColor.value.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Get.find<ThemeController>().primaryColor.value.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.vibration,
                            color: Get.find<ThemeController>().primaryColor.value,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Shake to Dismiss'.tr,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: themeController.primaryTextColor.value,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Utils.hapticFeedback();
                            // Reset to initial values
                            controller.isShakeEnabled.value = initialIsShakeEnabled;
                            controller.shakeTimes.value = initialShakeTimes;
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: themeController.primaryDisabledTextColor.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Settings
                          Column(
                            children: [
                              _buildSection(
                                  title: 'Number of Shakes'.tr,
                                  subtitle: 'How many shakes are required'.tr,
                                  child: Column(
                                    children: [
                                      Obx(() => Text(
                                        controller.shakeTimes.value.toString(),
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          color: Get.find<ThemeController>().primaryColor.value,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )),
                                      const SizedBox(height: 16),
                                      NumberPicker(
                                        value: controller.shakeTimes.value,
                                        minValue: 1,
                                        maxValue: 50,
                                        onChanged: (value) {
                                          Utils.hapticFeedback();
                                          controller.shakeTimes.value = value;
                                        },
                                        itemWidth: Utils
                                            .getResponsiveNumberPickerItemWidth(
                                          context,
                                          screenWidth: MediaQuery.of(context).size.width,
                                          baseWidthFactor: 0.2,
                                        ),
                                        textStyle: Utils
                                            .getResponsiveNumberPickerTextStyle(
                                          context,
                                          baseFontSize: 16,
                                          color: themeController.primaryDisabledTextColor.value,
                                        ),
                                        selectedTextStyle: Utils
                                            .getResponsiveNumberPickerSelectedTextStyle(
                                          context,
                                          baseFontSize: 20,
                                          color: Get.find<ThemeController>().primaryColor.value,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  
                  // Action buttons
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    decoration: BoxDecoration(
                      color: themeController.secondaryBackgroundColor.value,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Utils.hapticFeedback();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.find<ThemeController>().primaryColor.value,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save'.tr,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              )
            );
          },

          )
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeController.primaryBackgroundColor.value,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: themeController.primaryDisabledTextColor.value,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

}
