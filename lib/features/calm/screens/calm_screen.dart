import 'package:flutter/material.dart';
import 'breathing_screen.dart';
import 'affirmations_screen.dart';
import 'grounding_screen.dart';

class CalmScreen extends StatelessWidget {
  const CalmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1D47), Color(0xFF0E0C2A), Color(0xFF16103A)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3658B1).withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFE0D9FF), Color(0xFFAEC9FF)],
                    ).createShader(bounds),
                    child: const Text(
                      'Calm',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mindfulness & Coping Skills',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB8B0E8),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildExerciseCard(
                    context,
                    title: '4-7-8 Breathing',
                    description:
                        'Inhale for 4s, hold for 7s, exhale for 8s to calm your nervous system.',
                    duration: '5 min',
                    icon: Icons.air_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3658B1), Color(0xFF5936B4)],
                    ),
                    glowColor: const Color(0xFF3658B1),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const BreathingScreen())),
                  ),

                  const SizedBox(height: 14),

                  _buildExerciseCard(
                    context,
                    title: 'Gratitude Journaling',
                    description:
                        'Write down three things you are grateful for today.',
                    duration: '10 min',
                    icon: Icons.favorite_outline_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC427FB), Color(0xFF5936B4)],
                    ),
                    glowColor: const Color(0xFFC427FB),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const AffirmationsScreen())),
                  ),

                  const SizedBox(height: 14),

                  _buildExerciseCard(
                    context,
                    title: '5-4-3-2-1 Grounding',
                    description:
                        'Use your five senses to anchor yourself in the present moment.',
                    duration: '7 min',
                    icon: Icons.spa_outlined,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF48319D), Color(0xFF3658B1)],
                    ),
                    glowColor: const Color(0xFF48319D),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const GroundingScreen())),
                  ),

                  const SizedBox(height: 14),

                  _buildExerciseCard(
                    context,
                    title: 'Daily Affirmations',
                    description:
                        'Positive statements to boost your confidence and mental strength.',
                    duration: '3 min',
                    icon: Icons.star_outline_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5936B4), Color(0xFFF7CBFD)],
                    ),
                    glowColor: const Color(0xFF5936B4),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const AffirmationsScreen())),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context, {
    required String title,
    required String description,
    required String duration,
    required IconData icon,
    required LinearGradient gradient,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFB8B0E8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB8B0E8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFAEC9FF), Color(0xFFC427FB)],
                    ).createShader(bounds),
                    child: const Row(
                      children: [
                        Text(
                          'START PRACTICE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded,
                            color: Colors.white, size: 16),
                      ],
                    ),
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
