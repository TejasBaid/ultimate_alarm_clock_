import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/providers/secure_storage_provider.dart';
import 'package:ultimate_alarm_clock/app/utils/app_theme_sets.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

class ThemeController extends GetxController {
  final _secureStorageProvider = SecureStorageProvider();

  @override
  void onInit() {
    _loadThemeValue();
    _loadColorThemeValue();
    updateThemeColors();
    super.onInit();
  }

  Rx<ThemeMode> currentTheme = ThemeMode.system.obs;
  RxInt colorThemeIndex = 0.obs;

  void switchTheme() {
    currentTheme.value = currentTheme.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    updateThemeColors();
  }

  Rx<Color> primaryColor = kprimaryColor.obs;
  Rx<Color> secondaryColor = kLightSecondaryColor.obs;
  Rx<Color> primaryBackgroundColor = kLightPrimaryBackgroundColor.obs;
  Rx<Color> secondaryBackgroundColor = kLightSecondaryBackgroundColor.obs;
  Rx<Color> primaryTextColor = kLightPrimaryTextColor.obs;
  Rx<Color> secondaryTextColor = kLightSecondaryTextColor.obs;
  Rx<Color> primaryDisabledTextColor = kLightPrimaryDisabledTextColor.obs;

  void updateThemeColors() {
    var index = colorThemeIndex.value;
    if (index < 0 || index >= kAppThemeSets.length) index = 0;

    final set = kAppThemeSets[index];
    final isLight = currentTheme.value == ThemeMode.light;
    final surface = isLight ? set.light : set.dark;

    primaryColor.value = set.accent;
    secondaryColor.value = surface.secondaryAccent;
    primaryBackgroundColor.value = surface.primaryBackground;
    secondaryBackgroundColor.value = surface.secondaryBackground;
    primaryTextColor.value = surface.primaryText;
    secondaryTextColor.value = surface.secondaryText;
    primaryDisabledTextColor.value = surface.primaryDisabledText;
  }

  void _loadThemeValue() async {
    currentTheme.value =
        await _secureStorageProvider.readThemeValue() == AppTheme.light
            ? ThemeMode.light
            : ThemeMode.dark;
    updateThemeColors();
    Get.changeThemeMode(currentTheme.value);
  }

  void _saveThemeValuePreference() async {
    await _secureStorageProvider.writeThemeValue(
      theme: currentTheme.value == ThemeMode.light
          ? AppTheme.light
          : AppTheme.dark,
    );
  }

  void toggleThemeValue(bool enabled) {
    currentTheme.value = enabled ? ThemeMode.light : ThemeMode.dark;
    updateThemeColors();
    _saveThemeValuePreference();
  }

  void _loadColorThemeValue() async {
    String val = await _secureStorageProvider.readColorThemeIndex() ?? '0';
    colorThemeIndex.value = int.tryParse(val) ?? 0;
    updateThemeColors();
  }

  void setColorTheme(int index) async {
    colorThemeIndex.value = index;
    updateThemeColors();
    await _secureStorageProvider.writeColorThemeIndex(index: index);
  }
}
