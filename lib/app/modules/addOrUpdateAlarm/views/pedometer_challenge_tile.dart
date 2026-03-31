import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class PedometerChallenge extends StatelessWidget {
  const PedometerChallenge({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    int numberOfSteps;
    bool isPedometerEnabled;
    return Obx(
      () => InkWell(
        onTap: () {
          Utils.hapticFeedback();
          // storing initial state
          numberOfSteps = controller.numberOfSteps.value;
          isPedometerEnabled = controller.isPedometerEnabled.value;

          if (!controller.isPedometerEnabled.value) {
            controller.isPedometerEnabled.value = true;
            if (controller.numberOfSteps.value == 0) {
              controller.numberOfSteps.value = 10;
            }
          }
          
          _showPedometerSettingsBottomSheet(context, numberOfSteps, isPedometerEnabled);
        },
        child: ListTile(
          leading: Icon(
            controller.isPedometerEnabled.value ? Icons.directions_walk : Icons.directions_walk_outlined,
            color: controller.isPedometerEnabled.value 
                ? Get.find<ThemeController>().primaryColor.value 
                : themeController.primaryDisabledTextColor.value,
          ),
          title: Text(
            'Step Challenge'.tr,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
            ),
          ),
          subtitle: Text(
            controller.isPedometerEnabled.value && controller.numberOfSteps.value > 0
                ? controller.numberOfSteps.value > 1
                    ? '${controller.numberOfSteps.value} steps required'
                    : '${controller.numberOfSteps.value} step required'
                : 'Disabled'.tr,
            style: TextStyle(
              color: themeController.primaryDisabledTextColor.value,
            ),
          ),
          trailing: Switch.adaptive(
            value: controller.isPedometerEnabled.value,
            activeColor: Get.find<ThemeController>().primaryColor.value,
            onChanged: (value) {
              Utils.hapticFeedback();
              controller.isPedometerEnabled.value = value;
              if (!value) {
                controller.numberOfSteps.value = 0;
              } else if (controller.numberOfSteps.value == 0) {
                controller.numberOfSteps.value = 10;
                // Auto open settings when enabled for the first time
                _showPedometerSettingsBottomSheet(context, 0, false);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showPedometerSettingsBottomSheet(BuildContext context, int initialNumberOfSteps, bool initialIsPedometerEnabled) {
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
            maxChildSize: 0.8,
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
                            Icons.directions_walk,
                            color: Get.find<ThemeController>().primaryColor.value,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Step Challenge'.tr,
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
                            controller.isPedometerEnabled.value = initialIsPedometerEnabled;
                            controller.numberOfSteps.value = initialNumberOfSteps;
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
                                  title: 'Number of Steps'.tr,
                                  subtitle: 'How many steps are required'.tr,
                                  child: Column(
                                    children: [
                                      Obx(() => Text(
                                        controller.numberOfSteps.value.toString(),
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          color: Get.find<ThemeController>().primaryColor.value,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )),
                                      const SizedBox(height: 16),
                                      NumberPicker(
                                        value: controller.numberOfSteps.value,
                                        minValue: 1,
                                        maxValue: 100,
                                        onChanged: (value) {
                                          Utils.hapticFeedback();
                                          controller.numberOfSteps.value = value;
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
                                      const SizedBox(height: 16),
                                      // Step guidance
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.green.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Get out of bed and walk around to dismiss your alarm'.tr,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: themeController.primaryTextColor.value,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
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
