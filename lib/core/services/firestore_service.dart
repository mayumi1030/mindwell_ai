import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/mood_entry.dart';
import '../../models/journal_entry.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Mood Entries ─────────────────────────────────────────────

  // Save a mood entry
  Future<void> saveMoodEntry(MoodEntry entry) async {
    await _db
        .collection('users')
        .doc(entry.userId)
        .collection('mood_entries')
        .add(entry.toMap());
  }

  // Get all mood entries for a user (latest first)
  Future<List<MoodEntry>> getMoodEntries(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('mood_entries')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MoodEntry.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Get mood entries as a stream (real-time)
  Stream<List<MoodEntry>> getMoodEntriesStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('mood_entries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MoodEntry.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Check if user already logged mood today
  Future<bool> hasLoggedMoodToday(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toIso8601String();

    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('mood_entries')
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('createdAt', isLessThanOrEqualTo: endOfDay)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // ─── Journal Entries ──────────────────────────────────────────

  Future<void> saveJournalEntry(JournalEntry entry) async {
    await _db
        .collection('users')
        .doc(entry.userId)
        .collection('journal_entries')
        .add(entry.toMap());
  }

  Future<List<JournalEntry>> getJournalEntries(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('journal_entries')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => JournalEntry.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<JournalEntry>> getJournalEntriesStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('journal_entries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JournalEntry.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
