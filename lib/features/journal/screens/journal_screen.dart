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
          backgroundColor: const Color(0xFF5936B4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFFF6B8A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Color _sentimentColor(String label) {
    switch (label) {
      case 'POSITIVE':
        return const Color(0xFF4ADEAA);
      case 'NEGATIVE':
        return const Color(0xFFFF6B8A);
      default:
        return const Color(0xFFFFB347);
    }
  }

  LinearGradient _sentimentGradient(String label) {
    switch (label) {
      case 'POSITIVE':
        return const LinearGradient(
            colors: [Color(0xFF4ADEAA), Color(0xFF3658B1)]);
      case 'NEGATIVE':
        return const LinearGradient(
            colors: [Color(0xFFFF6B8A), Color(0xFFC427FB)]);
      default:
        return const LinearGradient(
            colors: [Color(0xFFFFB347), Color(0xFF5936B4)]);
    }
  }

  Widget _buildNewEntryCard() {
    return Container(
      padding: const EdgeInsets.all(22),
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
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
              color: Color(0xFFB8B0E8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _entryController,
            maxLines: 6,
            style: const TextStyle(
                fontSize: 15, color: Colors.white, height: 1.6),
            decoration: InputDecoration(
              hintText:
                  "What's on your mind? Your entries are private.",
              hintStyle: const TextStyle(
                color: Color(0xFF6B6494),
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                    color: Color(0xFFC427FB), width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isSaving ? null : _saveEntry,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5936B4), Color(0xFFC427FB)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC427FB).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Save Entry',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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
            child: CircularProgressIndicator(
                color: Color(0xFFC427FB), strokeWidth: 2),
          );
        }

        final entries = snapshot.data ?? [];

        if (entries.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Colors.white.withOpacity(0.12)),
            ),
            child: const Center(
              child: Column(
                children: [
                  Text('📓', style: TextStyle(fontSize: 36)),
                  SizedBox(height: 12),
                  Text(
                    'No entries yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Start writing your first journal entry above.',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFFB8B0E8)),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                color: Color(0xFFB8B0E8),
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
    final sentColor = _sentimentColor(entry.sentimentLabel);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_monthName(date.month)} ${date.day}, ${date.year}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB8B0E8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: _sentimentGradient(entry.sentimentLabel),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${entry.sentimentEmoji} ${entry.sentimentLabel}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.content.length > 120
                ? '${entry.content.substring(0, 120)}...'
                : entry.content,
            style: const TextStyle(
                fontSize: 14, color: Color(0xFFD4CCFF), height: 1.5),
          ),
          if (entry.keywords.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entry.keywords
                  .map((kw) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5936B4).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF5936B4).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          kw,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFE0D9FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

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
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFE0D9FF), Color(0xFFF7CBFD)],
                ).createShader(bounds),
                child: const Text(
                  'Journal',
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
                'Safe space for your thoughts',
                style: TextStyle(fontSize: 14, color: Color(0xFFB8B0E8)),
              ),
              const SizedBox(height: 24),
              _buildNewEntryCard(),
              const SizedBox(height: 24),
              _buildRecentEntries(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
