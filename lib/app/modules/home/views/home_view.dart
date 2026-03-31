// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/models/alarm_model.dart';
import 'package:ultimate_alarm_clock/app/data/providers/firestore_provider.dart';
import 'package:ultimate_alarm_clock/app/data/providers/isar_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/home/views/google_calender_dialog.dart';
import 'package:ultimate_alarm_clock/app/modules/home/views/profile_config.dart';
import 'package:ultimate_alarm_clock/app/modules/home/views/toggle_button.dart';
import 'package:ultimate_alarm_clock/app/modules/home/views/alarm_list_item.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/audio_utils.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/end_drawer.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

import '../controllers/home_controller.dart';
import 'notification_icon.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);
  ThemeController themeController = Get.find<ThemeController>();
  SettingsController settingsController = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    var width = Get.width;
    var height = Get.height;
    return Obx(() => Scaffold(
      backgroundColor: themeController.primaryBackgroundColor.value,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(
        () => Visibility(
            visible: controller.inMultipleSelectMode.value ? false : true,
            child: Container(
              height: width * 0.13,
              width: width * 0.13,
              child: FloatingActionButton(
                backgroundColor: themeController.primaryColor.value,
                foregroundColor: Colors.white,
                onPressed: () {
                  Utils.hapticFeedback();
                  controller.isProfile.value = false;
                  Get.toNamed(
                    '/add-update-alarm',
                    arguments: controller.genFakeAlarmModel(),
                  );
                },
                child: Container(
                    child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: controller.scalingFactor.value * 30,
                )),
              ),
            )),
      ),
      endDrawer: buildEndDrawer(context),
      appBar: null,
      body: SafeArea(
        child: Obx(
          () => NestedScrollView(
            controller: controller.scrollController,
            // If the user is not in the multiple select mode
            headerSliverBuilder: controller.inMultipleSelectMode.value == false
                ? (context, innerBoxIsScrolled) => [
                      // Show the normal app bar
                      SliverAppBar(
                        backgroundColor: themeController.primaryBackgroundColor.value,
                        actions: [Container()],
                        automaticallyImplyLeading: false,
                        expandedHeight: height / 7.9,
                        floating: true,
                        pinned: true,
                        snap: false,
                        centerTitle: true,
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center everything vertically
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                          left: 25 *
                                              controller.scalingFactor.value,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Next alarm'.tr,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    color: themeController.primaryDisabledTextColor.value,
                                                    fontSize: 16 *
                                                        controller.scalingFactor
                                                            .value,
                                                  ),
                                            ),
                                            Obx(
                                              () => Text(
                                                controller.alarmTime.value.tr,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall!
                                                    .copyWith(
                                                      color: themeController.primaryTextColor.value
                                                              .withOpacity(
                                                              0.75,
                                                            ),
                                                      fontSize: 14 *
                                                          controller
                                                              .scalingFactor
                                                              .value,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          notificationIcon(controller),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              onTap: () async {
                                                controller.isCalender.value =
                                                    true;
                                                Get.dialog(
                                                  await googleCalenderDialog(
                                                    controller,
                                                    themeController,
                                                    context,
                                                  ),
                                                );
                                              },
                                              child: SvgPicture.asset(
                                                'assets/images/GC.svg',
                                                colorFilter:
                                                    ColorFilter.mode(
                                                  themeController.primaryTextColor.value.withOpacity(0.75),
                                                  BlendMode.srcIn,
                                                ),
                                                height: 30 *
                                                    controller
                                                        .scalingFactor.value,
                                                width: 30 *
                                                    controller
                                                        .scalingFactor.value,
                                              ),
                                            ),
                                          ),
                                          Obx(
                                            () => Visibility(
                                              visible:
                                                  controller.scalingFactor < 0.9
                                                      ? false
                                                      : true,
                                              child: IconButton(
                                                onPressed: () {
                                                  Utils.hapticFeedback();
                                                  Scaffold.of(context)
                                                      .openEndDrawer();
                                                },
                                                icon: const Icon(
                                                  Icons.menu,
                                                ),
                                                color: themeController.primaryTextColor.value
                                                        .withOpacity(0.75),
                                                iconSize: 27 *
                                                    controller.scalingFactor.value,
                                              ),

                                              //   PopupMenuButton(
                                              //     // onPressed: () {
                                              //     //   Utils.hapticFeedback();
                                              //     //   Get.toNamed('/settings');
                                              //     // },

                                              //     icon: const Icon(Icons.more_vert),
                                              //     color: themeController
                                              //             .isLightMode.value
                                              //         ? kLightSecondaryBackgroundColor
                                              //         : ksecondaryBackgroundColor,
                                              //     iconSize: 27 *
                                              //         controller.scalingFactor.value,
                                              //     itemBuilder: (context) {
                                              //       return [
                                              //         PopupMenuItem<String>(
                                              //           onTap: () {
                                              //             Utils.hapticFeedback();
                                              //             Get.toNamed('/settings');
                                              //           },
                                              //           child: Text(
                                              //             'Settings',
                                              //             style: Theme.of(context)
                                              //                 .textTheme
                                              //                 .bodyMedium!
                                              //                 .copyWith(
                                              //                     color: themeController
                                              //                             .isLightMode
                                              //                             .value
                                              //                         ? kLightPrimaryTextColor
                                              //                         : kprimaryTextColor),
                                              //           ),
                                              //         ),
                                              //         PopupMenuItem<String>(
                                              //           value: 'option1',
                                              //           child: Text(
                                              //             'About',
                                              //             style: Theme.of(context)
                                              //                 .textTheme
                                              //                 .bodyMedium!
                                              //                 .copyWith(
                                              //                     color: themeController
                                              //                             .isLightMode
                                              //                             .value
                                              //                         ? kLightPrimaryTextColor
                                              //                         : kprimaryTextColor),
                                              //           ),
                                              //         ),
                                              //       ];
                                              //     },
                                              //   ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ]
                : (context, innerBoxIsScrolled) => [
                      // Else show the multiple select mode app bar
                      SliverAppBar(
                        backgroundColor: themeController.primaryBackgroundColor.value,
                        automaticallyImplyLeading: false,
                        actions: [Container()],
                        expandedHeight: height / 7.9,
                        floating: true,
                        pinned: true,
                        snap: false,
                        centerTitle: true,
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center everything vertically
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              // On pressing the close button, we're closing the multiple select mode, and clearing the select alarm set
                                              controller.inMultipleSelectMode
                                                  .value = false;
                                              controller.isAnyAlarmHolded
                                                  .value = false;
                                              controller.isAllAlarmsSelected
                                                  .value = false;
                                              controller.numberOfAlarmsSelected
                                                  .value = 0;
                                              controller.selectedAlarmSet
                                                  .clear();
                                            },
                                            icon: const Icon(Icons.close),
                                            color: themeController.primaryTextColor.value
                                                    .withOpacity(0.75),
                                            iconSize: 27 *
                                                controller.scalingFactor.value,
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2 *
                                                  controller
                                                      .scalingFactor.value,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Select alarms to delete'.tr,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall!
                                                      .copyWith(
                                                        color: themeController.primaryDisabledTextColor.value,
                                                        fontSize: 16 *
                                                            controller
                                                                .scalingFactor
                                                                .value,
                                                      ),
                                                ),
                                                Container(
                                                  height: 35,
                                                  width: MediaQuery.of(context).size.width / 1.2,
                                                  child: Row(
                                                    children: [
                                                      Obx(() {
                                                        // Storing the number of selected alarms
                                                        int numberOfAlarmsSelected =
                                                            controller
                                                                .numberOfAlarmsSelected
                                                                .value;
                                                        return Text(
                                                          numberOfAlarmsSelected ==
                                                                  0
                                                              ? 'No alarm selected'
                                                                  .tr
                                                              : '@noofAlarm alarms selected'
                                                                  .trParams({
                                                                  'noofAlarm':
                                                                      numberOfAlarmsSelected
                                                                          .toString(),
                                                                }),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .displaySmall!
                                                                  .copyWith(
                                                                    color: themeController.primaryTextColor.value
                                                                            .withOpacity(
                                                                            0.75,
                                                                          ),
                                                                    fontSize: 14 *
                                                                        controller
                                                                            .scalingFactor
                                                                            .value,
                                                                  ),
                                                        );
                                                      }),
                                                      Spacer(),
                                                      Row(
                                                        children: [
                                                          // All alarm select button
                                                          ToggleButton(
                                                            controller:
                                                                controller,
                                                            isSelected: controller
                                                                .isAllAlarmsSelected,
                                                          ),

                                                          // Delete button
                                                          SizedBox(
                                                            width: 30 * controller.scalingFactor.value,
                                                          ),
                                                          Obx(
                                                            () => InkWell(
                                                              onTap: () async {
                                                                if (controller.numberOfAlarmsSelected.value > 0) {
                                                                  
                                                                  bool confirm = await Get.defaultDialog(
                                                                    title: 'Confirmation'.tr,
                                                                    titleStyle: Theme.of(context).textTheme.displaySmall,
                                                                    backgroundColor: themeController.secondaryBackgroundColor.value,
                                                                    content: Column(
                                                                      children: [
                                                                        Text(
                                                                          'Delete ${controller.numberOfAlarmsSelected.value} selected alarms?'.tr,
                                                                          style: Theme.of(context).textTheme.bodyMedium,
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(top: 20),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              TextButton(
                                                                                onPressed: () => Get.back(result: false),
                                                                                style: ButtonStyle(
                                                                                  backgroundColor: MaterialStateProperty.all(
                                                                                    themeController.primaryTextColor.value.withOpacity(0.5),
                                                                                  ),
                                                                                ),
                                                                                child: Text(
                                                                                  'Cancel'.tr,
                                                                                  style: Theme.of(context).textTheme.displaySmall!,
                                                                                ),
                                                                              ),
                                                                              TextButton(
                                                                                onPressed: () => Get.back(result: true),
                                                                                style: ButtonStyle(
                                                                                  backgroundColor: MaterialStateProperty.all(themeController.primaryColor.value),
                                                                                ),
                                                                                child: Text(
                                                                                  'Delete'.tr,
                                                                                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                                                                    color: themeController.secondaryTextColor.value,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );

                                                                  if (confirm == true) {
                                                                    
                                                                    await controller.deleteAlarms();

                                                                    // Closing the multiple select mode
                                                                    controller.inMultipleSelectMode.value = false;
                                                                    controller.isAnyAlarmHolded.value = false;
                                                                    controller.isAllAlarmsSelected.value = false;
                                                                    controller.numberOfAlarmsSelected.value = 0;
                                                                    controller.selectedAlarmSet.clear();
                                                                    
                                                                    
                                                                    controller.refreshTimer = true;
                                                                    controller.refreshUpcomingAlarms();
                                                                  }
                                                                }
                                                              },
                                                              child: Icon(
                                                                Icons.delete,
                                                                color: controller.numberOfAlarmsSelected.value > 0
                                                                    ? Colors.red
                                                                    : themeController.primaryTextColor.value.withOpacity(0.75),
                                                                size: 27 * controller.scalingFactor.value,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],

            body: RefreshIndicator(
              onRefresh: () async {
                refresh(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(bottom: controller.scalingFactor * 20),
                    child: const ProfileSelect(),
                  ),
                  Expanded(
                    child: GlowingOverscrollIndicator(
                      color: themeController.primaryDisabledTextColor.value,
                      axisDirection: AxisDirection.down,
                      child: Obx(() {
                        return FutureBuilder(
                          future: controller.isUserSignedIn.value
                              ? controller
                                  .initStream(controller.userModel.value)
                              : controller
                                  .initStream(controller.userModel.value),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              final Stream streamAlarms = snapshot.data;

                              return StreamBuilder(
                                stream: streamAlarms,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator.adaptive(
                                        backgroundColor: Colors.transparent,
                                        valueColor: AlwaysStoppedAnimation(
                                          themeController.primaryColor.value,
                                        ),
                                      ),
                                    );
                                  } else {
                                    List<AlarmModel> alarms = snapshot.data;

                                    alarms = alarms.toList();
                                    controller.refreshTimer = true;
                                    controller.refreshUpcomingAlarms();
                                    if (alarms.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/images/empty.svg',
                                              height: height * 0.3,
                                              width: width * 0.8,
                                            ),
                                            Text(
                                              'Add an alarm to get started!'.tr,
                                              textWidthBasis:
                                                  TextWidthBasis.longestLine,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    color: themeController.primaryDisabledTextColor.value,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return ListView(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16 * controller.scalingFactor.value,
                                        vertical: 8 * controller.scalingFactor.value,
                                      ),
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: themeController.secondaryBackgroundColor.value,
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            children: alarms.asMap().entries.map((entry) {
                                              int index = entry.key;
                                              AlarmModel alarm = entry.value;
                                              bool isLast = index == alarms.length - 1;
                                              
                                              if (alarm.profile != controller.selectedProfile.value) {
                                                return const SizedBox.shrink();
                                              }

                                              return Dismissible(
                                                key: ValueKey(alarm.isarId),
                                                direction: DismissDirection.endToStart,
                                                onDismissed: (direction) async {
                                                  bool userConfirmed = await showDeleteAlarmConfirmationPopupOnSwipe(context);
                                                  if (userConfirmed) {
                                                    await controller.swipeToDeleteAlarm(controller.userModel.value, alarm);
                                                  }
                                                  Get.offNamedUntil('/bottom-navigation-bar', (route) => route.settings.name == '/splash-screen');
                                                },
                                                background: Container(
                                                  color: Colors.red,
                                                  alignment: Alignment.centerRight,
                                                  padding: const EdgeInsets.only(right: 20),
                                                  child: const Icon(Icons.delete, color: Colors.white),
                                                ),
                                                child: AlarmListItem(
                                                  alarm: alarm,
                                                  index: index,
                                                  controller: controller,
                                                  themeController: themeController,
                                                  settingsController: settingsController,
                                                  isLast: isLast,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        SizedBox(height: height * 0.1),
                                      ],
                                    );
                                  }
                                },
                              );
                            } else {
                              return CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation(
                                  themeController.primaryColor.value,
                                ),
                              );
                            }
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Future<bool> showDeleteAlarmConfirmationPopupOnSwipe(
    BuildContext context,
  ) async {
    // Return true if user confirms deletion, false if canceled

    var result = await Get.defaultDialog(
      titlePadding: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      backgroundColor: themeController.secondaryBackgroundColor.value,
      title: 'Confirmation'.tr,
      titleStyle: Theme.of(context).textTheme.displaySmall,
      content: Column(
        children: [
          Text(
            'want to delete?'.tr,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          Padding(
            padding: const EdgeInsets.only(
              top: 20,

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Get.back(result: false);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      themeController.primaryTextColor.value.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    'Cancel'.tr,
                    style: Theme.of(context).textTheme.displaySmall!,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.back(result: true); // User confirmed
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(themeController.primaryColor.value),
                  ),
                  child: Text(
                    'delete'.tr,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: themeController.secondaryTextColor.value,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return result ??
        false; // Default to false if the user dismisses the dialog without tapping any button
  }

  void refresh(BuildContext context) async {
    controller.refresh();
    await Future.delayed(const Duration(seconds: 3));
  }
}
