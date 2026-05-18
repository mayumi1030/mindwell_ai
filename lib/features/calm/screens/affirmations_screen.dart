import 'dart:math';
import 'package:flutter/material.dart';

// Color constants
const Color _textMuted = Color(0xFF6B6B6B);

class AffirmationsScreen extends StatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  int _currentIndex = 0;

  final List<Map<String, String>> _affirmations = [
    {'text': 'I am worthy of love and happiness.', 'emoji': '💚'},
    {'text': 'I have the strength to overcome any challenge.', 'emoji': '💪'},
    {'text': 'I am enough, exactly as I am today.', 'emoji': '✨'},
    {'text': 'My feelings are valid and I honour them.', 'emoji': '🌿'},
    {'text': 'I choose peace over worry.', 'emoji': '🌊'},
    {'text': 'I am growing and learning every single day.', 'emoji': '🌱'},
    {'text': 'I deserve rest, care, and kindness.', 'emoji': '🌸'},
    {'text': 'I trust myself to handle whatever comes my way.', 'emoji': '🦋'},
    {'text': 'My mental health matters and I prioritise it.', 'emoji': '🧘'},
    {'text': 'I am not alone — support is always available.', 'emoji': '🤝'},
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = Random().nextInt(_affirmations.length);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextAffirmation() {
    _animController.reverse().then((_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _affirmations.length;
      });
      _animController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final affirmation = _affirmations[_currentIndex];

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
                    'Daily Affirmations',
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
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        affirmation['emoji']!,
                        style: const TextStyle(fontSize: 72),
                      ),

                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: const Color(0x15FFFFFF),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          affirmation['text']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        '${_currentIndex + 1} of ${_affirmations.length}',
                        style: const TextStyle(fontSize: 13, color: _textMuted),
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _nextAffirmation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5936B4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Next Affirmation →',
                            style: TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }
}
