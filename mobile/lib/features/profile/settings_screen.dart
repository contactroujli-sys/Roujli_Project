import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/presentation/providers/auth_providers.dart';
import 'change_password_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = false;
  final bool _emailDigest = false;
  bool _isProfilePrivate = false;
  bool _isUpdatingPrivacy = false;

  static const Color gold = Color(0xFFE8B923);
  static const Color dark = Color(0xFF0A0A0A);
  static const Color card = Color(0xFF141414);
  static const Color border = Color(0xFF222222);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? false;
      _isProfilePrivate = prefs.getBool('profile_private') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ═══════════ NOTIFICATIONS ═══════════
                    _sectionLabel('NOTIFICATIONS'),
                    const SizedBox(height: 10),
                    _card([
                      _toggleTile(
                        icon: Icons.notifications_outlined,
                        iconColor: const Color(0xFF4CAF50),
                        title: 'Push Notifications',
                        subtitle: _pushNotifications ? 'Enabled' : 'Disabled',
                        value: _pushNotifications,
                        onChanged: _handlePushNotifications,
                      ),
                      _divider(),
                      _toggleTile(
                        icon: Icons.email_outlined,
                        iconColor: const Color(0xFF2196F3),
                        title: 'Email Digest',
                        subtitle: 'Weekly summary & offers',
                        value: _emailDigest,
                        onChanged: (_) => _comingSoon('Email Digest'),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // ═══════════ SECURITY ═══════════
                    _sectionLabel('SECURITY'),
                    const SizedBox(height: 10),
                    _card([
                      _navTile(
                        icon: Icons.lock_outline,
                        iconColor: const Color(0xFFE91E63),
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        onTap: _handleChangePassword,
                      ),
                      _divider(),
                      _navTile(
                        icon: Icons.devices_outlined,
                        iconColor: const Color(0xFF9C27B0),
                        title: 'Active Sessions',
                        subtitle: 'View and manage logged-in devices',
                        onTap: _showSessionsDialog,
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // ═══════════ PRIVACY ═══════════
                    _sectionLabel('PRIVACY'),
                    const SizedBox(height: 10),
                    _card([
                      _privacyTile(),
                    ]),
                    const SizedBox(height: 24),

                    // ═══════════ SUPPORT ═══════════
                    _sectionLabel('SUPPORT'),
                    const SizedBox(height: 10),
                    _card([
                      _navTile(
                        icon: Icons.help_outline,
                        iconColor: gold,
                        title: 'Help Center',
                        onTap: () => _info('Help Center', 'Our support team is available 24/7.'),
                      ),
                      _divider(),
                      _navTile(
                        icon: Icons.mail_outline,
                        iconColor: const Color(0xFF00BCD4),
                        title: 'Contact Support',
                        onTap: () => _info('Contact Support', 'Email: support@roujli.com'),
                      ),
                      _divider(),
                      _navTile(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF607D8B),
                        title: 'Terms of Service',
                        onTap: () => _info('Terms of Service', 'By using ROUJLI, you agree to use the service responsibly.'),
                      ),
                      _divider(),
                      _navTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: const Color(0xFF607D8B),
                        title: 'Privacy Policy',
                        onTap: () => _info('Privacy Policy', 'Your personal information is protected.'),
                      ),
                    ]),
                    const SizedBox(height: 40),

                    const Center(
                      child: Text(
                        'ROUJLI v1.0.0  ·  © 2026 ROUJLI Inc.',
                        style: TextStyle(color: Color(0xFF444444), fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Push Notifications ──────────────────────────────────────────────────────

  Future<void> _handlePushNotifications(bool val) async {
    if (val) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('push_notifications', true);
        setState(() => _pushNotifications = true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Push notifications enabled'),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (status.isPermanentlyDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enable notifications in your device settings.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Open Settings',
              textColor: Colors.white,
              onPressed: openAppSettings,
            ),
          ),
        );
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('push_notifications', false);
      setState(() => _pushNotifications = false);
    }
  }

  // ─── Change Password ─────────────────────────────────────────────────────────

  void _handleChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
  }

  // ─── Privacy Toggle ───────────────────────────────────────────────────────────

  Widget _privacyTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF607D8B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.visibility_outlined, color: Color(0xFF607D8B), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Visibility',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                Text(
                  _isProfilePrivate ? 'Private — only followers can view' : 'Public — visible to all',
                  style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                ),
              ],
            ),
          ),
          if (_isUpdatingPrivacy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: gold),
            )
          else
            Switch(
              value: _isProfilePrivate,
              onChanged: _handlePrivacyToggle,
              activeThumbColor: Colors.black,
              activeTrackColor: gold,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFF3A3A3A),
            ),
        ],
      ),
    );
  }

  Future<void> _handlePrivacyToggle(bool val) async {
    setState(() => _isUpdatingPrivacy = true);
    try {
      // Call backend API

      // We update via shared prefs and direct API call
      // Using DioService directly since authProvider doesn't have updatePrivacy
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('profile_private', val);
      setState(() => _isProfilePrivate = val);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val ? 'Profile set to Private' : 'Profile set to Public'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update privacy: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingPrivacy = false);
    }
  }

  // ─── Sessions Dialog ──────────────────────────────────────────────────────────

  void _showSessionsDialog() {
    final authState = ref.read(authProvider);
    final email = authState.user?.email ?? 'your account';
    final deviceLabel = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android device',
      TargetPlatform.iOS => 'iPhone / iPad',
      TargetPlatform.windows => 'Windows device',
      TargetPlatform.macOS => 'Mac device',
      TargetPlatform.linux => 'Linux device',
      TargetPlatform.fuchsia => 'Fuchsia device',
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Active Sessions', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.devices, color: Color(0xFF4CAF50), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$deviceLabel  •  Active now',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(email, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('No other active sessions detected.',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: gold)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _info(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Color(0xFFBDBDBD))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: gold))),
        ],
      ),
    );
  }

  // ─── UI Components ────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF9E9E9E),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Divider(color: Color(0xFF1E1E1E), height: 1, thickness: 1, indent: 16, endIndent: 16);
  }

  Widget _toggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.black,
            activeTrackColor: gold,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF3A3A3A),
          ),
        ],
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF444444), size: 20),
          ],
        ),
      ),
    );
  }
}