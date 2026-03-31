class AssessmentResult {
  final String id;
  final String userId;
  final String type; // 'PHQ9' or 'GAD7'
  final List<int> answers;
  final int score;
  final String severity;
  final String recommendation;
  final DateTime createdAt;

  AssessmentResult({
    required this.id,
    required this.userId,
    required this.type,
    required this.answers,
    required this.score,
    required this.severity,
    required this.recommendation,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'answers': answers,
      'score': score,
      'severity': severity,
      'recommendation': recommendation,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AssessmentResult.fromMap(String id, Map<String, dynamic> map) {
    return AssessmentResult(
      id: id,
      userId: map['userId'] ?? '',
      type: map['type'] ?? 'PHQ9',
      answers: List<int>.from(map['answers'] ?? []),
      score: map['score'] ?? 0,
      severity: map['severity'] ?? 'Minimal',
      recommendation: map['recommendation'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
