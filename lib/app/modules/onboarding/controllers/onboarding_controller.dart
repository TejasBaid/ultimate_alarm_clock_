import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/providers/get_storage_provider.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentIndex = 0.obs;

  final List<Map<String, dynamic>> onboardingPages = [
    {
      'title': 'Welcome to UltiClock',
      'description': 'The ultimate alarm clock that makes sure you wake up on time.',
      'icon': Icons.alarm,
    },
    {
      'title': 'Wake Up Challenges',
      'description': 'Solve math problems, shake your phone, or scan a QR code to dismiss your alarm.',
      'icon': Icons.extension,
    },
    {
      'title': 'Smart Features',
      'description': 'Check weather, track steps, and sync with your calendar seamlessly.',
      'icon': Icons.wb_sunny,
    },
  ];

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void nextPage() {
    if (currentIndex.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      finishOnboarding();
    }
  }

  void finishOnboarding() async {
    final storage = Get.find<GetStorageProvider>();
    Get.offNamed('/bottom-navigation-bar');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
