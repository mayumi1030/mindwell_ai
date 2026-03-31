import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/phq9_scorer.dart';
import '../../../core/utils/gad7_scorer.dart';
import '../../../models/assessment_result.dart';
import 'results_screen.dart';

class AssessmentScreen extends StatefulWidget {
  final String type; // 'PHQ9' or 'GAD7'

  const AssessmentScreen({super.key, required this.type});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _currentQuestion = 0;
  late List<int?> _answers;
  bool _isSaving = false;

  static const Color _background = Color(0xFFF5F4EF);
  static const Color _primaryGreen = Color(0xFF2D9B6F);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF6B6B6B);
  static const Color _cardBg = Color(0xFFFFFFFF);

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  List<String> get _questions =>
      widget.type == 'PHQ9' ? PHQ9Scorer.questions : GAD7Scorer.questions;

  List<String> get _options =>
      widget.type == 'PHQ9' ? PHQ9Scorer.options : GAD7Scorer.options;

  String get _title => widget.type == 'PHQ9' ? 'PHQ-9 Test' : 'GAD-7 Test';

  String get _subtitle => widget.type == 'PHQ9'
      ? 'Patient Health Questionnaire'
      : 'Generalized Anxiety Disorder';

  @override
  void initState() {
    super.initState();
    _answers = List.filled(_questions.length, null);
  }

  double get _progress => (_currentQuestion + 1) / _questions.length;

  Future<void> _submitAssessment() async {
    setState(() => _isSaving = true);

    final answers = _answers.map((a) => a ?? 0).toList();
    final score = widget.type == 'PHQ9'
        ? PHQ9Scorer.calculateScore(answers)
        : GAD7Scorer.calculateScore(answers);

    final severity = widget.type == 'PHQ9'
        ? PHQ9Scorer.getSeverity(score)
        : GAD7Scorer.getSeverity(score);

    final recommendation = widget.type == 'PHQ9'
        ? PHQ9Scorer.getRecommendation(score)
        : GAD7Scorer.getRecommendation(score);

    final result = AssessmentResult(
      id: '',
      userId: _userId,
      type: widget.type,
      answers: answers,
      score: score,
      severity: severity,
      recommendation: recommendation,
      createdAt: DateTime.now(),
    );

    try {
      await _firestoreService.saveAssessmentResult(result);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResultsScreen(result: result)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving result: $e'),
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

  void _selectAnswer(int value) {
    setState(() => _answers[_currentQuestion] = value);

    // Auto advance after short delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      if (_currentQuestion < _questions.length - 1) {
        setState(() => _currentQuestion++);
      } else {
        _submitAssessment();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionNumber = _currentQuestion + 1;
    final totalQuestions = _questions.length;
    final percent = ((_progress) * 100).toInt();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    _title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: _textMuted,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progress row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'QUESTION $questionNumber OF $totalQuestions',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9E9E9E),
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        _primaryGreen,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Question card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Question card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
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
                          // Preamble
                          const Text(
                            'Over the last 2 weeks, how often have you been bothered by:',
                            style: TextStyle(
                              fontSize: 15,
                              color: _textMuted,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Question
                          Text(
                            _questions[_currentQuestion],
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Answer options
                          ...List.generate(_options.length, (index) {
                            final isSelected =
                                _answers[_currentQuestion] == index;
                            return GestureDetector(
                              onTap: () => _selectAnswer(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _primaryGreen.withOpacity(0.08)
                                      : const Color(0xFFF5F4EF),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? _primaryGreen
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _options[index],
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: isSelected
                                              ? _primaryGreen
                                              : _textDark,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: _primaryGreen,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Loading indicator when submitting
                    if (_isSaving)
                      const CircularProgressIndicator(color: _primaryGreen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
