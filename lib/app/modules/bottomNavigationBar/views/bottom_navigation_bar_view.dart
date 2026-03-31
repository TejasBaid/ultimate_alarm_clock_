import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/bottomNavigationBar/controllers/bottom_navigation_bar_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class BottomNavigationBarView extends GetView<BottomNavigationBarController> {
  BottomNavigationBarView({super.key});

  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Obx(() => Scaffold(
      backgroundColor: themeController.primaryBackgroundColor.value,
      body: Obx(() {
        if (!controller.hasloaded.value) {
          return Center(
            child: CircularProgressIndicator.adaptive(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                themeController.primaryColor.value,
              ),
            ),
          );
        }
        return PageView(
          controller: controller.pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: controller.changeTab,
          children: controller.pages,
        );
      }),
      bottomNavigationBar: Obx(() {
        if (!controller.hasloaded.value) {
          return SizedBox(height: kBottomNavigationBarHeight + bottomInset);
        }

        final accent = themeController.primaryColor.value;
        final bgColor = themeController.primaryBackgroundColor.value;
        final surface = themeController.secondaryBackgroundColor.value;
        final unselected =
            themeController.primaryTextColor.value.withOpacity(0.42);
        final activeIndex = controller.activeTabIndex.value;

        return Material(
          color: bgColor,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: _NavDestination(
                      selected: activeIndex == 0,
                      accent: accent,
                      muted: unselected,
                      icon: Icons.alarm_outlined,
                      selectedIcon: Icons.alarm_rounded,
                      label: 'Alarm'.tr,
                      onTap: () {
                        Utils.hapticFeedback();
                        controller.goToPage(0);
                      },
                    ),
                  ),
                  Expanded(
                    child: _NavDestination(
                      selected: activeIndex == 1,
                      accent: accent,
                      muted: unselected,
                      icon: Icons.av_timer_outlined,
                      selectedIcon: Icons.av_timer_rounded,
                      label: 'StopWatch'.tr,
                      onTap: () {
                        Utils.hapticFeedback();
                        controller.goToPage(1);
                      },
                    ),
                  ),
                  Expanded(
                    child: _NavDestination(
                      selected: activeIndex == 2,
                      accent: accent,
                      muted: unselected,
                      icon: Icons.hourglass_empty_rounded,
                      selectedIcon: Icons.hourglass_bottom_rounded,
                      label: 'Timer'.tr,
                      onTap: () {
                        Utils.hapticFeedback();
                        controller.goToPage(2);
                      },
                    ),
                  ),
                  Expanded(
                    child: _NavDestination(
                      selected: activeIndex == 3,
                      accent: accent,
                      muted: unselected,
                      icon: Icons.public_outlined,
                      selectedIcon: Icons.public_rounded,
                      label: 'World'.tr,
                      onTap: () {
                        Utils.hapticFeedback();
                        controller.goToPage(3);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ));
  }
}

class _NavDestination extends StatelessWidget {
  const _NavDestination({
    required this.selected,
    required this.accent,
    required this.muted,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final Color accent;
  final Color muted;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: accent.withOpacity(0.12),
          highlightColor: accent.withOpacity(0.06),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            decoration: const BoxDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    selected ? selectedIcon : icon,
                    key: ValueKey<bool>(selected),
                    color: selected ? accent : muted,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.1,
                    color: selected ? accent : muted,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
