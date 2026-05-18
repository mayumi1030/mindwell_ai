import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/mood_entry.dart';
import '../../assessment/screens/assessment_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<MoodEntry> _entries = [];
  bool _isLoading = true;

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
    if (_latestScore == null)
      return 'Welcome! Start by logging your mood today.';
    if (_latestScore! >= 8)
      return "That's great! Keep nurturing that positive momentum by doing something that brings you joy today.";
    if (_latestScore! >= 6)
      return "You're doing well! Consider a short mindfulness break to maintain your positive energy.";
    if (_latestScore! >= 4)
      return "It's okay to have moderate days. Try the 4-7-8 breathing exercise in the Calm tab.";
    return "It looks like you're having a tough time. You're not alone. Visit the Help tab or reach out to someone you trust.";
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
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFE0D9FF), Color(0xFFF7CBFD)],
          ).createShader(bounds),
          child: Text(
            '$greeting, $_userName 👋',
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'How are you feeling today?',
          style: TextStyle(fontSize: 14, color: Color(0xFFB8B0E8)),
        ),
      ],
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5936B4), Color(0xFF48319D), Color(0xFF3658B1)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5936B4).withOpacity(0.45),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFFF7CBFD),
              size: 22,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _dailyInsight,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFD4CCFF),
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
          child: _buildStatCard(
            label: 'MOOD STREAK',
            value: '$_streak',
            unit: 'days',
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFFB347),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildStatCard(
            label: 'LATEST MOOD',
            value: _latestEmoji ?? '—',
            unit: _latestScore != null ? '${_latestScore}/10' : '',
            icon: Icons.sentiment_satisfied_alt_outlined,
            iconColor: const Color(0xFF4ADEAA),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
            ),
            isEmoji: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required LinearGradient gradient,
    bool isEmoji = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB8B0E8),
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isEmoji)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Text(
                  unit,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB8B0E8),
                  ),
                ),
              ],
            ),
        ],
      ),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MOOD TRENDS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB8B0E8),
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5936B4).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF5936B4).withOpacity(0.5),
                  ),
                ),
                child: const Text(
                  'Last 7 days',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFE0D9FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
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
                    color: Colors.white.withOpacity(0.06),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
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
                          '${_monthName(date.month)} ${date.day}\n${entry.emoji} ${spot.y.toInt()}/10',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: '\n${entry.emoji}',
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5936B4), Color(0xFFC427FB)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 5,
                        color: const Color(0xFFC427FB),
                        strokeWidth: 2.5,
                        strokeColor: const Color(0xFF0E0C2A),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFC427FB).withOpacity(0.2),
                          const Color(0xFF5936B4).withOpacity(0.0),
                        ],
                      ),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
              color: Color(0xFFB8B0E8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          _buildActionTile(
            icon: Icons.add_circle_outline_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF4ADEAA), Color(0xFF3658B1)],
            ),
            label: 'New Journal Entry',
            onTap: () => widget.onNavigate(2),
          ),
          const SizedBox(height: 10),
          _buildActionTile(
            icon: Icons.trending_up_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF5936B4), Color(0xFFC427FB)],
            ),
            label: 'Take PHQ-9 Test',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AssessmentScreen(type: 'PHQ9'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildActionTile(
            icon: Icons.psychology_outlined,
            gradient: const LinearGradient(
              colors: [Color(0xFFC427FB), Color(0xFF3658B1)],
            ),
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
    required LinearGradient gradient,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.3),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1D47), Color(0xFF0E0C2A), Color(0xFF16103A)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background orb
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC427FB).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFC427FB),
                      strokeWidth: 2.5,
                    ),
                  )
                : RefreshIndicator(
                    color: const Color(0xFFC427FB),
                    backgroundColor: const Color(0xFF1A1740),
                    onRefresh: _loadEntries,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
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
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
