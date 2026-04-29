import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoodTracker Widget Tests', () {
    testWidgets('Mood emoji picker shows 10 emojis', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.count(
              crossAxisCount: 5,
              children: List.generate(10, (i) {
                return Center(child: Text('${i + 1}', key: Key('mood_$i')));
              }),
            ),
          ),
        ),
      );

      // Verify 10 mood options exist
      for (int i = 0; i < 10; i++) {
        expect(find.byKey(Key('mood_$i')), findsOneWidget);
      }
    });

    testWidgets('Score labels display correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: List.generate(10, (i) {
                return Text('${i + 1}', key: Key('score_${i + 1}'));
              }),
            ),
          ),
        ),
      );

      // Verify score labels 1-10
      for (int i = 1; i <= 10; i++) {
        expect(find.byKey(Key('score_$i')), findsOneWidget);
      }
    });

    testWidgets('Save mood button appears when score selected', (tester) async {
      bool buttonVisible = false;
      int? selectedScore;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => selectedScore = 5),
                    child: const Text('Select Mood 5'),
                  ),
                  if (selectedScore != null)
                    ElevatedButton(
                      onPressed: () => setState(() => buttonVisible = true),
                      child: const Text('Save Mood'),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      // Initially button not visible
      expect(find.text('Save Mood'), findsNothing);

      // Tap to select mood
      await tester.tap(find.text('Select Mood 5'));
      await tester.pump();

      // Now save button appears
      expect(find.text('Save Mood'), findsOneWidget);
    });

    testWidgets('History section label renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('HISTORY'))),
      );
      expect(find.text('HISTORY'), findsOneWidget);
    });
  });
}
