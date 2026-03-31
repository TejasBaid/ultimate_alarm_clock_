import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/providers/secure_storage_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/home/views/home_view.dart';
import 'package:ultimate_alarm_clock/app/modules/stopwatch/views/stopwatch_view.dart';
import 'package:ultimate_alarm_clock/app/modules/timer/views/timer_view.dart';
import 'package:ultimate_alarm_clock/app/modules/worldClock/views/world_clock_view.dart';

class BottomNavigationBarController extends GetxController
    with WidgetsBindingObserver {
  RxInt activeTabIndex = 0.obs;
  RxBool hasloaded = false.obs;

  final _secureStorageProvider = SecureStorageProvider();

  PageController? _pageController;

  PageController get pageController {
    assert(
      _pageController != null,
      'pageController is only available after loadSavedState completes',
    );
    return _pageController!;
  }

  List<Widget> pages = [
    HomeView(),
    StopwatchView(),
    TimerView(),
    const WorldClockView(),
  ];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadSavedState();
  }

  @override
  void onClose() {
    _pageController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> loadSavedState() async {
    if (hasloaded.value) return;
    var value = await _secureStorageProvider.readTabIndex();
    if (value < 0 || value > pages.length - 1) {
      value = 0;
    }
    activeTabIndex.value = value;
    _pageController = PageController(initialPage: activeTabIndex.value);
    hasloaded.value = true;
  }

  void _saveState() async {
    await _secureStorageProvider.writeTabIndex(
      tabIndex: activeTabIndex.value,
    );
  }

  void changeTab(int index) {
    final i = index.clamp(0, pages.length - 1);
    activeTabIndex.value = i;
    _saveState();
  }

  void goToPage(int index) {
    final i = index.clamp(0, pages.length - 1);
    changeTab(i);
    if (_pageController?.hasClients ?? false) {
      _pageController!.jumpToPage(i);
    }
  }
}
