import 'dart:async';
import 'package:flutter/material.dart';

// Color constant
const Color _textMuted = Color(0xFF6B6B6B);

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  Timer? _timer;
  int _secondsLeft = 4;
  int _phase = 0; // 0=inhale, 1=hold, 2=exhale
  int _cycleCount = 0;
  bool _isRunning = false;

  final List<Map<String, dynamic>> _phases = [
    {'label': 'Inhale', 'seconds': 4, 'color': Color(0xFF2D9B6F)},
    {'label': 'Hold', 'seconds': 7, 'color': Color(0xFF5C6BC0)},
    {'label': 'Exhale', 'seconds': 8, 'color': Color(0xFF4CAF82)},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _secondsLeft = _phases[0]['seconds'];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startStop() {
    if (_isRunning) {
      _timer?.cancel();
      _animController.stop();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _runPhase();
    }
  }

  void _runPhase() {
    final duration = _phases[_phase]['seconds'] as int;
    setState(() => _secondsLeft = duration);

    // Animate circle
    if (_phase == 0) {
      _animController.duration = Duration(seconds: duration);
      _animController.forward(from: 0);
    } else if (_phase == 2) {
      _animController.duration = Duration(seconds: duration);
      _animController.reverse(from: 1);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        _nextPhase();
      }
    });
  }

  void _nextPhase() {
    if (!mounted) return;
    setState(() {
      _phase = (_phase + 1) % 3;
      if (_phase == 0) _cycleCount++;
    });
    _runPhase();
  }

  void _reset() {
    _timer?.cancel();
    _animController.reset();
    setState(() {
      _isRunning = false;
      _phase = 0;
      _cycleCount = 0;
      _secondsLeft = _phases[0]['seconds'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPhase = _phases[_phase];
    final Color phaseColor = currentPhase['color'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    '4-7-8 Breathing',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cycles counter
                  Text(
                    'Cycle $_cycleCount',
                    style: const TextStyle(
                      fontSize: 14,
                      color: const Color(0xFFB8B0E8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Breathing circle
                  AnimatedBuilder(
                    animation: _scaleAnim,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _phase == 1 ? 1.0 : _scaleAnim.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: phaseColor.withOpacity(0.12),
                        border: Border.all(
                          color: phaseColor.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: phaseColor.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$_secondsLeft',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    color: phaseColor,
                                  ),
                                ),
                                Text(
                                  currentPhase['label'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: phaseColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Phase indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final isActive = _phase == i;
                      final color = _phases[i]['color'] as Color;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? color.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? color : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          '${_phases[i]['label']} ${_phases[i]['seconds']}s',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isActive ? color : _textMuted,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 48),

                  // Start/Stop button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _reset,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: _startStop,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFC427FB),
                          ),
                          child: Icon(
                            _isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
