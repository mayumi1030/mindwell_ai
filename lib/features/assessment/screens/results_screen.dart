import 'package:flutter/material.dart';
import '../../../models/assessment_result.dart';
import '../../home/screens/home_screen.dart';

class ResultsScreen extends StatelessWidget {
  final AssessmentResult result;

  const ResultsScreen({super.key, required this.result});

  Color _severityColor(String severity) {
    switch (severity) {
      case 'Minimal':
        return const Color(0xFF2D9B6F);
      case 'Mild':
        return const Color(0xFF4CAF82);
      case 'Moderate':
        return const Color(0xFFFFB347);
      case 'Moderately Severe':
        return const Color(0xFFEF6C00);
      case 'Severe':
        return const Color(0xFFE57373);
      default:
        return const Color(0xFF2D9B6F);
    }
  }

  String _severityEmoji(String severity) {
    switch (severity) {
      case 'Minimal':
        return '😊';
      case 'Mild':
        return '🙂';
      case 'Moderate':
        return '😐';
      case 'Moderately Severe':
        return '😟';
      case 'Severe':
        return '😔';
      default:
        return '😐';
    }
  }

  int get _maxScore => result.type == 'PHQ9' ? 27 : 21;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(result.severity);
    final emoji = _severityEmoji(result.severity);
    final scorePercent = result.score / _maxScore;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1D47), Color(0xFF0E0C2A), Color(0xFF16103A)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),

                // Header
                Text(
                  result.type == 'PHQ9' ? 'PHQ-9 Results' : 'GAD-7 Results',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  result.type == 'PHQ9'
                      ? 'Depression Assessment'
                      : 'Anxiety Assessment',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFB8B0E8),
                  ),
                ),

                const SizedBox(height: 32),

                // Score Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5936B4), Color(0xFFC427FB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC427FB).withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Emoji
                      Text(emoji, style: const TextStyle(fontSize: 56)),

                      const SizedBox(height: 16),

                      // Score
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${result.score}',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 52,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            const TextSpan(
                              text: ' / ',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFFE0D9FF),
                              ),
                            ),
                            TextSpan(
                              text: '$_maxScore',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFFE0D9FF),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Severity Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          result.severity.toUpperCase(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: color,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: scorePercent,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Recommendation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5936B4), Color(0xFFC427FB)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),

                          const SizedBox(width: 10),

                          const Text(
                            'Recommendation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Text(
                        result.recommendation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB8B0E8),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Disclaimer Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFFFB347).withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFEF6C00),
                        size: 20,
                      ),

                      const SizedBox(width: 10),

                      const Expanded(
                        child: Text(
                          'This assessment is for informational purposes only and does not constitute a medical diagnosis. Please consult a qualified mental health professional for proper evaluation.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF795548),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Back Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5936B4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
