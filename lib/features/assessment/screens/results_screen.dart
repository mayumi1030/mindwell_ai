import 'package:flutter/material.dart';
import '../../../models/assessment_result.dart';
import '../../home/screens/home_screen.dart';

class ResultsScreen extends StatelessWidget {
  final AssessmentResult result;

  const ResultsScreen({super.key, required this.result});

  static const Color _background = Color(0xFFF5F4EF);
  static const Color _primaryGreen = Color(0xFF2D9B6F);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF6B6B6B);
  static const Color _cardBg = Color(0xFFFFFFFF);

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

    return Scaffold(
      backgroundColor: _background,
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
                  color: _textDark,
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
                  color: _textMuted,
                ),
              ),

              const SizedBox(height: 32),

              // Score card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
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
                          TextSpan(
                            text: ' / $_maxScore',
                            style: const TextStyle(
                              fontSize: 20,
                              color: _textMuted,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Severity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
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

                    // Score bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: scorePercent,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Recommendation card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCEFE2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: _primaryGreen,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Recommendation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.recommendation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _textMuted,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Disclaimer card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
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

              const SizedBox(height: 24),

              // Back to home button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
