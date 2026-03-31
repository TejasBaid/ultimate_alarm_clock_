import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/models/timer_model.dart';
import 'package:ultimate_alarm_clock/app/data/providers/isar_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/timer/controllers/timer_controller.dart';

import '../../../utils/utils.dart';
import '../../settings/controllers/theme_controller.dart';

class TimerAnimatedCard extends StatefulWidget {
  final TimerModel timer;
  final int index;

  const TimerAnimatedCard({
    super.key,
    required this.index,
    required this.timer,
  });
  @override
  _TimerAnimatedCardState createState() => _TimerAnimatedCardState();
}

class _TimerAnimatedCardState extends State<TimerAnimatedCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TimerController controller = Get.find<TimerController>();
  ThemeController themeController = Get.find<ThemeController>();
  var width = Get.width;
  var height = Get.height;

  Timer? _timerCounter;
  void startTimer() {
    _timerCounter = Timer.periodic(Duration(seconds: 1), (timer) {
      print('${widget.timer.timerName}');
      if (widget.timer.timeElapsed < widget.timer.timerValue) {
        setState(() {
          widget.timer.timeElapsed += 1000;
          IsarDb.updateTimerTick(widget.timer);
        });
      } else {
        stopTimer();
        controller.startRinger(widget.timer.timerId);
      }
    });
  }

  void stopTimer() {
    _timerCounter!.cancel();
  }

  @override
  void initState() {
    super.initState();
    if (Utils.getDifferenceMillisFromNow(
                widget.timer.startedOn, widget.timer.timerValue) <=
            0 &&
        widget.timer.isPaused == 0) {
      widget.timer.isPaused = 1;
      widget.timer.timeElapsed = 0;
      IsarDb.updateTimerPauseStatus(widget.timer);
    } else if (Utils.getDifferenceMillisFromNow(
                widget.timer.startedOn, widget.timer.timerValue) <
            widget.timer.timerValue &&
        widget.timer.isPaused == 0) {
      widget.timer.timeElapsed = widget.timer.timerValue - Utils.getDifferenceMillisFromNow(
          widget.timer.startedOn, widget.timer.timerValue);
      IsarDb.updateTimerPauseStatus(widget.timer);
    }
    if (widget.timer.isPaused == 0) {
      startTimer();
    }
  }

  @override
  void dispose() {
    _timerCounter?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: context.width,
        decoration: BoxDecoration(
          color: themeController.primaryBackgroundColor.value,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.timer.isPaused == 0 
                ? themeController.primaryColor.value.withOpacity(0.4)
                : themeController.primaryTextColor.value.withOpacity(0.05),
            width: widget.timer.isPaused == 0 ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (widget.timer.isPaused == 0)
              BoxShadow(
                color: themeController.primaryColor.value.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 64,
                      width: 64,
                      child: CircularProgressIndicator(
                        value: widget.timer.timeElapsed / widget.timer.timerValue,
                        strokeWidth: 3.0,
                        backgroundColor: themeController.primaryTextColor.value.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(themeController.primaryColor.value),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (widget.timer.isPaused == 0) {
                            stopTimer();
                          } else {
                            startTimer();
                          }
                          widget.timer.isPaused =
                              widget.timer.isPaused == 0 ? 1 : 0;
                          IsarDb.updateTimerPauseStatus(widget.timer);
                        });
                        if (widget.timer.timeElapsed >=
                            widget.timer.timerValue) {
                          controller.stopRinger(widget.timer.timerId);
                          setState(() {
                            widget.timer.timeElapsed = 0;
                            IsarDb.updateTimerTick(widget.timer)
                                .then((value) =>
                                    IsarDb.updateTimerPauseStatus(
                                        widget.timer));
                            widget.timer.isPaused = 1;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.timer.isPaused == 0 
                              ? themeController.primaryColor.value.withOpacity(0.15)
                              : themeController.primaryColor.value,
                          shape: BoxShape.circle,
                          boxShadow: widget.timer.isPaused == 1 ? [
                            BoxShadow(
                              color: themeController.primaryColor.value.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ] : [],
                        ),
                        width: 48,
                        height: 48,
                        child: Icon(
                          widget.timer.isPaused == 0
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 26,
                          color: widget.timer.isPaused == 0
                              ? themeController.primaryColor.value
                              : themeController.secondaryTextColor.value,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => Text(
                          '${Utils.formatMilliseconds(widget.timer.timerValue - widget.timer.timeElapsed)}',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                color: themeController.primaryTextColor.value,
                                fontSize: 40,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.0,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                        ),
                      ),
                      if (widget.timer.timerName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.timer.timerName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            color: themeController.primaryTextColor.value.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      splashRadius: 20,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          if (_timerCounter != null &&
                              widget.timer.isPaused == 0) {
                            stopTimer();
                          }
                          widget.timer.timeElapsed = 0;
                          IsarDb.updateTimerTick(widget.timer);
                          if (_timerCounter != null &&
                              widget.timer.isPaused == 0) {
                            widget.timer.startedOn =
                                DateTime.now().toString();
                            IsarDb.updateTimerTick(widget.timer)
                                .then((value) => startTimer());
                          }
                        });
                      },
                      icon: Icon(
                        Icons.refresh_rounded,
                        size: 22,
                        color: themeController.primaryTextColor.value.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    IconButton(
                      splashRadius: 20,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        controller.stopRinger(widget.timer.timerId);
                        controller.deleteTimer(widget.timer.timerId);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: themeController.primaryTextColor.value.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  bool get wantKeepAlive => true;
}
