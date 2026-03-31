import 'package:flutter/material.dart';
import 'breathing_screen.dart';
import 'affirmations_screen.dart';
import 'grounding_screen.dart';

class CalmScreen extends StatelessWidget {
  const CalmScreen({super.key});

  static const Color _background = Color(0xFFF5F4EF);
  static const Color _primaryGreen = Color(0xFF2D9B6F);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF6B6B6B);
  static const Color _cardBg = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Header
              const Text(
                'Calm',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mindfulness & Coping Skills',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: _textMuted,
                ),
              ),

              const SizedBox(height: 24),

              // Exercise cards
              _buildExerciseCard(
                context,
                title: '4-7-8 Breathing',
                description:
                    'Inhale for 4s, hold for 7s, exhale for 8s to calm the nervous system.',
                duration: '5 min',
                borderColor: _primaryGreen,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BreathingScreen()),
                ),
              ),

              const SizedBox(height: 14),

              _buildExerciseCard(
                context,
                title: 'Gratitude Journaling',
                description:
                    'Write down three things you are grateful for today.',
                duration: '10 min',
                borderColor: Colors.transparent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AffirmationsScreen()),
                ),
              ),

              const SizedBox(height: 14),

              _buildExerciseCard(
                context,
                title: '5-4-3-2-1 Grounding',
                description:
                    'Use your five senses to anchor yourself to the present moment.',
                duration: '7 min',
                borderColor: Colors.transparent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GroundingScreen()),
                ),
              ),

              const SizedBox(height: 14),

              _buildExerciseCard(
                context,
                title: 'Daily Affirmations',
                description:
                    'Positive statements to boost your confidence and mental strength.',
                duration: '3 min',
                borderColor: Colors.transparent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AffirmationsScreen()),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context, {
    required String title,
    required String description,
    required String duration,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    final bool isHighlighted = borderColor != Colors.transparent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHighlighted ? borderColor : Colors.grey.shade100,
            width: isHighlighted ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: _textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'START PRACTICE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _primaryGreen,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _primaryGreen,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
