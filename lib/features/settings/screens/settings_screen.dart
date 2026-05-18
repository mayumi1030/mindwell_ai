import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _notificationsEnabled = true;
  bool _isExporting = false;
  bool _isDeleting = false;

  User? get _user => FirebaseAuth.instance.currentUser;
  String get _userId => _user?.uid ?? '';
  String get _userName => _user?.displayName ?? 'User';
  String get _userEmail => _user?.email ?? '';

  Future<void> _handleSignOut() async {
    final confirm = await _showConfirmDialog(
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      confirmGradient: const LinearGradient(
          colors: [Color(0xFF5936B4), Color(0xFFC427FB)]),
    );
    if (!confirm) return;
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _handleExportData() async {
    setState(() => _isExporting = true);
    try {
      final moods = await _firestoreService.getMoodEntries(_userId);
      final journals = await _firestoreService.getJournalEntries(_userId);
      final phq9 = await _firestoreService.getAssessmentResults(_userId, 'PHQ9');
      final gad7 = await _firestoreService.getAssessmentResults(_userId, 'GAD7');
      final exportData = {
        'exported_at': DateTime.now().toIso8601String(),
        'user': {'name': _userName, 'email': _userEmail},
        'mood_entries': moods.map((e) => {
          'score': e.score, 'emoji': e.emoji, 'note': e.note,
          'date': e.createdAt.toIso8601String(),
        }).toList(),
        'journal_entries': journals.map((e) => {
          'content': e.content, 'sentiment': e.sentimentLabel,
          'keywords': e.keywords, 'date': e.createdAt.toIso8601String(),
        }).toList(),
        'assessments': {
          'PHQ9': phq9.map((e) => {
            'score': e.score, 'severity': e.severity,
            'date': e.createdAt.toIso8601String(),
          }).toList(),
          'GAD7': gad7.map((e) => {
            'score': e.score, 'severity': e.severity,
            'date': e.createdAt.toIso8601String(),
          }).toList(),
        },
      };
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      if (!mounted) return;
      _showDataExportDialog(jsonString);
    } catch (e) {
      _showSnackBar('Export failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await _showConfirmDialog(
      title: 'Delete Account',
      message:
          'This permanently deletes your account and ALL data. This cannot be undone.',
      confirmText: 'Delete Forever',
      confirmGradient: const LinearGradient(
          colors: [Color(0xFFFF6B8A), Color(0xFFC427FB)]),
    );
    if (!confirm) return;
    setState(() => _isDeleting = true);
    try {
      await _firestoreService.deleteAllUserData(_userId);
      await _user?.delete();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showSnackBar('Delete failed. Re-login and try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required LinearGradient confirmGradient,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1740), Color(0xFF16103A)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB8B0E8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15)),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: Color(0xFFB8B0E8),
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: confirmGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            confirmText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  void _showDataExportDialog(String jsonData) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1740), Color(0xFF16103A)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Data Export',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Copy and save as a .json file.',
                style: TextStyle(fontSize: 13, color: Color(0xFFB8B0E8)),
              ),
              const SizedBox(height: 14),
              Container(
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.1)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    jsonData,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFFD4CCFF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Center(
                    child: Text(
                      'Close',
                      style: TextStyle(
                          color: Color(0xFFB8B0E8),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFFF6B8A)
            : const Color(0xFF5936B4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFB8B0E8),
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _buildSettingsTile({
    required IconData icon,
    required LinearGradient iconGradient,
    required Color glowColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: iconGradient,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB8B0E8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withOpacity(0.25),
                      size: 20,
                    ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: Colors.white.withOpacity(0.07)),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(children: children),
      );

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
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFE0D9FF), Color(0xFFF7CBFD)],
                ).createShader(bounds),
                child: const Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage your account & preferences',
                style: TextStyle(fontSize: 14, color: Color(0xFFB8B0E8)),
              ),

              const SizedBox(height: 28),

              // Profile card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5936B4), Color(0xFF48319D)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5936B4).withOpacity(0.5),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _userEmail,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('PREFERENCES'),
              _buildCard(children: [
                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  iconGradient: const LinearGradient(
                      colors: [Color(0xFF3658B1), Color(0xFF5936B4)]),
                  glowColor: const Color(0xFF3658B1),
                  title: 'Daily Reminders',
                  subtitle: 'Get reminded to log your mood',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    activeColor: const Color(0xFFC427FB),
                    onChanged: (val) =>
                        setState(() => _notificationsEnabled = val),
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.lock_outline_rounded,
                  iconGradient: const LinearGradient(
                      colors: [Color(0xFFFFB347), Color(0xFFC427FB)]),
                  glowColor: const Color(0xFFFFB347),
                  title: 'App Lock',
                  subtitle: 'Biometric or PIN protection',
                  showDivider: false,
                  onTap: () =>
                      _showSnackBar('App lock coming in next update!'),
                ),
              ]),

              const SizedBox(height: 20),

              _buildSectionTitle('PRIVACY & DATA'),
              _buildCard(children: [
                _buildSettingsTile(
                  icon: Icons.download_outlined,
                  iconGradient: const LinearGradient(
                      colors: [Color(0xFF4ADEAA), Color(0xFF3658B1)]),
                  glowColor: const Color(0xFF4ADEAA),
                  title: 'Export My Data',
                  subtitle: 'Download all your data as JSON',
                  trailing: _isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFC427FB),
                          ),
                        )
                      : Icon(Icons.chevron_right_rounded,
                          color: Colors.white.withOpacity(0.25), size: 20),
                  onTap: _isExporting ? null : _handleExportData,
                ),
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  iconGradient: const LinearGradient(
                      colors: [Color(0xFF5936B4), Color(0xFFC427FB)]),
                  glowColor: const Color(0xFF5936B4),
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  showDivider: false,
                  onTap: () => _showSnackBar('Opening privacy policy...'),
                ),
              ]),

              const SizedBox(height: 20),

              _buildSectionTitle('ABOUT'),
              _buildCard(children: [
                _buildSettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconGradient: const LinearGradient(
                      colors: [Color(0xFF48319D), Color(0xFF3658B1)]),
                  glowColor: const Color(0xFF48319D),
                  title: 'App Version',
                  subtitle: 'MindWell AI v1.0.0',
                  trailing: const SizedBox.shrink(),
                ),
                _buildSettingsTile(
                  icon: Icons.favorite_outline_rounded,
                  iconGradient: const LinearGradient(
                      colors: [Color(0xFFFF6B8A), Color(0xFFC427FB)]),
                  glowColor: const Color(0xFFFF6B8A),
                  title: 'Mental Health Disclaimer',
                  subtitle: 'This app is not a substitute for therapy',
                  showDivider: false,
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A1740), Color(0xFF16103A)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Disclaimer',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'MindWell AI is a self-help tool for emotional wellbeing. It is not a substitute for professional mental health treatment or medical advice. If you are in crisis, please contact a qualified professional immediately.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFB8B0E8),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              child: Container(
                                width: double.infinity,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5936B4),
                                      Color(0xFFC427FB),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text(
                                    'I Understand',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 20),

              _buildSectionTitle('ACCOUNT'),
              _buildCard(children: [
                _buildSettingsTile(
                  icon: Icons.logout_rounded,
                  iconGradient: const LinearGradient(
                      colors: [Color(0xFF3658B1), Color(0xFF5936B4)]),
                  glowColor: const Color(0xFF3658B1),
                  title: 'Sign Out',
                  onTap: _handleSignOut,
                ),
                _buildSettingsTile(
                  icon: Icons.delete_outline_rounded,
                  iconGradient: const LinearGradient(
                      colors: [Color(0xFFFF6B8A), Color(0xFFC427FB)]),
                  glowColor: const Color(0xFFFF6B8A),
                  title: 'Delete Account',
                  subtitle: 'Permanently delete all your data',
                  showDivider: false,
                  trailing: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFF6B8A),
                          ),
                        )
                      : Icon(Icons.chevron_right_rounded,
                          color: Colors.white.withOpacity(0.25), size: 20),
                  onTap: _isDeleting ? null : _handleDeleteAccount,
                ),
              ]),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
