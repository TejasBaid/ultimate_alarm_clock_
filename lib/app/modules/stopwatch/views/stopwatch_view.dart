import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/stopwatch/controllers/stopwatch_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/end_drawer.dart';
import '../../../utils/utils.dart';

// ignore: must_be_immutable
class StopwatchView extends GetView<StopwatchController> {
  StopwatchView({Key? key}) : super(key: key);
  ThemeController themeController = Get.find<ThemeController>();
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Obx(() => Scaffold(
        backgroundColor: themeController.primaryBackgroundColor.value,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(height / 7.9),
          child: AppBar(
            backgroundColor: themeController.primaryBackgroundColor.value,
            toolbarHeight: height / 7.9,
            elevation: 0.0,
            centerTitle: true,
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
                      // splashRadius: 0.000001,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: controller.hasFlags.value ? height * 0.05 : height * 0.15,
              ),
            ),
            Obx(
              () {
                var timeParts = controller.result.split(':');
                if (timeParts.length < 3) return const SizedBox();
                
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "${timeParts[0]}:${timeParts[1]}",
                        style: TextStyle(
                          fontSize: 85.0,
                          fontWeight: FontWeight.w200,
                          letterSpacing: 1.5,
                          color: themeController.primaryTextColor.value,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: Text(
                          ".${timeParts[2]}",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.w300,
                            color: themeController.primaryColor.value.withOpacity(0.8),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
            const SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Lap Button
                SizedBox(
                  height: 75,
                  width: 75,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(themeController.secondaryBackgroundColor.value),
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    onPressed: controller.addFlag,
                    child: Icon(
                      Icons.flag_outlined,
                      size: 28,
                      color: themeController.primaryTextColor.value,
                    ),
                  ),
                ),
                // Play/Pause Button
                SizedBox(
                  height: 90,
                  width: 90,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(themeController.primaryColor.value.withOpacity(0.15)),
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    onPressed: controller.toggleTimer,
                    child: Obx(
                      () => Icon(
                        controller.isTimerPaused.value
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 40,
                        color: themeController.primaryColor.value,
                      ),
                    ),
                  ),
                ),
                // Stop/Reset Button
                SizedBox(
                  height: 75,
                  width: 75,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(themeController.secondaryBackgroundColor.value),
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    onPressed: controller.resetTime,
                    child: Icon(
                      Icons.stop_rounded,
                      size: 28,
                      color: themeController.primaryTextColor.value,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40.0),
            Expanded(
              child: Obx(
                () => AnimatedList(
                  key: controller.listKey,
                  initialItemCount: controller.flags.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index, animation) {
                    final reversedIndex = controller.flags.length - 1 - index;
                    return SlideTransition(
                      position: animation.drive(
                        Tween<Offset>(
                          begin: const Offset(0, -0.3),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeInOut)),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(bottom: BorderSide(color: themeController.primaryTextColor.value.withOpacity(0.1))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lap ${controller.flags[reversedIndex].number}',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w300,
                                color: themeController.primaryTextColor.value.withOpacity(0.7),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "+${DateFormat('mm:ss:SS').format(
                                    DateTime(0).add(controller.flags[reversedIndex].lapTime),
                                  )}",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w300,
                                    color: themeController.primaryColor.value,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    DateFormat('mm:ss:SS').format(
                                      DateTime(0).add(controller.flags[reversedIndex].totalTime),
                                    ),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w400,
                                      color: themeController.primaryTextColor.value,
                                      letterSpacing: 1.0,
                                      fontFeatures: const [FontFeature.tabularFigures()],
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
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
          ],
        ),
        endDrawer: buildEndDrawer(context)));
  }
}
