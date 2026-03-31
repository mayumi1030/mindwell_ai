class JournalEntry {
  final String id;
  final String userId;
  final String content;
  final String sentimentLabel; // POSITIVE / NEUTRAL / NEGATIVE
  final String sentimentEmoji;
  final double sentimentScore;
  final List<String> keywords;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.content,
    required this.sentimentLabel,
    required this.sentimentEmoji,
    required this.sentimentScore,
    required this.keywords,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'sentimentLabel': sentimentLabel,
      'sentimentEmoji': sentimentEmoji,
      'sentimentScore': sentimentScore,
      'keywords': keywords,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(String id, Map<String, dynamic> map) {
    return JournalEntry(
      id: id,
      userId: map['userId'] ?? '',
      content: map['content'] ?? '',
      sentimentLabel: map['sentimentLabel'] ?? 'NEUTRAL',
      sentimentEmoji: map['sentimentEmoji'] ?? '😶',
      sentimentScore: (map['sentimentScore'] ?? 0.0).toDouble(),
      keywords: List<String>.from(map['keywords'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
