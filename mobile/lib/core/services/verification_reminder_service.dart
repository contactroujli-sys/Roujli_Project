import 'dart:async';
import 'package:flutter/material.dart';
import '../../shared/services/storage_service.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart' show VerifyEmailScreen;
import '../../features/auth/presentation/screens/verify_email_screen.dart';

class VerificationReminderService {
  static const Duration reminderInterval = Duration(hours: 24); // Remind every 24 hours
  static Timer? _reminderTimer;

  static void startPeriodicReminders(BuildContext context) {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkAndShowReminder(context);
    });
  }

  static void stopPeriodicReminders() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
  }

  static Future<void> _checkAndShowReminder(BuildContext context) async {
    final hasSkipped = await StorageService.hasSkippedVerification();
    if (!hasSkipped) return;

    final lastReminderShown = await StorageService.getLastReminderShown();
    final now = DateTime.now();

    if (lastReminderShown != null) {
      final lastReminder = DateTime.parse(lastReminderShown);
      final timeSinceLastReminder = now.difference(lastReminder);

      if (timeSinceLastReminder < reminderInterval) {
        return; // Not time to show reminder yet
      }
    }

    // Show reminder
    if (context.mounted) {
      showVerificationReminder(context);
      await StorageService.setLastReminderShown(now.toIso8601String());
    }
  }

  static void showVerificationReminder(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Complete Your Verification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'You skipped email verification. Verify your email to access all features and keep your account secure.',
          style: TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Later',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Get pending verification email and navigate to verification screen
              final email = await StorageService.getPendingVerificationEmail();
              if (email != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifyEmailScreen(email: email),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8B923),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Verify Now',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool> shouldShowVerificationReminder() async {
    final hasSkipped = await StorageService.hasSkippedVerification();
    if (!hasSkipped) return false;

    final lastReminderShown = await StorageService.getLastReminderShown();
    if (lastReminderShown == null) return true;

    final lastReminder = DateTime.parse(lastReminderShown);
    final timeSinceLastReminder = DateTime.now().difference(lastReminder);

    return timeSinceLastReminder >= reminderInterval;
  }
}
