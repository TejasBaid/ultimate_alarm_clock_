import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class MemoryChallengeTile extends StatelessWidget {
  const MemoryChallengeTile({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    bool isMemoryEnabled;
    int numMemoryRounds;
    return Obx(
      () => InkWell(
        onTap: () {
          Utils.hapticFeedback();
          isMemoryEnabled = controller.isMemoryEnabled.value;
          numMemoryRounds = controller.numMemoryRounds.value;

          if (!controller.isMemoryEnabled.value) {
            controller.isMemoryEnabled.value = true;
            if (controller.numMemoryRounds.value == 0) {
              controller.numMemoryRounds.value = 3;
            }
          }
          
          _showMemorySettingsBottomSheet(context, isMemoryEnabled, numMemoryRounds);
        },
        child: ListTile(
          leading: Icon(
            controller.isMemoryEnabled.value ? Icons.grid_view : Icons.grid_view_outlined,
            color: controller.isMemoryEnabled.value 
                ? Get.find<ThemeController>().primaryColor.value 
                : themeController.primaryDisabledTextColor.value,
          ),
          title: Text(
            'Memory Challenge'.tr,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
            ),
          ),
          subtitle: Text(
            controller.isMemoryEnabled.value && controller.numMemoryRounds.value > 0
                ? '${controller.numMemoryRounds.value} rounds'
                : 'Disabled'.tr,
            style: TextStyle(
              color: themeController.primaryDisabledTextColor.value,
            ),
          ),
          trailing: Switch.adaptive(
            value: controller.isMemoryEnabled.value,
            activeColor: Get.find<ThemeController>().primaryColor.value,
            onChanged: (value) {
              Utils.hapticFeedback();
              controller.isMemoryEnabled.value = value;
              if (!value) {
                controller.numMemoryRounds.value = 0;
              } else if (controller.numMemoryRounds.value == 0) {
                controller.numMemoryRounds.value = 3;
                _showMemorySettingsBottomSheet(context, false, 3);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showMemorySettingsBottomSheet(BuildContext context, bool initialIsMemoryEnabled, int initialNumMemoryRounds) {
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
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: themeController.primaryDisabledTextColor.value.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                  
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
                            Icons.grid_view,
                            color: Get.find<ThemeController>().primaryColor.value,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Memory Challenge'.tr,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: themeController.primaryTextColor.value,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Utils.hapticFeedback();
                            controller.isMemoryEnabled.value = initialIsMemoryEnabled;
                            controller.numMemoryRounds.value = initialNumMemoryRounds;
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
                  
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Column(
                            children: [
                                    _buildSection(
                                      title: 'Number of Rounds'.tr,
                                      subtitle: 'How many patterns to memorize'.tr,
                                      child: Column(
                                        children: [
                                          Obx(() => Text(
                                            controller.numMemoryRounds.value.toString(),
                                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                              color: Get.find<ThemeController>().primaryColor.value,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )),
                                          const SizedBox(height: 16),
                                          NumberPicker(
                                            value: controller.numMemoryRounds.value,
                                            minValue: 1,
                                            maxValue: 10,
                                            onChanged: (value) {
                                              Utils.hapticFeedback();
                                              controller.numMemoryRounds.value = value;
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
          ),
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
