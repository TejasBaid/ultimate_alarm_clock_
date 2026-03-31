import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/about/controller/about_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class AboutView extends GetView<AboutController> {
  AboutView({super.key});

  final AboutController aboutController = Get.find<AboutController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: themeController.primaryBackgroundColor.value,
      appBar: AppBar(
        backgroundColor: themeController.primaryBackgroundColor.value,
        title: Text(
          'About'.tr,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: themeController.primaryTextColor.value,
                fontWeight: FontWeight.w600,
              ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Obx(
            () => Icon(
              Icons.adaptive.arrow_back,
              color: themeController.primaryTextColor.value,
            ),
          ),
          onPressed: () {
            Utils.hapticFeedback();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: themeController.primaryColor.value.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: SizedBox.fromSize(
                    size: const Size.fromRadius(60),
                    child: Image.asset('assets/images/ic_launcher-playstore.png'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ultimate Alarm Clock'.tr,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeController.primaryTextColor.value,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: themeController.primaryColor.value.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: themeController.primaryColor.value.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Version 0.2.1'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeController.primaryColor.value,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: themeController.secondaryBackgroundColor.value,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: themeController.primaryTextColor.value.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: themeController.primaryColor.value,
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This project was originally developed as part of Google Summer of Code under the CCExtractor organization. It\'s free, open-source, and we encourage developers to contribute!'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: themeController.primaryTextColor.value.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Links'.tr.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: themeController.primaryTextColor.value.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLinkButton(
                context: context,
                title: 'GitHub Repository',
                subtitle: 'View source code & contribute',
                iconPath: 'assets/images/github.svg',
                onTap: () async {
                  if (!await aboutController.launchUrl(Uri.parse(AboutController.githubUrl))) {
                    throw Exception('Could not launch ${AboutController.githubUrl}'.tr);
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildLinkButton(
                context: context,
                title: 'CCExtractor',
                subtitle: 'Visit organization website',
                iconPath: 'assets/images/link.svg',
                onTap: () async {
                  if (!await aboutController.launchUrl(Uri.parse(AboutController.ccExtractorUrl))) {
                    throw Exception('Could not launch ${AboutController.ccExtractorUrl}'.tr);
                  }
                },
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Made with ',
                    style: TextStyle(
                      color: themeController.primaryTextColor.value.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  const Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                  Text(
                    ' for the community',
                    style: TextStyle(
                      color: themeController.primaryTextColor.value.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildLinkButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Material(
      color: themeController.secondaryBackgroundColor.value,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Utils.hapticFeedback();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  colorFilter: iconPath.contains('link') 
                      ? const ColorFilter.mode(Colors.black87, BlendMode.srcIn)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeController.primaryTextColor.value,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: themeController.primaryTextColor.value.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: themeController.primaryTextColor.value.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}