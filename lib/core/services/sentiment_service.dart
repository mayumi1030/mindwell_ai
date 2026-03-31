import 'dart:convert';
import 'package:http/http.dart' as http;

class SentimentResult {
  final String label;
  final String emoji;
  final double compound;
  final List<String> keywords;

  SentimentResult({
    required this.label,
    required this.emoji,
    required this.compound,
    required this.keywords,
  });
}

class SentimentService {
  // Use 10.0.2.2 for Android emulator to reach localhost
  static const String _baseUrl = 'http://10.0.2.2:5000';

  Future<SentimentResult> analyze(String text) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/analyze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SentimentResult(
          label: data['label'] ?? 'NEUTRAL',
          emoji: data['emoji'] ?? '😶',
          compound: (data['compound'] ?? 0.0).toDouble(),
          keywords: List<String>.from(data['keywords'] ?? []),
        );
      } else {
        throw Exception('Sentiment analysis failed');
      }
    } catch (e) {
      // Fallback if service unavailable
      return SentimentResult(
        label: 'NEUTRAL',
        emoji: '😶',
        compound: 0.0,
        keywords: [],
      );
    }
  }
}
