import 'package:flutter_test/flutter_test.dart';
import 'package:mindwell_ai/core/utils/phq9_scorer.dart';

void main() {
  group('PHQ9Scorer', () {
    // ─── Score Calculation ───────────────────────────────────────
    test('calculates zero score correctly', () {
      final answers = List.filled(9, 0);
      expect(PHQ9Scorer.calculateScore(answers), 0);
    });

    test('calculates maximum score correctly', () {
      final answers = List.filled(9, 3);
      expect(PHQ9Scorer.calculateScore(answers), 27);
    });

    test('calculates mixed score correctly', () {
      final answers = [0, 1, 2, 3, 0, 1, 2, 3, 1];
      expect(PHQ9Scorer.calculateScore(answers), 13);
    });

    test('calculates partial score correctly', () {
      final answers = [1, 1, 1, 1, 1, 1, 1, 1, 1];
      expect(PHQ9Scorer.calculateScore(answers), 9);
    });

    // ─── Severity Classification ─────────────────────────────────
    test('returns Minimal for score 0', () {
      expect(PHQ9Scorer.getSeverity(0), 'Minimal');
    });

    test('returns Minimal for score 4', () {
      expect(PHQ9Scorer.getSeverity(4), 'Minimal');
    });

    test('returns Mild for score 5', () {
      expect(PHQ9Scorer.getSeverity(5), 'Mild');
    });

    test('returns Mild for score 9', () {
      expect(PHQ9Scorer.getSeverity(9), 'Mild');
    });

    test('returns Moderate for score 10', () {
      expect(PHQ9Scorer.getSeverity(10), 'Moderate');
    });

    test('returns Moderate for score 14', () {
      expect(PHQ9Scorer.getSeverity(14), 'Moderate');
    });

    test('returns Moderately Severe for score 15', () {
      expect(PHQ9Scorer.getSeverity(15), 'Moderately Severe');
    });

    test('returns Moderately Severe for score 19', () {
      expect(PHQ9Scorer.getSeverity(19), 'Moderately Severe');
    });

    test('returns Severe for score 20', () {
      expect(PHQ9Scorer.getSeverity(20), 'Severe');
    });

    test('returns Severe for maximum score 27', () {
      expect(PHQ9Scorer.getSeverity(27), 'Severe');
    });

    // ─── Recommendations ─────────────────────────────────────────
    test('gives minimal recommendation for low score', () {
      final rec = PHQ9Scorer.getRecommendation(2);
      expect(rec.toLowerCase(), contains('minimal'));
    });

    test('gives mild recommendation for score 7', () {
      final rec = PHQ9Scorer.getRecommendation(7);
      expect(rec.toLowerCase(), contains('mild'));
    });

    test('gives moderate recommendation for score 12', () {
      final rec = PHQ9Scorer.getRecommendation(12);
      expect(rec.toLowerCase(), contains('professional'));
    });

    test('gives severe recommendation for score 25', () {
      final rec = PHQ9Scorer.getRecommendation(25);
      expect(rec.toLowerCase(), contains('severe'));
    });

    // ─── Questions ───────────────────────────────────────────────
    test('has exactly 9 questions', () {
      expect(PHQ9Scorer.questions.length, 9);
    });

    test('has exactly 4 answer options', () {
      expect(PHQ9Scorer.options.length, 4);
    });

    test('first option is Not at all', () {
      expect(PHQ9Scorer.options[0], 'Not at all');
    });

    test('last option is Nearly every day', () {
      expect(PHQ9Scorer.options[3], 'Nearly every day');
    });
  });
}
