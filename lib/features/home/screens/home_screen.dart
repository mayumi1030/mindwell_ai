import 'package:flutter/material.dart';
import '../../mood/screens/mood_tracker_screen.dart';
import '../../journal/screens/journal_screen.dart';
import '../../calm/screens/calm_screen.dart';
import '../../help/screens/crisis_screen.dart';
import '../../settings/screens/settings_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const Color _primaryGreen = Color(0xFF2D9B6F);
  static const Color _textMuted = Color(0xFF9E9E9E);
  static const Color _background = Color(0xFFF5F4EF);

  List<Widget> get _screens => [
    DashboardScreen(
      onNavigate: (index) => setState(() => _currentIndex = index),
    ),
    const MoodTrackerScreen(),
    const JournalScreen(),
    const CalmScreen(),
    const CrisisScreen(),
    const SettingsScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.grid_view_rounded, label: 'HOME'),
    _NavItem(icon: Icons.sentiment_satisfied_alt_outlined, label: 'MOOD'),
    _NavItem(icon: Icons.menu_book_outlined, label: 'JOURNAL'),
    _NavItem(icon: Icons.air_outlined, label: 'CALM'),
    _NavItem(icon: Icons.support_agent_outlined, label: 'HELP'),
    _NavItem(icon: Icons.settings_outlined, label: 'SETTINGS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isActive = _currentIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: isActive ? _primaryGreen : _textMuted,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isActive ? _primaryGreen : _textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
