import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/alarmChallenge/controllers/alarm_challenge_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

enum _MemoryPhase { countdown, showing, input, success, failure }

class MemoryChallengeView extends StatefulWidget {
  const MemoryChallengeView({Key? key}) : super(key: key);

  @override
  State<MemoryChallengeView> createState() => _MemoryChallengeViewState();
}

class _MemoryChallengeViewState extends State<MemoryChallengeView> with TickerProviderStateMixin {
  final AlarmChallengeController controller = Get.find<AlarmChallengeController>();
  final ThemeController themeController = Get.find<ThemeController>();

  _MemoryPhase _phase = _MemoryPhase.countdown;
  int _countdown = 3;
  int _activeTileIndex = -1;
  int _flashTileIndex = -1;
  List<int> _userInput = [];
  List<int> _pattern = [];
  Timer? _countdownTimer;
  Worker? _patternWorker;

  @override
  void initState() {
    super.initState();
    _pattern = List<int>.from(controller.memoryPattern);
    _patternWorker = ever(controller.memoryPatternVersion, (_) {
      if (mounted) {
        _pattern = List<int>.from(controller.memoryPattern);
        _startCountdown();
      }
    });
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _patternWorker?.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _phase = _MemoryPhase.countdown;
      _countdown = 3;
      _activeTileIndex = -1;
      _flashTileIndex = -1;
      _userInput = [];
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        t.cancel();
        _playPattern();
      }
    });
  }

  Future<void> _playPattern() async {
    if (!mounted) return;
    setState(() {
      _phase = _MemoryPhase.showing;
      _activeTileIndex = -1;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    for (int i = 0; i < _pattern.length; i++) {
      if (!mounted) return;
      setState(() => _activeTileIndex = _pattern[i]);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _activeTileIndex = -1);
      await Future.delayed(const Duration(milliseconds: 250));
    }

    if (!mounted) return;
    setState(() {
      _phase = _MemoryPhase.input;
      _userInput = [];
    });
  }

  Future<void> _onTileTapped(int index) async {
    if (_phase != _MemoryPhase.input) return;
    Utils.hapticFeedback();

    setState(() => _flashTileIndex = index);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => _flashTileIndex = -1);

    final newInput = List<int>.from(_userInput)..add(index);
    setState(() => _userInput = newInput);

    if (newInput[newInput.length - 1] != _pattern[newInput.length - 1]) {
      await _onFailure();
      return;
    }

    if (newInput.length == _pattern.length) {
      await _onSuccess();
    }
  }

  Future<void> _onSuccess() async {
    if (!mounted) return;
    setState(() => _phase = _MemoryPhase.success);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    controller.onMemoryRoundCompleted();
  }

  Future<void> _onFailure() async {
    if (!mounted) return;
    setState(() => _phase = _MemoryPhase.failure);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _playPattern();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.primaryBackgroundColor.value,
      body: SafeArea(
        child: Obx(() {
          final roundsLeft = controller.numMemoryRounds.value;
          final totalRounds = controller.alarmRecord.numMemoryRounds;
          final completedRounds = (totalRounds - roundsLeft).clamp(0, totalRounds);

          return Column(
            children: [
              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close_rounded, color: themeController.primaryTextColor.value.withOpacity(0.6)),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'MEMORY CHALLENGE',
                          style: TextStyle(
                            color: themeController.primaryColor.value,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          'Round ${completedRounds + 1} of $totalRounds',
                          style: TextStyle(
                            color: themeController.primaryTextColor.value.withOpacity(0.4),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              
              // ── Challenge Timer ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: controller.progress.value,
                    minHeight: 3,
                    backgroundColor: themeController.primaryColor.value.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(themeController.primaryColor.value),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // ── Status Indicator ──
              _buildStatusHeader(),

              const Spacer(flex: 1),

              // ── Grid ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: 16,
                    itemBuilder: (_, index) => _buildTile(index),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // ── Progress Dots ──
              _buildInputProgress(),

              const SizedBox(height: 40),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatusHeader() {
    String title = '';
    String subtitle = '';
    Color color = themeController.primaryTextColor.value;

    switch (_phase) {
      case _MemoryPhase.countdown:
        title = 'Get Ready';
        subtitle = 'Starting in $_countdown...';
        color = themeController.primaryColor.value;
        break;
      case _MemoryPhase.showing:
        title = 'Memorize';
        subtitle = 'Watch the sequence';
        color = themeController.primaryColor.value;
        break;
      case _MemoryPhase.input:
        title = 'Your Turn';
        subtitle = 'Repeat the pattern';
        break;
      case _MemoryPhase.success:
        title = 'Perfect';
        subtitle = 'Round complete';
        color = Colors.green;
        break;
      case _MemoryPhase.failure:
        title = 'Oops';
        subtitle = 'Try again';
        color = Colors.red;
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: ValueKey(_phase.toString() + _countdown.toString()),
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: themeController.primaryTextColor.value.withOpacity(0.4),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(int index) {
    final bool isLit = (_phase == _MemoryPhase.showing && _activeTileIndex == index) ||
                       (_phase == _MemoryPhase.input && _flashTileIndex == index);
    
    Color tileColor = themeController.secondaryBackgroundColor.value;
    if (isLit) tileColor = themeController.primaryColor.value;
    if (_phase == _MemoryPhase.success) tileColor = Colors.green.withOpacity(0.4);
    if (_phase == _MemoryPhase.failure) tileColor = Colors.red.withOpacity(0.3);

    return GestureDetector(
      onTap: () => _onTileTapped(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: isLit ? 50 : 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLit ? [
            BoxShadow(
              color: themeController.primaryColor.value.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ] : [],
          border: Border.all(
            color: isLit 
                ? themeController.primaryColor.value 
                : themeController.primaryTextColor.value.withOpacity(0.04),
            width: isLit ? 2.5 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildInputProgress() {
    return AnimatedOpacity(
      opacity: _phase == _MemoryPhase.input ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pattern.length, (i) {
          final isFilled = i < _userInput.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: isFilled ? 12 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isFilled 
                  ? themeController.primaryColor.value 
                  : themeController.primaryTextColor.value.withOpacity(0.1),
            ),
          );
        }),
      ),
    );
  }
}
