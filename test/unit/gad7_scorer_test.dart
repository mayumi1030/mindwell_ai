import 'package:flutter_test/flutter_test.dart';
import 'package:mindwell_ai/core/utils/gad7_scorer.dart';

void main() {
  group('GAD7Scorer', () {
    // ─── Score Calculation ───────────────────────────────────────
    test('calculates zero score correctly', () {
      final answers = List.filled(7, 0);
      expect(GAD7Scorer.calculateScore(answers), 0);
    });

    test('calculates maximum score correctly', () {
      final answers = List.filled(7, 3);
      expect(GAD7Scorer.calculateScore(answers), 21);
    });

    test('calculates mixed score correctly', () {
      final answers = [0, 1, 2, 3, 0, 1, 2];
      expect(GAD7Scorer.calculateScore(answers), 9);
    });

    test('calculates all-ones score correctly', () {
      final answers = List.filled(7, 1);
      expect(GAD7Scorer.calculateScore(answers), 7);
    });

    // ─── Severity Classification ─────────────────────────────────
    test('returns Minimal for score 0', () {
      expect(GAD7Scorer.getSeverity(0), 'Minimal');
    });

    test('returns Minimal for score 4', () {
      expect(GAD7Scorer.getSeverity(4), 'Minimal');
    });

    test('returns Mild for score 5', () {
      expect(GAD7Scorer.getSeverity(5), 'Mild');
    });

    test('returns Mild for score 9', () {
      expect(GAD7Scorer.getSeverity(9), 'Mild');
    });

    test('returns Moderate for score 10', () {
      expect(GAD7Scorer.getSeverity(10), 'Moderate');
    });

    test('returns Moderate for score 14', () {
      expect(GAD7Scorer.getSeverity(14), 'Moderate');
    });

    test('returns Severe for score 15', () {
      expect(GAD7Scorer.getSeverity(15), 'Severe');
    });

    test('returns Severe for maximum score 21', () {
      expect(GAD7Scorer.getSeverity(21), 'Severe');
    });

    // ─── Recommendations ─────────────────────────────────────────
    test('gives minimal recommendation for score 2', () {
      final rec = GAD7Scorer.getRecommendation(2);
      expect(rec.toLowerCase(), contains('minimal'));
    });

    test('gives mild recommendation for score 7', () {
      final rec = GAD7Scorer.getRecommendation(7);
      expect(rec.toLowerCase(), contains('breathing'));
    });

    test('gives moderate recommendation for score 12', () {
      final rec = GAD7Scorer.getRecommendation(12);
      expect(rec.toLowerCase(), contains('professional'));
    });

    test('gives severe recommendation for score 18', () {
      final rec = GAD7Scorer.getRecommendation(18);
      expect(rec.toLowerCase(), contains('helpline'));
    });

    // ─── Questions ───────────────────────────────────────────────
    test('has exactly 7 questions', () {
      expect(GAD7Scorer.questions.length, 7);
    });

    test('has exactly 4 answer options', () {
      expect(GAD7Scorer.options.length, 4);
    });

    test('first option is Not at all', () {
      expect(GAD7Scorer.options[0], 'Not at all');
    });

    test('last option is Nearly every day', () {
      expect(GAD7Scorer.options[3], 'Nearly every day');
    });
  });
}
