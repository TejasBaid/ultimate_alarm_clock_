import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class QrBarCode extends StatelessWidget {
  const QrBarCode({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    bool isQrEnabled;
    return Obx(
      () => InkWell(
        onTap: () async {
          Utils.hapticFeedback();
          // storing initial state
          isQrEnabled = controller.isQrEnabled.value;

          if (!controller.isQrEnabled.value) {
            await controller.requestQrPermission(context);
            if (!controller.isQrEnabled.value) return; // User denied permission
          }
          
          _showQrSettingsBottomSheet(context, isQrEnabled);
        },
        child: ListTile(
          leading: Icon(
            controller.isQrEnabled.value ? Icons.qr_code_scanner : Icons.qr_code_scanner_outlined,
            color: controller.isQrEnabled.value 
                ? Get.find<ThemeController>().primaryColor.value 
                : themeController.primaryDisabledTextColor.value,
          ),
          title: Text(
            'QR/Bar Code Challenge'.tr,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
            ),
          ),
          subtitle: Text(
            controller.isQrEnabled.value
                ? 'Scan QR code to dismiss alarm'.tr
                : 'Disabled'.tr,
            style: TextStyle(
              color: themeController.primaryDisabledTextColor.value,
            ),
          ),
          trailing: Switch.adaptive(
            value: controller.isQrEnabled.value,
            activeColor: Get.find<ThemeController>().primaryColor.value,
            onChanged: (value) async {
              Utils.hapticFeedback();
              if (value) {
                await controller.requestQrPermission(context);
                if (controller.isQrEnabled.value) {
                  // Auto open settings when enabled for the first time
                  _showQrSettingsBottomSheet(context, false);
                }
              } else {
                controller.isQrEnabled.value = false;
              }
            },
          ),
        ),
      ),
    );
  }

  void _showQrSettingsBottomSheet(BuildContext context, bool initialIsQrEnabled) {
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
                            Icons.qr_code_scanner,
                            color: Get.find<ThemeController>().primaryColor.value,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'QR/Bar Code Challenge'.tr,
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
                            controller.isQrEnabled.value = initialIsQrEnabled;
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
                                  title: 'How it works'.tr,
                                  subtitle: 'Scan instructions and tips'.tr,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Setup Instructions'.tr,
                                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                  color: themeController.primaryTextColor.value,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          '1. Scan a QR code on any object (book, poster, etc.)\n2. Move that object to another room\n3. When alarm rings, find and scan the same QR code'.tr,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: themeController.primaryTextColor.value,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              )
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
