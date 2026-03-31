import 'package:flutter/material.dart';

class GroundingScreen extends StatefulWidget {
  const GroundingScreen({super.key});

  @override
  State<GroundingScreen> createState() => _GroundingScreenState();
}

class _GroundingScreenState extends State<GroundingScreen> {
  int _currentStep = 0;

  static const Color _background = Color(0xFFF5F4EF);
  static const Color _primaryGreen = Color(0xFF2D9B6F);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF6B6B6B);
  static const Color _cardBg = Color(0xFFFFFFFF);

  final List<Map<String, dynamic>> _steps = [
    {
      'number': '5',
      'sense': 'See',
      'emoji': '👁️',
      'instruction': 'Look around and name 5 things you can SEE.',
      'hint': 'e.g. a chair, a window, your hands, a plant, a lamp',
      'color': Color(0xFF2D9B6F),
    },
    {
      'number': '4',
      'sense': 'Touch',
      'emoji': '✋',
      'instruction': 'Notice 4 things you can TOUCH or feel.',
      'hint': 'e.g. the texture of your clothes, the floor, a surface',
      'color': Color(0xFF5C6BC0),
    },
    {
      'number': '3',
      'sense': 'Hear',
      'emoji': '👂',
      'instruction': 'Listen for 3 things you can HEAR.',
      'hint': 'e.g. traffic, birds, your breathing, a fan',
      'color': Color(0xFFEF6C00),
    },
    {
      'number': '2',
      'sense': 'Smell',
      'emoji': '👃',
      'instruction': 'Find 2 things you can SMELL.',
      'hint': 'e.g. your coffee, fresh air, a candle, your skin',
      'color': Color(0xFFD81B60),
    },
    {
      'number': '1',
      'sense': 'Taste',
      'emoji': '👅',
      'instruction': 'Notice 1 thing you can TASTE.',
      'hint': 'e.g. a mint, water, your last meal',
      'color': Color(0xFF00897B),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final Color stepColor = step['color'];

    return Scaffold(
      backgroundColor: _background,
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
                    '5-4-3-2-1 Grounding',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Step indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(5, (i) {
                  final isDone = i < _currentStep;
                  final isActive = i == _currentStep;
                  final color = _steps[i]['color'] as Color;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDone || isActive
                            ? color
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Big number + emoji
                    Text(step['emoji'], style: const TextStyle(fontSize: 64)),

                    const SizedBox(height: 16),

                    Text(
                      step['number'],
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 80,
                        fontWeight: FontWeight.w700,
                        color: stepColor,
                      ),
                    ),

                    // Step card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            step['instruction'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            step['hint'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _textMuted,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Next / Done button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentStep < _steps.length - 1) {
                            setState(() => _currentStep++);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: stepColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentStep < _steps.length - 1
                              ? 'Next →'
                              : 'Complete ✓',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
