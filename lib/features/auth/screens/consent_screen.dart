import 'package:flutter/material.dart';
import '../../home/screens/home_screen.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _consentData = false;
  bool _consentTherapy = false;
  bool _consentAge = false;

  static const Color _background = Color(0xFFF5F4EF);
  static const Color _primaryGreen = Color(0xFF2D9B6F);
  static const Color _logoBackground = Color(0xFFCCEFE2);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF6B6B6B);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _warningBg = Color(0xFFFFF3F3);
  static const Color _warningBorder = Color(0xFFE57373);

  // All three must be checked to proceed
  bool get _allAgreed => _consentData && _consentTherapy && _consentAge;

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox({
    required bool value,
    required String text,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: value ? _primaryGreen.withOpacity(0.07) : _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? _primaryGreen : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                activeColor: _primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: value ? _textDark : _textMuted,
                  height: 1.5,
                  fontWeight: value ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 36),

                    // Logo + title
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: _logoBackground,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.favorite_border_rounded,
                              color: _primaryGreen,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Before you begin',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please read and agree to the following\nbefore using MindWell AI',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: _textMuted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Warning card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _warningBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _warningBorder.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: _warningBorder,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'MindWell AI is a self-help tool only. It is NOT a substitute for professional mental health therapy or medical advice. In a crisis, please contact a helpline immediately.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFB71C1C),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Info cards
                    _buildSectionCard(
                      icon: Icons.lock_outline_rounded,
                      iconColor: _primaryGreen,
                      iconBg: _logoBackground,
                      title: 'Your data is private',
                      body:
                          'Your journal entries are encrypted. Your emotional data is never sold or shared with third parties.',
                    ),

                    const SizedBox(height: 12),

                    _buildSectionCard(
                      icon: Icons.bar_chart_rounded,
                      iconColor: const Color(0xFF5C6BC0),
                      iconBg: const Color(0xFFE8EAF6),
                      title: 'AI-powered insights',
                      body:
                          'MindWell uses sentiment analysis to help you understand your emotional patterns. Results are informational only.',
                    ),

                    const SizedBox(height: 12),

                    _buildSectionCard(
                      icon: Icons.phone_in_talk_rounded,
                      iconColor: const Color(0xFFEF6C00),
                      iconBg: const Color(0xFFFFF3E0),
                      title: 'Crisis support available',
                      body:
                          'Sri Lankan helplines (NIMH 1926, Sumithrayo) are accessible anytime from the Help tab.',
                    ),

                    const SizedBox(height: 28),

                    // Consent checkboxes
                    const Text(
                      'PLEASE CONFIRM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildConsentCheckbox(
                      value: _consentTherapy,
                      text:
                          'I understand this app is not a substitute for professional therapy or medical treatment.',
                      onChanged: (val) =>
                          setState(() => _consentTherapy = val ?? false),
                    ),

                    const SizedBox(height: 10),

                    _buildConsentCheckbox(
                      value: _consentData,
                      text:
                          'I consent to my anonymized data being used to provide personalized insights within the app.',
                      onChanged: (val) =>
                          setState(() => _consentData = val ?? false),
                    ),

                    const SizedBox(height: 10),

                    _buildConsentCheckbox(
                      value: _consentAge,
                      text: 'I confirm that I am 16 years of age or older.',
                      onChanged: (val) =>
                          setState(() => _consentAge = val ?? false),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // Fixed bottom button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: _background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _allAgreed ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    disabledBackgroundColor: _primaryGreen.withOpacity(0.35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'I understand, let\'s continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }
}
