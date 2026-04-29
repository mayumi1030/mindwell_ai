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

  static const Color _background = Color(0xFFF5F4EF);
  static const Color _primaryGreen = Color(0xFF2D9B6F);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF6B6B6B);
  static const Color _cardBg = Color(0xFFFFFFFF);

  User? get _user => FirebaseAuth.instance.currentUser;
  String get _userId => _user?.uid ?? '';
  String get _userName => _user?.displayName ?? 'User';
  String get _userEmail => _user?.email ?? '';

  // ─── Sign Out ─────────────────────────────────────────────────
  Future<void> _handleSignOut() async {
    final confirm = await _showConfirmDialog(
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      confirmColor: _primaryGreen,
    );
    if (!confirm) return;

    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ─── Export Data ──────────────────────────────────────────────
  Future<void> _handleExportData() async {
    setState(() => _isExporting = true);
    try {
      final moods = await _firestoreService.getMoodEntries(_userId);
      final journals = await _firestoreService.getJournalEntries(_userId);
      final phq9 = await _firestoreService.getAssessmentResults(
        _userId,
        'PHQ9',
      );
      final gad7 = await _firestoreService.getAssessmentResults(
        _userId,
        'GAD7',
      );

      final exportData = {
        'exported_at': DateTime.now().toIso8601String(),
        'user': {'name': _userName, 'email': _userEmail},
        'mood_entries': moods
            .map(
              (e) => {
                'score': e.score,
                'emoji': e.emoji,
                'note': e.note,
                'date': e.createdAt.toIso8601String(),
              },
            )
            .toList(),
        'journal_entries': journals
            .map(
              (e) => {
                'content': e.content,
                'sentiment': e.sentimentLabel,
                'keywords': e.keywords,
                'date': e.createdAt.toIso8601String(),
              },
            )
            .toList(),
        'assessments': {
          'PHQ9': phq9
              .map(
                (e) => {
                  'score': e.score,
                  'severity': e.severity,
                  'date': e.createdAt.toIso8601String(),
                },
              )
              .toList(),
          'GAD7': gad7
              .map(
                (e) => {
                  'score': e.score,
                  'severity': e.severity,
                  'date': e.createdAt.toIso8601String(),
                },
              )
              .toList(),
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

  // ─── Delete Account ───────────────────────────────────────────
  Future<void> _handleDeleteAccount() async {
    final confirm = await _showConfirmDialog(
      title: 'Delete Account',
      message:
          'This will permanently delete your account and ALL your data including mood entries, journal entries, and assessment results. This cannot be undone.',
      confirmText: 'Delete Forever',
      confirmColor: const Color(0xFFE57373),
    );
    if (!confirm) return;

    setState(() => _isDeleting = true);
    try {
      // Delete all Firestore data
      await _firestoreService.deleteAllUserData(_userId);
      // Delete Firebase Auth account
      await _user?.delete();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showSnackBar(
        'Delete failed. Please re-login and try again.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B6B6B),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9E9E9E)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: confirmColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showDataExportDialog(String jsonData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Your Data Export',
          style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your data has been compiled below. Copy and save it as a .json file.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B6B6B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F4EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Text(
                  jsonData,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF9E9E9E)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFE57373) : _primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9E9E9E),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
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
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
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
                          color: _textDark,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey.shade300,
                      size: 20,
                    ),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
      child: Column(children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Header
              const Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage your account & preferences',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: _textMuted,
                ),
              ),

              const SizedBox(height: 28),

              // Profile card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F0),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _primaryGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _userEmail,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Preferences section
              _buildSectionTitle('PREFERENCES'),
              _buildCard(
                children: [
                  _buildSettingsTile(
                    icon: Icons.notifications_outlined,
                    iconColor: const Color(0xFF5C6BC0),
                    iconBg: const Color(0xFFE8EAF6),
                    title: 'Daily Reminders',
                    subtitle: 'Get reminded to log your mood',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      activeColor: _primaryGreen,
                      onChanged: (val) =>
                          setState(() => _notificationsEnabled = val),
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.lock_outline_rounded,
                    iconColor: const Color(0xFFEF6C00),
                    iconBg: const Color(0xFFFFF3E0),
                    title: 'App Lock',
                    subtitle: 'Biometric or PIN protection',
                    showDivider: false,
                    onTap: () =>
                        _showSnackBar('App lock coming in next update!'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Privacy section
              _buildSectionTitle('PRIVACY & DATA'),
              _buildCard(
                children: [
                  _buildSettingsTile(
                    icon: Icons.download_outlined,
                    iconColor: _primaryGreen,
                    iconBg: const Color(0xFFE8F5F0),
                    title: 'Export My Data',
                    subtitle: 'Download all your data as JSON',
                    trailing: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF2D9B6F),
                            ),
                          )
                        : Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey.shade300,
                            size: 20,
                          ),
                    onTap: _isExporting ? null : _handleExportData,
                  ),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: const Color(0xFF5C6BC0),
                    iconBg: const Color(0xFFE8EAF6),
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    showDivider: false,
                    onTap: () => _showSnackBar('Opening privacy policy...'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // About section
              _buildSectionTitle('ABOUT'),
              _buildCard(
                children: [
                  _buildSettingsTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: _textMuted,
                    iconBg: Colors.grey.shade100,
                    title: 'App Version',
                    subtitle: 'MindWell AI v1.0.0',
                    trailing: const SizedBox.shrink(),
                  ),
                  _buildSettingsTile(
                    icon: Icons.favorite_border_rounded,
                    iconColor: const Color(0xFFE57373),
                    iconBg: const Color(0xFFFFF0F0),
                    title: 'Mental Health Disclaimer',
                    subtitle: 'This app is not a substitute for therapy',
                    showDivider: false,
                    onTap: () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          'Disclaimer',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        content: const Text(
                          'MindWell AI is a self-help tool designed to support emotional wellbeing. It is not a substitute for professional mental health treatment, therapy, or medical advice. If you are experiencing a mental health crisis, please contact a qualified professional or call a helpline immediately.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B6B6B),
                            height: 1.5,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                color: Color(0xFF2D9B6F),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Account section
              _buildSectionTitle('ACCOUNT'),
              _buildCard(
                children: [
                  _buildSettingsTile(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFF5C6BC0),
                    iconBg: const Color(0xFFE8EAF6),
                    title: 'Sign Out',
                    onTap: _handleSignOut,
                  ),
                  _buildSettingsTile(
                    icon: Icons.delete_outline_rounded,
                    iconColor: const Color(0xFFE57373),
                    iconBg: const Color(0xFFFFF0F0),
                    title: 'Delete Account',
                    subtitle: 'Permanently delete all your data',
                    showDivider: false,
                    trailing: _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFE57373),
                            ),
                          )
                        : Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey.shade300,
                            size: 20,
                          ),
                    onTap: _isDeleting ? null : _handleDeleteAccount,
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
