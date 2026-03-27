class MoodEntry {
  final String id;
  final String userId;
  final int score; // 1–10
  final String emoji; // emoji character
  final String note; // optional note
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.score,
    required this.emoji,
    required this.note,
    required this.createdAt,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'score': score,
      'emoji': emoji,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore map
  factory MoodEntry.fromMap(String id, Map<String, dynamic> map) {
    return MoodEntry(
      id: id,
      userId: map['userId'] ?? '',
      score: map['score'] ?? 1,
      emoji: map['emoji'] ?? '😐',
      note: map['note'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
