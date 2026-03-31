class GAD7Scorer {
  static const List<String> questions = [
    'Feeling nervous, anxious, or on edge?',
    'Not being able to stop or control worrying?',
    'Worrying too much about different things?',
    'Trouble relaxing?',
    'Being so restless that it\'s hard to sit still?',
    'Becoming easily annoyed or irritable?',
    'Feeling afraid, as if something awful might happen?',
  ];

  static const List<String> options = [
    'Not at all',
    'Several days',
    'More than half the days',
    'Nearly every day',
  ];

  static int calculateScore(List<int> answers) {
    return answers.fold(0, (sum, answer) => sum + answer);
  }

  static String getSeverity(int score) {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Mild';
    if (score <= 14) return 'Moderate';
    return 'Severe';
  }

  static String getRecommendation(int score) {
    if (score <= 4) {
      return 'Your score suggests minimal anxiety. Continue practicing mindfulness and self-care regularly.';
    }
    if (score <= 9) {
      return 'Your score suggests mild anxiety. Try the breathing exercises in the Calm tab to manage stress.';
    }
    if (score <= 14) {
      return 'Your score suggests moderate anxiety. Consider speaking with a mental health professional for support.';
    }
    return 'Your score suggests severe anxiety. Please consult a mental health professional or contact a helpline.';
  }
}
