import 'package:flutter/material.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

@immutable
class ThemeSurface {
  const ThemeSurface({
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.primaryDisabledText,
    required this.secondaryAccent,
  });

  final Color primaryBackground;
  final Color secondaryBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color primaryDisabledText;
  final Color secondaryAccent;
}

@immutable
class AppThemeSet {
  const AppThemeSet({
    required this.accent,
    required this.light,
    required this.dark,
  });

  final Color accent;
  final ThemeSurface light;
  final ThemeSurface dark;
}

const List<String> kThemeSetNames = [
  'Neon',
  'Pink',
  'Cyan',
  'Purple',
  'Orange',
  'Acid',
  'Rose',
];

const List<AppThemeSet> kAppThemeSets = [
  // 0 — Neon (original app defaults)
  AppThemeSet(
    accent: Color(0xffAFFC41),
    light: ThemeSurface(
      primaryBackground: kLightPrimaryBackgroundColor,
      secondaryBackground: kLightSecondaryBackgroundColor,
      primaryText: kLightPrimaryTextColor,
      secondaryText: kLightSecondaryTextColor,
      primaryDisabledText: kLightPrimaryDisabledTextColor,
      secondaryAccent: Color(0xff6FBC00),
    ),
    dark: ThemeSurface(
      primaryBackground: kprimaryBackgroundColor,
      secondaryBackground: ksecondaryBackgroundColor,
      primaryText: kprimaryTextColor,
      secondaryText: ksecondaryTextColor,
      primaryDisabledText: kprimaryDisabledTextColor,
      secondaryAccent: Color(0xffB8E9C4),
    ),
  ),
  // 1 — Pink noir
  AppThemeSet(
    accent: Color(0xffFF3366),
    light: ThemeSurface(
      primaryBackground: Color(0xffFFF7F9),
      secondaryBackground: Color(0xffFFEDF2),
      primaryText: Color(0xff3D2430),
      secondaryText: Color(0xff1A1A1A),
      primaryDisabledText: Color(0xffB5929E),
      secondaryAccent: Color(0xffD81B60),
    ),
    dark: ThemeSurface(
      primaryBackground: Color(0xff160F14),
      secondaryBackground: Color(0xff22151C),
      primaryText: Color(0xffFCE8EF),
      secondaryText: Colors.black,
      primaryDisabledText: Color(0xff7D5F6C),
      secondaryAccent: Color(0xffFF80AB),
    ),
  ),
  // 2 — Cyan terminal
  AppThemeSet(
    accent: Color(0xff00E5FF),
    light: ThemeSurface(
      primaryBackground: Color(0xffF4FAFC),
      secondaryBackground: Color(0xffE6F4F8),
      primaryText: Color(0xff243238),
      secondaryText: Color(0xff101820),
      primaryDisabledText: Color(0xff8DA3AD),
      secondaryAccent: Color(0xff00B8D4),
    ),
    dark: ThemeSurface(
      primaryBackground: Color(0xff0C1216),
      secondaryBackground: Color(0xff121B22),
      primaryText: Color(0xffE3F8FF),
      secondaryText: Colors.black,
      primaryDisabledText: Color(0xff5C7582),
      secondaryAccent: Color(0xff84FFFF),
    ),
  ),
  // 3 — Purple void
  AppThemeSet(
    accent: Color(0xffB388FF),
    light: ThemeSurface(
      primaryBackground: Color(0xffF8F5FC),
      secondaryBackground: Color(0xffEEEAFA),
      primaryText: Color(0xff2E2640),
      secondaryText: Color(0xff1A1424),
      primaryDisabledText: Color(0xff9B91B5),
      secondaryAccent: Color(0xff6200EA),
    ),
    dark: ThemeSurface(
      primaryBackground: Color(0xff120F18),
      secondaryBackground: Color(0xff1A1628),
      primaryText: Color(0xffEFE8FF),
      secondaryText: Colors.black,
      primaryDisabledText: Color(0xff6E6588),
      secondaryAccent: Color(0xffEA80FC),
    ),
  ),
  // 4 — Ember
  AppThemeSet(
    accent: Color(0xffFF9100),
    light: ThemeSurface(
      primaryBackground: Color(0xffFFFAF5),
      secondaryBackground: Color(0xffFFF0E3),
      primaryText: Color(0xff3A2A22),
      secondaryText: Color(0xff1C140E),
      primaryDisabledText: Color(0xffB89A88),
      secondaryAccent: Color(0xffE65100),
    ),
    dark: ThemeSurface(
      primaryBackground: Color(0xff15110E),
      secondaryBackground: Color(0xff1E1814),
      primaryText: Color(0xffFFECDD),
      secondaryText: Colors.black,
      primaryDisabledText: Color(0xff8A7264),
      secondaryAccent: Color(0xffFFD180),
    ),
  ),
  // 5 — Acid lab
  AppThemeSet(
    accent: Color(0xffE0FF4F),
    light: ThemeSurface(
      primaryBackground: Color(0xffFAFBF2),
      secondaryBackground: Color(0xffF2F5E4),
      primaryText: Color(0xff343828),
      secondaryText: Color(0xff1C1E14),
      primaryDisabledText: Color(0xffA0A88E),
      secondaryAccent: Color(0xff827717),
    ),
    dark: ThemeSurface(
      primaryBackground: Color(0xff10120C),
      secondaryBackground: Color(0xff171A12),
      primaryText: Color(0xffF4FFD8),
      secondaryText: Colors.black,
      primaryDisabledText: Color(0xff6F7A5A),
      secondaryAccent: Color(0xffF4FF81),
    ),
  ),
  // 6 — Rose chrome
  AppThemeSet(
    accent: Color(0xffFF4081),
    light: ThemeSurface(
      primaryBackground: Color(0xffFFF6F8),
      secondaryBackground: Color(0xffFFEBF0),
      primaryText: Color(0xff3A2230),
      secondaryText: Color(0xff1A1018),
      primaryDisabledText: Color(0xffBB8FA0),
      secondaryAccent: Color(0xffC2185B),
    ),
    dark: ThemeSurface(
      primaryBackground: Color(0xff140E12),
      secondaryBackground: Color(0xff1E141A),
      primaryText: Color(0xffFFDCE8),
      secondaryText: Colors.black,
      primaryDisabledText: Color(0xff856070),
      secondaryAccent: Color(0xffFF8A80),
    ),
  ),
];
