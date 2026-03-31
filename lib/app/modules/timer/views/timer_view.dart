// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ultimate_alarm_clock/app/data/providers/isar_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/timer/controllers/timer_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/timer/views/timer_animation.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/end_drawer.dart';
import 'package:ultimate_alarm_clock/app/utils/hover_preset_button.dart';
import 'package:ultimate_alarm_clock/app/utils/preset_button.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/views/custom_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:ultimate_alarm_clock/app/data/models/timer_model.dart';

class TimerView extends GetView<TimerController> {
  TimerView({Key? key}) : super(key: key);
  final GlobalKey dialogKey = GlobalKey();
  final ThemeController themeController = Get.find<ThemeController>();
  // var width = Get.width;
  // var height = Get.height;
  
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Obx(() => Scaffold(
      backgroundColor: themeController.primaryBackgroundColor.value,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height / 8.9),
        child: AppBar(
          backgroundColor: themeController.primaryBackgroundColor.value,
          toolbarHeight: height / 7.9,
          elevation: 0.0,
          title: Obx(
            () => Text(
              'Timer',
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    color: themeController.primaryTextColor.value.withOpacity(
                      0.75,
                    ),
                    fontSize: 26,
                  ),
            ),
          ),
          actions: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Obx(
                  () => IconButton(
                    onPressed: () {
                      Utils.hapticFeedback();
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: Icon(
                      Icons.menu,
                    ),
                    color: themeController.primaryTextColor.value
                        .withOpacity(0.75),
                    iconSize: 27,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: controller.timerList.isNotEmpty ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: controller.timerList.isNotEmpty ? 1.0 : 0.0,
            child: FloatingActionButton.extended(
              onPressed: () {
                Utils.hapticFeedback();
                showSleekTimerSelector(context, width, height);
              },
              backgroundColor: themeController.primaryColor.value,
              elevation: 8,
              icon: Icon(
                Icons.add_rounded,
                color: themeController.secondaryTextColor.value,
                size: 26,
              ),
              label: Text(
                "New Timer",
                style: TextStyle(
                  color: themeController.secondaryTextColor.value,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final hasTimers = controller.timerList.isNotEmpty;

        return Column(
          children: [
            Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildSleekPreset(context, '+ 1 Min', const Duration(minutes: 1)),
                      const SizedBox(width: 10),
                      _buildSleekPreset(context, '+ 5 Min', const Duration(minutes: 5)),
                      const SizedBox(width: 10),
                      _buildSleekPreset(context, '+ 10 Min', const Duration(minutes: 10)),
                      const SizedBox(width: 10),
                      _buildSleekPreset(context, '+ 15 Min', const Duration(minutes: 15)),
                    ],
                  ),
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                return controller.timerList.isNotEmpty
                    ? StreamBuilder<List<TimerModel>>(
                        stream: IsarDb.getTimers(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(themeController.primaryColor.value),
                              ),
                            );
                          } else {
                            List<TimerModel> timers = snapshot.data!;
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              controller: controller.scrollController,
                              padding: const EdgeInsets.only(bottom: 120),
                              itemCount: timers.length,
                              itemBuilder: (BuildContext context, int index) {
                                return TimerAnimatedCard(
                                  key: ValueKey(timers[index].timerId),
                                  index: index,
                                  timer: timers[index],
                                );
                              },
                            );
                          }
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              size: 100,
                              color: themeController.primaryTextColor.value.withOpacity(0.05),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "No active timers",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                color: themeController.primaryTextColor.value.withOpacity(0.5),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeController.primaryColor.value,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                                shadowColor: themeController.primaryColor.value.withOpacity(0.4),
                              ),
                              onPressed: () {
                                Utils.hapticFeedback();
                                showSleekTimerSelector(context, width, height);
                              },
                              icon: Icon(
                                Icons.add_rounded,
                                color: themeController.secondaryTextColor.value,
                              ),
                              label: Text(
                                "Start a Timer",
                                style: TextStyle(
                                  color: themeController.secondaryTextColor.value,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
              }),
            ),
          ],
        );
      }),
      endDrawer: buildEndDrawer(context),
    ));
  }

  Widget _buildSleekPreset(BuildContext context, String label, Duration duration) {
    return InkWell(
      onTap: () {
        Utils.hapticFeedback();
        controller.remainingTime.value = duration;
        controller.createTimer();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: themeController.secondaryBackgroundColor.value.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: themeController.primaryTextColor.value.withOpacity(0.05)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: themeController.primaryTextColor.value.withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void showSleekTimerSelector(BuildContext context, double width, double height) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: themeController.primaryBackgroundColor.value,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 15,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: themeController.primaryTextColor.value.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              Container(
                height: 180,
                width: width * 0.85,
                decoration: BoxDecoration(
                  color: themeController.secondaryBackgroundColor.value,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: themeController.secondaryTextColor.value.withOpacity(0.05)),
                ),
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        color: themeController.primaryTextColor.value,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hms,
                    initialTimerDuration: Duration(
                      hours: controller.hours.value,
                      minutes: controller.minutes.value,
                      seconds: controller.seconds.value,
                    ),
                    onTimerDurationChanged: (Duration changedTimer) {
                      Utils.hapticFeedback();
                      controller.hours.value = changedTimer.inHours;
                      controller.minutes.value = changedTimer.inMinutes.remainder(60);
                      controller.seconds.value = changedTimer.inSeconds.remainder(60);
                      controller.setTextFieldTimerTime();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: width * 0.85,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeController.primaryColor.value,
                    elevation: 4,
                    shadowColor: themeController.primaryColor.value.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Utils.hapticFeedback();
                    controller.remainingTime.value = Duration(
                      hours: controller.hours.value,
                      minutes: controller.minutes.value,
                      seconds: controller.seconds.value,
                    );
                    if (controller.hours.value != 0 ||
                        controller.minutes.value != 0 ||
                        controller.seconds.value != 0) {
                      controller.createTimer();
                    }
                    // Reset to default
                    controller.hours.value = 0;
                    controller.minutes.value = 1;
                    controller.seconds.value = 0;
                    controller.setTextFieldTimerTime();

                    Get.back();
                  },
                  child: Text(
                    'Start Timer',
                    style: TextStyle(
                      color: themeController.secondaryTextColor.value,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void timerSelector(BuildContext context, double width, double height) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: themeController.primaryBackgroundColor.value,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 15,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: themeController.primaryTextColor.value.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 20),
                        const SizedBox(width: 10),
                        Obx(
                          () => Text(
                            'Add timer',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  color: themeController.primaryTextColor.value
                                      .withOpacity(0.7),
                                  fontSize: 15,
                                ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            controller.changeTimePickerTimer();
                          },
                          child: Obx(
                            () => Icon(
                              Icons.keyboard,
                              color: themeController.primaryTextColor.value
                                  .withOpacity(0.7),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Utils.hapticFeedback();
                      },
                      child: Obx(
                        () => Container(
                          color: themeController.primaryBackgroundColor.value,
                          width: width,
                          child: controller.isTimePickerTimer.value
                              ? _buildAdaptiveTimerPicker(context, width, height, themeController)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Hours',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: themeController
                                                    .primaryDisabledTextColor
                                                    .value,
                                              ),
                                        ),
                                        SizedBox(
                                          height: height * 0.008,
                                        ),
                                        SizedBox(
                                          width: width * 0.18,
                                          child: TextField(
                                            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                              color: themeController.primaryTextColor.value,
                                            ),
                                            cursorColor: themeController.primaryColor.value,
                                            onChanged: (_) {
                                              controller.setTimerTime();
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'HH',
                                              hintStyle: Theme.of(context).textTheme.displayLarge!.copyWith(
                                                color: themeController.primaryTextColor.value.withOpacity(0.5),
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            textAlign: TextAlign.center,
                                            controller: controller.inputHoursControllerTimer,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(
                                                  r'[0-9]',
                                                ),
                                              ),
                                              LengthLimitingTextInputFormatter(
                                                2,
                                              ),
                                              LimitRange(
                                                0,
                                                99,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.02,
                                        right: width * 0.02,
                                        top: height * 0.035,
                                      ),
                                      child: Text(
                                        ':',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: themeController
                                                  .primaryDisabledTextColor
                                                  .value,
                                            ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Minutes',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: themeController
                                                    .primaryDisabledTextColor
                                                    .value,
                                              ),
                                        ),
                                        SizedBox(
                                          height: height * 0.008,
                                        ),
                                        SizedBox(
                                          width: width * 0.18,
                                          child: TextField(
                                            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                              color: themeController.primaryTextColor.value,
                                            ),
                                            cursorColor: themeController.primaryColor.value,
                                            onChanged: (_) {
                                              controller.setTimerTime();
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'MM',
                                              hintStyle: Theme.of(context).textTheme.displayLarge!.copyWith(
                                                color: themeController.primaryTextColor.value.withOpacity(0.5),
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            textAlign: TextAlign.center,
                                            controller: controller.inputMinutesControllerTimer,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(
                                                  r'[0-9]',
                                                ),
                                              ),
                                              LengthLimitingTextInputFormatter(
                                                2,
                                              ),
                                              LimitRange(
                                                0,
                                                59,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.02,
                                        right: width * 0.02,
                                        top: height * 0.035,
                                      ),
                                      child: Text(
                                        ':',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: themeController
                                                  .primaryDisabledTextColor
                                                  .value,
                                            ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Sec',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: themeController
                                                    .primaryDisabledTextColor
                                                    .value,
                                              ),
                                        ),
                                        SizedBox(
                                          height: height * 0.008,
                                        ),
                                        SizedBox(
                                          width: width * 0.18,
                                          child: TextField(
                                            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                              color: themeController.primaryTextColor.value,
                                            ),
                                            cursorColor: themeController.primaryColor.value,
                                            onChanged: (_) {
                                              controller.setTimerTime();
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'SS',
                                              hintStyle: Theme.of(context).textTheme.displayLarge!.copyWith(
                                                color: themeController.primaryTextColor.value.withOpacity(0.5),
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            textAlign: TextAlign.center,
                                            controller: controller.inputSecondsControllerTimer,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(
                                                  r'[0-9]',
                                                ),
                                              ),
                                              LengthLimitingTextInputFormatter(
                                                2,
                                              ),
                                              LimitRange(
                                                0,
                                                59,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20.00, 20.00, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                Get.back();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Obx(
                                  () => Text(
                                    'Cancel',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                          color: themeController
                                              .primaryTextColor.value
                                              .withOpacity(0.5),
                                          fontSize: 15,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                controller.remainingTime.value = Duration(
                                  hours: controller.hours.value,
                                  minutes: controller.minutes.value,
                                  seconds: controller.seconds.value,
                                );
                                if (controller.hours.value != 0 ||
                                    controller.minutes.value != 0 ||
                                    controller.seconds.value != 0) {
                                  controller.createTimer();
                                }
                                controller.hours.value = 0;
                                controller.minutes.value = 1;
                                controller.seconds.value = 0;
                                controller.setTextFieldTimerTime();

                                Get.back();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Obx(
                                  () => Text(
                                    'OK',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                          color: themeController
                                              .primaryTextColor.value
                                              .withOpacity(0.5),
                                          fontSize: 15,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildAdaptiveTimerPicker(BuildContext context, double width, double height, ThemeController themeController) {
    // Check if font scaling is too high for NumberPicker
    final systemScale = MediaQuery.textScaleFactorOf(context);
    final combinedScale = systemScale;
    final useCustomPicker = combinedScale > 1.5;

    if (useCustomPicker) {
      // Use simplified custom picker for timer
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimerUnitColumn(
              context: context,
              label: 'Hours',
              value: controller.hours.value,
              minValue: 0,
              maxValue: 99,
              onChanged: (value) {
                Utils.hapticFeedback();
                controller.hours.value = value;
                controller.setTextFieldTimerTime();
              },
              width: width,
              themeController: themeController,
              systemScale: systemScale,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: (24 * systemScale).clamp(20.0, 40.0),
                  fontWeight: FontWeight.bold,
                  color: themeController.primaryDisabledTextColor.value,
                ),
              ),
            ),
            _buildTimerUnitColumn(
              context: context,
              label: 'Minutes',
              value: controller.minutes.value,
              minValue: 0,
              maxValue: 59,
              onChanged: (value) {
                Utils.hapticFeedback();
                controller.minutes.value = value;
                controller.setTextFieldTimerTime();
              },
              width: width,
              themeController: themeController,
              systemScale: systemScale,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: (24 * systemScale).clamp(20.0, 40.0),
                  fontWeight: FontWeight.bold,
                  color: themeController.primaryDisabledTextColor.value,
                ),
              ),
            ),
            _buildTimerUnitColumn(
              context: context,
              label: 'Seconds',
              value: controller.seconds.value,
              minValue: 0,
              maxValue: 59,
              onChanged: (value) {
                Utils.hapticFeedback();
                controller.seconds.value = value;
                controller.setTextFieldTimerTime();
              },
              width: width,
              themeController: themeController,
              systemScale: systemScale,
            ),
          ],
        ),
      );
    } else {
      // Use enhanced NumberPicker for normal scaling
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hours Picker
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hours',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeController.primaryDisabledTextColor.value,
                  ),
                ),
                SizedBox(height: height * 0.008),
                NumberPicker(
                  minValue: 0,
                  maxValue: 99,
                  value: controller.hours.value,
                  onChanged: (value) {
                    Utils.hapticFeedback();
                    controller.hours.value = value;
                    controller.setTextFieldTimerTime();
                  },
                  infiniteLoop: true,
                  itemWidth: Utils.getResponsiveNumberPickerItemWidth(
                    context,
                    screenWidth: width,
                    baseWidthFactor: 0.15,
                  ),
                  itemHeight: Utils.getResponsiveNumberPickerItemHeight(
                    context,
                    baseFontSize: 30,
                  ),
                  zeroPad: true,
                  selectedTextStyle: Utils.getResponsiveNumberPickerSelectedTextStyle(
                    context,
                    baseFontSize: 30,
                    color: Get.find<ThemeController>().primaryColor.value,
                  ),
                  textStyle: Utils.getResponsiveNumberPickerTextStyle(
                    context,
                    baseFontSize: 18,
                    color: themeController.primaryDisabledTextColor.value,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: width * 0.005,
                        color: themeController.primaryDisabledTextColor.value,
                      ),
                      bottom: BorderSide(
                        width: width * 0.005,
                        color: themeController.primaryDisabledTextColor.value,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Colon separator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
              child: Text(
                ':',
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeController.primaryDisabledTextColor.value,
                ),
              ),
            ),
            // Minutes Picker
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Minutes',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeController.primaryDisabledTextColor.value,
                  ),
                ),
                SizedBox(height: height * 0.008),
                NumberPicker(
                  minValue: 0,
                  maxValue: 59,
                  value: controller.minutes.value,
                  onChanged: (value) {
                    Utils.hapticFeedback();
                    controller.minutes.value = value;
                    controller.setTextFieldTimerTime();
                  },
                  infiniteLoop: true,
                  itemWidth: Utils.getResponsiveNumberPickerItemWidth(
                    context,
                    screenWidth: width,
                    baseWidthFactor: 0.15,
                  ),
                  itemHeight: Utils.getResponsiveNumberPickerItemHeight(
                    context,
                    baseFontSize: 30,
                  ),
                  zeroPad: true,
                  selectedTextStyle: Utils.getResponsiveNumberPickerSelectedTextStyle(
                    context,
                    baseFontSize: 30,
                    color: Get.find<ThemeController>().primaryColor.value,
                  ),
                  textStyle: Utils.getResponsiveNumberPickerTextStyle(
                    context,
                    baseFontSize: 18,
                    color: themeController.primaryDisabledTextColor.value,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: width * 0.005,
                        color: themeController.primaryDisabledTextColor.value,
                      ),
                      bottom: BorderSide(
                        width: width * 0.005,
                        color: themeController.primaryDisabledTextColor.value,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Colon separator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
              child: Text(
                ':',
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeController.primaryDisabledTextColor.value,
                ),
              ),
            ),
            // Seconds Picker
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Seconds',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeController.primaryDisabledTextColor.value,
                  ),
                ),
                SizedBox(height: height * 0.008),
                NumberPicker(
                  minValue: 0,
                  maxValue: 59,
                  value: controller.seconds.value,
                  onChanged: (value) {
                    Utils.hapticFeedback();
                    controller.seconds.value = value;
                    controller.setTextFieldTimerTime();
                  },
                  infiniteLoop: true,
                  itemWidth: Utils.getResponsiveNumberPickerItemWidth(
                    context,
                    screenWidth: width,
                    baseWidthFactor: 0.15,
                  ),
                  itemHeight: Utils.getResponsiveNumberPickerItemHeight(
                    context,
                    baseFontSize: 30,
                  ),
                  zeroPad: true,
                  selectedTextStyle: Utils.getResponsiveNumberPickerSelectedTextStyle(
                    context,
                    baseFontSize: 30,
                    color: Get.find<ThemeController>().primaryColor.value,
                  ),
                  textStyle: Utils.getResponsiveNumberPickerTextStyle(
                    context,
                    baseFontSize: 18,
                    color: themeController.primaryDisabledTextColor.value,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: width * 0.005,
                        color: themeController.primaryDisabledTextColor.value,
                      ),
                      bottom: BorderSide(
                        width: width * 0.005,
                        color: themeController.primaryDisabledTextColor.value,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTimerUnitColumn({
    required BuildContext context,
    required String label,
    required int value,
    required int minValue,
    required int maxValue,
    required Function(int) onChanged,
    required double width,
    required ThemeController themeController,
    required double systemScale,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: (14 * systemScale).clamp(12.0, 24.0),
            fontWeight: FontWeight.bold,
            color: themeController.primaryDisabledTextColor.value,
          ),
        ),
        SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.2,
          ),
          width: (width * 0.18).clamp(70.0, 100.0),
          decoration: BoxDecoration(
            color: Get.find<ThemeController>().primaryColor.value.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Get.find<ThemeController>().primaryColor.value.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Plus button
              InkWell(
                onTap: () {
                  Utils.hapticFeedback();
                  int newValue = value + 1;
                  if (newValue > maxValue) newValue = minValue;
                  onChanged(newValue);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all((8 * systemScale).clamp(6.0, 12.0)),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: Get.find<ThemeController>().primaryColor.value,
                    size: (20 * systemScale).clamp(16.0, 28.0),
                  ),
                ),
              ),
              // Current value display
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: (4 * systemScale).clamp(2.0, 8.0),
                    horizontal: 4,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: (20 * systemScale).clamp(16.0, 32.0),
                        fontWeight: FontWeight.bold,
                        color: Get.find<ThemeController>().primaryColor.value,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              // Minus button

              InkWell(
                onTap: () {
                  Utils.hapticFeedback();
                  int newValue = value - 1;
                  if (newValue < minValue) newValue = maxValue;
                  onChanged(newValue);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all((8 * systemScale).clamp(6.0, 12.0)),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Get.find<ThemeController>().primaryColor.value,
                    size: (20 * systemScale).clamp(16.0, 28.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
