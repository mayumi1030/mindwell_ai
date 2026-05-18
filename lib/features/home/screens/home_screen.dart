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
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1740), Color(0xFF16103A)],
          ),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
            BoxShadow(
              color: const Color(0xFF5936B4).withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isActive = _currentIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF5936B4),
                                    Color(0xFFC427FB),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC427FB)
                                        .withOpacity(0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(item.icon,
                                  size: 20, color: Colors.white),
                            )
                          else
                            Icon(
                              item.icon,
                              size: 22,
                              color: Colors.white.withOpacity(0.35),
                            ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isActive
                                  ? const Color(0xFFE0D9FF)
                                  : Colors.white.withOpacity(0.35),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
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
