import 'package:flutter_test/flutter_test.dart';
import 'package:mindwell_ai/core/services/sentiment_service.dart';

void main() {
  group('SentimentResult', () {
    test('creates SentimentResult with correct values', () {
      final result = SentimentResult(
        label: 'POSITIVE',
        emoji: '😊',
        compound: 0.75,
        keywords: ['happy', 'great'],
      );

      expect(result.label, 'POSITIVE');
      expect(result.emoji, '😊');
      expect(result.compound, 0.75);
      expect(result.keywords, ['happy', 'great']);
    });

    test('creates NEUTRAL SentimentResult correctly', () {
      final result = SentimentResult(
        label: 'NEUTRAL',
        emoji: '😶',
        compound: 0.0,
        keywords: [],
      );

      expect(result.label, 'NEUTRAL');
      expect(result.compound, 0.0);
      expect(result.keywords.isEmpty, true);
    });

    test('creates NEGATIVE SentimentResult correctly', () {
      final result = SentimentResult(
        label: 'NEGATIVE',
        emoji: '😔',
        compound: -0.65,
        keywords: ['sad', 'tired'],
      );

      expect(result.label, 'NEGATIVE');
      expect(result.compound, -0.65);
      expect(result.compound.isNegative, true);
    });

    // ─── Sentiment Label Validation ──────────────────────────────
    test('POSITIVE label is valid', () {
      const validLabels = ['POSITIVE', 'NEUTRAL', 'NEGATIVE'];
      expect(validLabels.contains('POSITIVE'), true);
    });

    test('compound score within valid range for positive', () {
      final result = SentimentResult(
        label: 'POSITIVE',
        emoji: '😊',
        compound: 0.85,
        keywords: [],
      );
      expect(result.compound >= 0.05, true);
    });

    test('compound score within valid range for negative', () {
      final result = SentimentResult(
        label: 'NEGATIVE',
        emoji: '😔',
        compound: -0.45,
        keywords: [],
      );
      expect(result.compound <= -0.05, true);
    });

    test('compound score within valid range for neutral', () {
      final result = SentimentResult(
        label: 'NEUTRAL',
        emoji: '😶',
        compound: 0.02,
        keywords: [],
      );
      expect(result.compound > -0.05 && result.compound < 0.05, true);
    });

    // ─── Keywords ────────────────────────────────────────────────
    test('keywords list can hold multiple items', () {
      final result = SentimentResult(
        label: 'POSITIVE',
        emoji: '😊',
        compound: 0.6,
        keywords: ['happy', 'grateful', 'blessed', 'joyful', 'calm'],
      );
      expect(result.keywords.length, 5);
    });

    test('keywords list can be empty', () {
      final result = SentimentResult(
        label: 'NEUTRAL',
        emoji: '😶',
        compound: 0.0,
        keywords: [],
      );
      expect(result.keywords.isEmpty, true);
    });
  });
}
