import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CrisisScreen extends StatelessWidget {
  const CrisisScreen({super.key});

  final List<Map<String, String>> _helplines = const [
    {
      'name': 'National Institute of Mental Health (NIMH)',
      'description': '24-hour mental health helpline in Sri Lanka.',
      'number': '1926',
    },
    {
      'name': 'Sumithrayo',
      'description': 'Emotional support and suicide prevention helpline.',
      'number': '0800 441 441',
    },
    {
      'name': 'CCS Sri Lanka',
      'description': 'Counselling and mental wellness support.',
      'number': '011 2696 441',
    },
    {
      'name': 'Sri Lanka Police Emergency',
      'description': 'For immediate physical danger or emergencies.',
      'number': '119',
    },
  ];

  Future<void> _callNumber(String number) async {
    final cleaned = number.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Header
              const Text(
                'Crisis Support',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'You are not alone. Help is available.',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFB8B0E8),
                ),
              ),

              const SizedBox(height: 24),

              // Emergency notice card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE57373).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE0E0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFE57373),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Notice',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB71C1C),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'If you are in immediate danger or having thoughts of self-harm, please call a helpline right away.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFC62828),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Helplines label
              const Text(
                'SRI LANKAN HELPLINES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E9E9E),
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              // Helpline cards
              ..._helplines.map(
                (helpline) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              helpline['name']!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              helpline['description']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: const Color(0xFFB8B0E8),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              helpline['number']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFC427FB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _callNumber(helpline['number']!),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC427FB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.phone_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Self-care reminder
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0x15FFFFFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💚', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Remember: seeking help is a sign of strength, not weakness. You deserve support.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2D6A4F),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
