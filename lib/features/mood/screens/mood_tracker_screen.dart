import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/mood_entry.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int? _selectedScore;
  bool _isSaving = false;
  bool _alreadyLoggedToday = false;

  static const Color _background = Color(0xFFF5F4EF);
  static const Color _primaryGreen = Color(0xFF2D9B6F);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF6B6B6B);
  static const Color _cardBg = Color(0xFFFFFFFF);

  // 10 emojis matching your UI design
  final List<String> _emojis = [
    '🤬',
    '😔',
    '😟',
    '😐',
    '🙂',
    '😊',
    '🤩',
    '✨',
    '🌈',
    '😇',
  ];

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _checkTodayLog();
  }

  Future<void> _checkTodayLog() async {
    final logged = await _firestoreService.hasLoggedMoodToday(_userId);
    if (mounted) setState(() => _alreadyLoggedToday = logged);
  }

  Future<void> _saveMood() async {
    if (_selectedScore == null) return;
    setState(() => _isSaving = true);

    try {
      final entry = MoodEntry(
        id: '',
        userId: _userId,
        score: _selectedScore!,
        emoji: _emojis[_selectedScore! - 1],
        note: '',
        createdAt: DateTime.now(),
      );
      await _firestoreService.saveMoodEntry(entry);
      if (!mounted) return;
      setState(() {
        _alreadyLoggedToday = true;
        _selectedScore = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mood saved successfully!'),
          backgroundColor: _primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving mood: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildEmojiPicker() {
    return Container(
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
          const Text(
            'HOW ARE YOU RIGHT NOW?',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E9E9E),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // 2 rows of 5 emojis
          ...List.generate(2, (rowIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (colIndex) {
                  final score = rowIndex * 5 + colIndex + 1;
                  final isSelected = _selectedScore == score;
                  return GestureDetector(
                    onTap: _alreadyLoggedToday
                        ? null
                        : () => setState(
                            () => _selectedScore == score
                                ? _selectedScore = null
                                : _selectedScore = score,
                          ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _primaryGreen.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? _primaryGreen
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _emojis[score - 1],
                            style: TextStyle(fontSize: isSelected ? 36 : 30),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected ? _primaryGreen : _textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          }),

          if (!_alreadyLoggedToday && _selectedScore != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveMood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Mood',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],

          if (_alreadyLoggedToday) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: _primaryGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Mood logged for today. See you tomorrow!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2D9B6F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return StreamBuilder<List<MoodEntry>>(
      stream: _firestoreService.getMoodEntriesStream(_userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2D9B6F)),
          );
        }

        final entries = snapshot.data ?? [];
        if (entries.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'No mood entries yet.\nStart tracking your mood above!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
              ),
            ),
          );
        }

        return Container(
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
              const Text(
                'HISTORY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E9E9E),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.grey.shade100, height: 1),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final date = entry.createdAt;
                  final dateStr =
                      '${_monthName(date.month)} ${date.day.toString().padLeft(2, '0')}';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Text(entry.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.score}/10',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              dateStr.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9E9E9E),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _scoreColor(entry.score).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _scoreLabel(entry.score),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _scoreColor(entry.score),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _scoreColor(int score) {
    if (score <= 3) return const Color(0xFFE57373);
    if (score <= 5) return const Color(0xFFFFB347);
    if (score <= 7) return const Color(0xFF4CAF82);
    return const Color(0xFF2D9B6F);
  }

  String _scoreLabel(int score) {
    if (score <= 2) return 'Very Low';
    if (score <= 4) return 'Low';
    if (score <= 6) return 'Moderate';
    if (score <= 8) return 'Good';
    return 'Excellent';
  }

  String _monthName(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }

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
                'Mood Tracker',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track your emotional journey',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: _textMuted,
                ),
              ),

              const SizedBox(height: 24),

              // Emoji picker card
              _buildEmojiPicker(),

              const SizedBox(height: 20),

              // History list
              _buildHistoryList(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
