import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/mood_entry.dart';
import '../../assessment/screens/assessment_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<MoodEntry> _entries = [];
  bool _isLoading = true;

  static const Color _background = Color(0xFFF5F4EF);
  static const Color _primaryGreen = Color(0xFF2D9B6F);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF6B6B6B);
  static const Color _cardBg = Color(0xFFFFFFFF);

  User? get _user => FirebaseAuth.instance.currentUser;
  String get _userId => _user?.uid ?? '';
  String get _userName => _user?.displayName ?? 'there';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await _firestoreService.getMoodEntries(_userId);
    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  int get _streak {
    if (_entries.isEmpty) return 0;
    int streak = 0;
    DateTime checkDate = DateTime.now();
    for (int i = 0; i < _entries.length; i++) {
      final entryDate = _entries[i].createdAt;
      final entryDay = DateTime(entryDate.year, entryDate.month, entryDate.day);
      final checkDay = DateTime(checkDate.year, checkDate.month, checkDate.day);
      if (entryDay == checkDay ||
          entryDay == checkDay.subtract(const Duration(days: 1))) {
        streak++;
        checkDate = entryDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int? get _latestScore => _entries.isNotEmpty ? _entries.first.score : null;

  String? get _latestEmoji => _entries.isNotEmpty ? _entries.first.emoji : null;

  String get _dailyInsight {
    if (_latestScore == null) {
      return 'Welcome! Start by logging your mood today.';
    }
    if (_latestScore! >= 8) {
      return "That's great to hear you're feeling so good! Keep nurturing that positive momentum by doing something small today that brings you joy.";
    }
    if (_latestScore! >= 6) {
      return "You're doing well! Consider taking a short mindfulness break to maintain your positive energy throughout the day.";
    }
    if (_latestScore! >= 4) {
      return "It's okay to have moderate days. Try the 4-7-8 breathing exercise in the Calm tab to lift your mood.";
    }
    return "It looks like you're having a tough time. Remember, you're not alone. Consider reaching out to someone you trust or visiting the Help tab.";
  }

  List<MoodEntry> get _chartEntries {
    final recent = _entries.take(7).toList();
    return recent.reversed.toList();
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Ayubowan';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $_userName',
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'How are you feeling today?',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: _textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFCCEFE2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: _primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Insight',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dailyInsight,
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

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(18),
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
                const Text(
                  'MOOD STREAK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$_streak',
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'days',
                      style: TextStyle(fontSize: 14, color: _textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(18),
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
                const Text(
                  'LATEST MOOD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _latestEmoji ?? '—',
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _latestScore != null ? '${_latestScore}/10' : '—',
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodChart() {
    if (_chartEntries.isEmpty) return const SizedBox.shrink();

    final spots = _chartEntries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.score.toDouble());
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
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
          const Text(
            'MOOD TRENDS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E9E9E),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 10,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final entry = _chartEntries[spot.x.toInt()];
                        final date = entry.createdAt;
                        return LineTooltipItem(
                          '${_monthName(date.month)} ${date.day}\nscore : ${spot.y.toInt()}',
                          const TextStyle(
                            color: _textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: _primaryGreen,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 4,
                        color: _primaryGreen,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _primaryGreen.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
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
          const Text(
            'QUICK ACTIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E9E9E),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // ✅ New Journal Entry
          _buildActionTile(
            icon: Icons.add_circle_outline_rounded,
            iconColor: _primaryGreen,
            label: 'New Journal Entry',
            onTap: () {},
          ),

          const SizedBox(height: 10),

          // ✅ PHQ-9 Test
          _buildActionTile(
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFF5C6BC0),
            label: 'Take PHQ-9 Test',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AssessmentScreen(type: 'PHQ9'),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ✅ GAD-7 Test
          _buildActionTile(
            icon: Icons.psychology_outlined,
            iconColor: const Color(0xFF2D9B6F),
            label: 'Take GAD-7 Test',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AssessmentScreen(type: 'GAD7'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F4EF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _textDark,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2D9B6F)),
              )
            : RefreshIndicator(
                color: _primaryGreen,
                onRefresh: _loadEntries,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      _buildGreeting(),
                      const SizedBox(height: 24),
                      _buildInsightCard(),
                      const SizedBox(height: 16),
                      _buildStatsRow(),
                      const SizedBox(height: 16),
                      _buildMoodChart(),
                      const SizedBox(height: 16),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
