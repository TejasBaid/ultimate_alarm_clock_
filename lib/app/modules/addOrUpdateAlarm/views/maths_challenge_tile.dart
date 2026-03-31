import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class MathsChallenge extends StatelessWidget {
  const MathsChallenge({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    double sliderValue;
    int noOfMathQues;
    bool isMathsEnabled;
    return Obx(
      () => InkWell(
        onTap: () {
          Utils.hapticFeedback();
          // saving initial values of sliders & numbers
          isMathsEnabled = controller.isMathsEnabled.value;
          sliderValue = controller.mathsSliderValue.value;
          noOfMathQues = controller.numMathsQuestions.value;

          if (!controller.isMathsEnabled.value) {
            controller.isMathsEnabled.value = true;
            if (controller.numMathsQuestions.value == 0) {
              controller.numMathsQuestions.value = 3;
            }
          }
          
          _showMathSettingsBottomSheet(context, isMathsEnabled, sliderValue, noOfMathQues);
        },
        child: ListTile(
          leading: Icon(
            controller.isMathsEnabled.value ? Icons.calculate : Icons.calculate_outlined,
            color: controller.isMathsEnabled.value 
                ? Get.find<ThemeController>().primaryColor.value 
                : themeController.primaryDisabledTextColor.value,
          ),
          title: Text(
            'Math Challenge'.tr,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
            ),
          ),
          subtitle: Text(
            controller.isMathsEnabled.value && controller.numMathsQuestions.value > 0
                ? '${Utils.getDifficultyLabel(controller.mathsDifficulty.value).tr} • ${controller.numMathsQuestions.value} questions'
                : 'Disabled'.tr,
            style: TextStyle(
              color: themeController.primaryDisabledTextColor.value,
            ),
          ),
          trailing: Switch.adaptive(
            value: controller.isMathsEnabled.value,
            activeColor: Get.find<ThemeController>().primaryColor.value,
            onChanged: (value) {
              Utils.hapticFeedback();
              controller.isMathsEnabled.value = value;
              if (!value) {
                controller.numMathsQuestions.value = 0;
              } else if (controller.numMathsQuestions.value == 0) {
                controller.numMathsQuestions.value = 3;
                // Auto open settings when enabled for the first time
                _showMathSettingsBottomSheet(context, false, controller.mathsSliderValue.value, 0);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showMathSettingsBottomSheet(BuildContext context, bool initialIsMathsEnabled, double initialSliderValue, int initialNoOfMathQues) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeController.secondaryBackgroundColor.value,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: themeController.primaryDisabledTextColor.value.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Get.find<ThemeController>().primaryColor.value.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calculate,
                            color: Get.find<ThemeController>().primaryColor.value,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Math Challenge'.tr,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: themeController.primaryTextColor.value,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Utils.hapticFeedback();
                            // Reset to initial values
                            controller.isMathsEnabled.value = initialIsMathsEnabled;
                            controller.mathsSliderValue.value = initialSliderValue;
                            controller.numMathsQuestions.value = initialNoOfMathQues;
                            controller.mathsDifficulty.value = Utils.getDifficulty(initialSliderValue);
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: themeController.primaryDisabledTextColor.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Settings
                          Column(
                            children: [
                              // Difficulty Section
                              _buildSection(
                                      title: 'Difficulty Level'.tr,
                                      subtitle: 'Choose problem complexity'.tr,
                                      child: Column(
                                        children: [
                                          // Preview problem
                                          Obx(() => Container(
                                            padding: const EdgeInsets.all(16),
                                            margin: const EdgeInsets.only(bottom: 16),
                                            decoration: BoxDecoration(
                                              color: Get.find<ThemeController>().primaryColor.value.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Get.find<ThemeController>().primaryColor.value.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  Utils.getDifficultyLabel(controller.mathsDifficulty.value).tr,
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    color: Get.find<ThemeController>().primaryColor.value,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  Utils.generateMathProblem(controller.mathsDifficulty.value)[0],
                                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    color: themeController.primaryTextColor.value,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                          
                                          // Difficulty slider
                                          Obx(() => Slider.adaptive(
                                            min: 0.0,
                                            max: 2.0,
                                            divisions: 2,
                                            value: controller.mathsSliderValue.value,
                                            onChanged: (newValue) {
                                              Utils.hapticFeedback();
                                              controller.mathsSliderValue.value = newValue;
                                              controller.mathsDifficulty.value = Utils.getDifficulty(newValue);
                                            },
                                            activeColor: Get.find<ThemeController>().primaryColor.value,
                                            inactiveColor: Get.find<ThemeController>().primaryColor.value.withOpacity(0.3),
                                          )),
                                          
                                          // Difficulty labels
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Easy'.tr,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: themeController.primaryDisabledTextColor.value,
                                                ),
                                              ),
                                              Text(
                                                'Medium'.tr,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: themeController.primaryDisabledTextColor.value,
                                                ),
                                              ),
                                              Text(
                                                'Hard'.tr,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: themeController.primaryDisabledTextColor.value,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Number of Questions
                                    _buildSection(
                                      title: 'Number of Questions'.tr,
                                      subtitle: 'How many problems to solve'.tr,
                                      child: Column(
                                        children: [
                                          Obx(() => Text(
                                            controller.numMathsQuestions.value.toString(),
                                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                              color: Get.find<ThemeController>().primaryColor.value,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )),
                                          const SizedBox(height: 16),
                                          NumberPicker(
                                            value: controller.numMathsQuestions.value,
                                            minValue: 1,
                                            maxValue: 20,
                                            onChanged: (value) {
                                              Utils.hapticFeedback();
                                              controller.numMathsQuestions.value = value;
                                            },
                                            itemWidth: Utils
                                                .getResponsiveNumberPickerItemWidth(
                                              context,
                                              screenWidth: MediaQuery.of(context).size.width,
                                              baseWidthFactor: 0.2,
                                            ),
                                            textStyle: Utils
                                                .getResponsiveNumberPickerTextStyle(
                                              context,
                                              baseFontSize: 16,
                                              color: themeController.primaryDisabledTextColor.value,
                                            ),
                                            selectedTextStyle: Utils
                                                .getResponsiveNumberPickerSelectedTextStyle(
                                              context,
                                              baseFontSize: 20,
                                              color: Get.find<ThemeController>().primaryColor.value,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  
                  // Action buttons
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    decoration: BoxDecoration(
                      color: themeController.secondaryBackgroundColor.value,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Utils.hapticFeedback();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.find<ThemeController>().primaryColor.value,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save'.tr,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              )
            );
          },
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeController.primaryBackgroundColor.value,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: themeController.primaryDisabledTextColor.value,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
