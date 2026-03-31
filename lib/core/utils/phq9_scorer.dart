class PHQ9Scorer {
  static const List<String> questions = [
    'Little interest or pleasure in doing things?',
    'Feeling down, depressed, or hopeless?',
    'Trouble falling or staying asleep, or sleeping too much?',
    'Feeling tired or having little energy?',
    'Poor appetite or overeating?',
    'Feeling bad about yourself — or that you are a failure?',
    'Trouble concentrating on things, such as reading or watching TV?',
    'Moving or speaking so slowly that other people could notice? Or being fidgety or restless?',
    'Thoughts that you would be better off dead or of hurting yourself?',
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
    if (score <= 19) return 'Moderately Severe';
    return 'Severe';
  }

  static String getRecommendation(int score) {
    if (score <= 4) {
      return 'Your score suggests minimal depression symptoms. Keep up your self-care routine and check in regularly.';
    }
    if (score <= 9) {
      return 'Your score suggests mild depression. Consider using the mindfulness exercises in the Calm tab and monitor your mood regularly.';
    }
    if (score <= 14) {
      return 'Your score suggests moderate depression. It may be helpful to speak with a mental health professional for guidance.';
    }
    if (score <= 19) {
      return 'Your score suggests moderately severe depression. We strongly recommend consulting a mental health professional.';
    }
    return 'Your score suggests severe depression. Please reach out to a mental health professional or crisis helpline immediately.';
  }

  static String getSeverityColor(int score) {
    if (score <= 4) return 'green';
    if (score <= 9) return 'teal';
    if (score <= 14) return 'orange';
    if (score <= 19) return 'deepOrange';
    return 'red';
  }
}
