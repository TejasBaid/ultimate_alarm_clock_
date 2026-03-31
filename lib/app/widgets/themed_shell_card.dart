import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';

class ThemedShellCard extends StatelessWidget {
  const ThemedShellCard({
    super.key,
    required this.themeController,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 22),
    this.width,
    this.center = true,
    this.compact = false,
  });

  final ThemeController themeController;
  final Widget child;
  final EdgeInsetsGeometry padding;

  final double? width;

  final bool center;

  final bool compact;

  static const double _standardRadius = 22;
  static const double _compactRadius = 17;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final accent = themeController.primaryColor.value;
      final isLight = themeController.currentTheme.value == ThemeMode.light;
      final innerBg = themeController.secondaryBackgroundColor.value;
      final radius = compact ? _compactRadius : _standardRadius;
      final innerRadius = radius - 1.25;

      final outerGlow = accent.withOpacity(
        isLight
            ? (compact ? 0.085 : 0.14)
            : (compact ? 0.04 : 0.075),
      );

      final effectiveWidth =
          width ?? (compact ? Get.width - 20 : Get.width * 0.92);

      final shell = Container(
        width: effectiveWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: compact
              ? [
                  BoxShadow(
                    color: outerGlow,
                    blurRadius: isLight ? 12 : 8,
                    spreadRadius: -2,
                    offset: Offset(0, isLight ? 4 : 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(isLight ? 0.035 : 0.08),
                    blurRadius: isLight ? 10 : 6,
                    offset: Offset(0, isLight ? 5 : 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: outerGlow,
                    blurRadius: isLight ? 26 : 14,
                    spreadRadius: isLight ? -4 : -5,
                    offset: Offset(0, isLight ? 10 : 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(isLight ? 0.05 : 0.12),
                    blurRadius: isLight ? 22 : 10,
                    offset: Offset(0, isLight ? 12 : 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isLight
                          ? [
                              accent.withOpacity(compact ? 0.32 : 0.45),
                              accent.withOpacity(compact ? 0.04 : 0.06),
                              accent.withOpacity(compact ? 0.18 : 0.28),
                            ]
                          : [
                              accent.withOpacity(compact ? 0.12 : 0.2),
                              accent.withOpacity(compact ? 0.02 : 0.03),
                              accent.withOpacity(compact ? 0.07 : 0.11),
                            ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(1.25),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(innerRadius),
                    color: innerBg,
                    border: Border.all(
                      color: isLight
                          ? Colors.white.withOpacity(compact ? 0.55 : 0.7)
                          : Colors.white.withOpacity(0.07),
                    ),
                  ),
                  child: Padding(
                    padding: padding,
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (center) {
        return Center(child: shell);
      }
      return shell;
    });
  }
}
