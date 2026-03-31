import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/sentiment_service.dart';
import '../../../models/journal_entry.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final SentimentService _sentimentService = SentimentService();
  final TextEditingController _entryController = TextEditingController();
  bool _isSaving = false;

  static const Color _background = Color(0xFFF5F4EF);
  static const Color _primaryGreen = Color(0xFF2D9B6F);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF6B6B6B);
  static const Color _cardBg = Color(0xFFFFFFFF);

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final text = _entryController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      // Analyze sentiment
      final sentiment = await _sentimentService.analyze(text);

      final entry = JournalEntry(
        id: '',
        userId: _userId,
        content: text,
        sentimentLabel: sentiment.label,
        sentimentEmoji: sentiment.emoji,
        sentimentScore: sentiment.compound,
        keywords: sentiment.keywords,
        createdAt: DateTime.now(),
      );

      await _firestoreService.saveJournalEntry(entry);
      _entryController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(sentiment.emoji),
              const SizedBox(width: 8),
              Text('Entry saved — ${sentiment.label}'),
            ],
          ),
          backgroundColor: _primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving entry: $e'),
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

  Color _sentimentColor(String label) {
    switch (label) {
      case 'POSITIVE':
        return const Color(0xFF2D9B6F);
      case 'NEGATIVE':
        return const Color(0xFFE57373);
      default:
        return const Color(0xFFFFB347);
    }
  }

  Widget _buildNewEntryCard() {
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
            'NEW ENTRY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E9E9E),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _entryController,
            maxLines: 6,
            style: const TextStyle(fontSize: 15, color: _textDark, height: 1.6),
            decoration: InputDecoration(
              hintText: "What's on your mind? Your entries are encrypted.",
              hintStyle: const TextStyle(
                color: Color(0xFFBBBBBB),
                fontSize: 14,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F4EF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                disabledBackgroundColor: _primaryGreen.withOpacity(0.4),
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
                      'Save Entry',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntries() {
    return StreamBuilder<List<JournalEntry>>(
      stream: _firestoreService.getJournalEntriesStream(_userId),
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
                'No journal entries yet.\nWrite your first entry above!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RECENT ENTRIES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ...entries.map((entry) => _buildEntryCard(entry)),
          ],
        );
      },
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    final date = entry.createdAt;
    final dateStr = '${_monthName(date.month)} ${date.day}, ${date.year}';
    final sentimentColor = _sentimentColor(entry.sentimentLabel);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
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
          // Header row
          Row(
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Sentiment badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: sentimentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.sentimentEmoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.sentimentLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: sentimentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Entry preview
          Text(
            entry.content.length > 120
                ? '${entry.content.substring(0, 120)}...'
                : entry.content,
            style: const TextStyle(fontSize: 14, color: _textDark, height: 1.5),
          ),

          // Keywords
          if (entry.keywords.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entry.keywords
                  .map(
                    (kw) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EFFE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        kw,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF534AB7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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
              const Text(
                'Journal',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Safe space for your thoughts',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 24),
              _buildNewEntryCard(),
              const SizedBox(height: 24),
              _buildRecentEntries(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
