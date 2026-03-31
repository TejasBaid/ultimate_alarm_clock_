import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/providers/firestore_provider.dart';

import '../../../utils/constants.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: Get.find<ThemeController>().primaryBackgroundColor.value,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Get.find<ThemeController>().primaryBackgroundColor.value,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Get.find<ThemeController>().primaryColor.value.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_active,
                color: Get.find<ThemeController>().primaryColor.value,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirestoreDb.getNotifications(),
        builder: (context, snapshot) {
          debugPrint('🔔 NotificationsView StreamBuilder update:');
          debugPrint('   - Connection state: ${snapshot.connectionState}');
          debugPrint('   - Has data: ${snapshot.hasData}');
          debugPrint('   - Has error: ${snapshot.hasError}');
          debugPrint('   - Error: ${snapshot.error}');
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('   - Showing loading indicator');
            return Center(
              child: CircularProgressIndicator(color: Get.find<ThemeController>().primaryColor.value),
            );
          }
          
          if (snapshot.hasError) {
            debugPrint('   - Showing error state: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }
          
          if (snapshot.hasData && snapshot.data != null) {
            final document = snapshot.data!;
            final data = document.data();
            final List notif = data != null ? (data['receivedItems'] ?? []) : [];
            controller.notifications = notif;
            
            debugPrint('   - Document exists: ${document.exists}');
            debugPrint('   - Document ID: ${document.id}');
            debugPrint('   - Document data exists: ${data != null}');
            debugPrint('   - Raw document data: $data');
            debugPrint('   - Notifications count: ${notif.length}');
            for (int i = 0; i < notif.length && i < 3; i++) {
              debugPrint('   - Notification ${i + 1}: ${notif[i]}');
            }
            
            if (controller.notifications.isEmpty) {
              debugPrint('   - Showing empty state');
              return _buildEmptyState();
            }
            
            debugPrint('   - Showing notifications list with ${controller.notifications.length} items');
            return RefreshIndicator(
              color: Get.find<ThemeController>().primaryColor.value,
              backgroundColor: ksecondaryBackgroundColor,
              onRefresh: () async {
                // Trigger a refresh
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                  final notification = controller.notifications[index];
                  return _buildNotificationCard(notification, index);
                },
              ),
            );
          }
          
          debugPrint('   - Falling back to empty state');
          return _buildEmptyState();
        },
      ),
    ));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ksecondaryBackgroundColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Shared alarms and profiles will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map notification, int index) {
    final isAlarm = notification['type'] != 'profile';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: ksecondaryBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAcceptDialog(notification, index),
                              child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isAlarm ? Get.find<ThemeController>().primaryColor.value.withOpacity(0.1) : Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isAlarm
                      ? Icon(
                          Icons.alarm,
                          color: Get.find<ThemeController>().primaryColor.value,
                          size: 28,
                        )
                      : Center(
                          child: Text(
                            '${notification['profileName']}'
                                .substring(0, 2)
                                .toUpperCase(),
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                        isAlarm ? 'Shared Alarm' : 'Shared Profile',
                                          style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                      const SizedBox(height: 4),
                      Text(
                        isAlarm ? notification['alarmTime'] : notification['profileName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                                        Text(
                        'From ${notification['owner']}',
                                          style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Get.find<ThemeController>().primaryColor.value.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                    'Tap to accept',
                                                    style: TextStyle(
                      fontSize: 12,
                      color: Get.find<ThemeController>().primaryColor.value,
                      fontWeight: FontWeight.w500,
                                                    ),
                  ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
      ),
    );
  }

  void _showAcceptDialog(Map notification, int index) {
    final isAlarm = notification['type'] != 'profile';
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ksecondaryBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isAlarm ? Get.find<ThemeController>().primaryColor.value.withOpacity(0.1) : Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isAlarm
                    ? Icon(
                        Icons.alarm,
                        color: Get.find<ThemeController>().primaryColor.value,
                        size: 32,
                      )
                    : Center(
                        child: Text(
                          '${notification['profileName']}'
                              .substring(0, 2)
                              .toUpperCase(),
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isAlarm ? 'Accept Shared Alarm?' : 'Accept Shared Profile?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  children: [
                    const TextSpan(text: 'From '),
                    TextSpan(
                      text: notification['owner'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Get.find<ThemeController>().primaryColor.value,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kprimaryBackgroundColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
            child: Column(
              children: [
                    Text(
                      isAlarm ? notification['alarmTime'] : notification['profileName'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Get.find<ThemeController>().primaryColor.value,
                      ),
                    ),
                    if (isAlarm) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Shared Alarm',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isAlarm && controller.allProfiles.isNotEmpty) ...[
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select profile to add to:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.allProfiles.length,
                    itemBuilder: (context, profileIndex) {
                      return Obx(() => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: controller.selectedProfile.value == controller.allProfiles[profileIndex]
                              ? Get.find<ThemeController>().primaryColor.value
                              : kprimaryBackgroundColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              controller.selectedProfile.value = controller.allProfiles[profileIndex];
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    controller.selectedProfile.value == controller.allProfiles[profileIndex]
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: controller.selectedProfile.value == controller.allProfiles[profileIndex]
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    controller.allProfiles[profileIndex],
                                    style: TextStyle(
                                      color: controller.selectedProfile.value == controller.allProfiles[profileIndex]
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ));
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        await FirestoreDb.removeItem(notification);
                        Get.back();
                        Get.snackbar(
                          'Rejected',
                          'Shared ${isAlarm ? 'alarm' : 'profile'} rejected',
                          backgroundColor: Colors.red.withOpacity(0.1),
                          colorText: Colors.red,
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.withOpacity(0.3)),
                        ),
                      ),
                      child: Text(
                        'Reject',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          debugPrint('🎯 Accept button pressed');
                          
                          // Show loading
                          Get.dialog(
                            Center(
                              child: CircularProgressIndicator(color: Get.find<ThemeController>().primaryColor.value),
                            ),
                            barrierDismissible: false,
                          );
                          debugPrint('🔄 Loading dialog shown');
                          
                          if (isAlarm) {
                            debugPrint('🔔 Accepting shared alarm...');
                            await controller.acceptSharedALarm(
                              notification['owner'],
                              notification['AlarmName'],
                            );
                            debugPrint('✅ Shared alarm accepted successfully');
                          } else {
                            debugPrint('📁 Importing profile...');
                            await controller.importProfile(
                              notification['owner'],
                        notification['profileName'],
                            );
                            debugPrint('✅ Profile imported successfully');
                          }
                          
                          debugPrint('🗑️ Removing notification item...');
                          await FirestoreDb.removeItem(notification);
                          debugPrint('✅ Notification item removed');
                          
                          // Close all dialogs and navigate back to notifications
                          debugPrint('❌ Closing all dialogs');
                          Get.until((route) => !Get.isDialogOpen!);
                          
                          debugPrint('🎉 Showing success snackbar');
                          Get.snackbar(
                            'Success!',
                            'Shared ${isAlarm ? 'alarm' : 'profile'} added successfully',
                            backgroundColor: Get.find<ThemeController>().primaryColor.value.withOpacity(0.1),
                            colorText: Get.find<ThemeController>().primaryColor.value,
                            snackPosition: SnackPosition.TOP,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        } catch (e) {
                          debugPrint('❌ Error in accept button: $e');
                          debugPrint('❌ Stack trace: ${StackTrace.current}');
                          
                          // Close all dialogs if open
                          if (Get.isDialogOpen ?? false) {
                            debugPrint('❌ Closing all dialogs due to error');
                            Get.until((route) => !Get.isDialogOpen!);
                          }
                          
                          Get.snackbar(
                            'Error',
                            'Failed to add shared ${isAlarm ? 'alarm' : 'profile'}: ${e.toString()}',
                            backgroundColor: Colors.red.withOpacity(0.1),
                            colorText: Colors.red,
                            snackPosition: SnackPosition.TOP,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.find<ThemeController>().primaryColor.value,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Accept',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
