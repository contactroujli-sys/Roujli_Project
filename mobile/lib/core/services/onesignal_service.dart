import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized OneSignal Service encapsulating all SDK operations
class OneSignalService {
  static const String appId = 'ae44e38f-8e13-44b0-81c3-8a8265d9581b';
  static const String _dialogShownKey = 'onesignal_verification_dialog_shown';
  static const String _explanationShownKey = 'roujli_notification_explanation_shown';

  static GlobalKey<NavigatorState>? navigatorKey;

  /// Initialize OneSignal SDK & setup observers
  static Future<void> init({GlobalKey<NavigatorState>? navKey}) async {
    navigatorKey = navKey;

    // Enable verbose logging during dev/debug
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Initialize OneSignal with App ID
    OneSignal.initialize(appId);

    // Register push subscription observer
    _setupSubscriptionObserver();
  }

  /// Register push subscription observer retained for lifetime of the app
  static void _setupSubscriptionObserver() {
    OneSignal.User.pushSubscription.addObserver((state) {
      _evaluateSubscription(state.current.id);
    });

    // Evaluate initial subscription status immediately at observer-registration time
    _evaluateSubscription(OneSignal.User.pushSubscription.id);
  }

  /// Evaluate if subscription ID is real and server-assigned (non-empty & not local-)
  static void _evaluateSubscription(String? subscriptionId) async {
    if (subscriptionId != null &&
        subscriptionId.isNotEmpty &&
        !subscriptionId.startsWith('local-')) {
      final prefs = await SharedPreferences.getInstance();
      final hasShown = prefs.getBool(_dialogShownKey) ?? false;
      if (!hasShown) {
        await prefs.setBool(_dialogShownKey, true);
        _showVerificationDialog();
      }
    }
  }

  /// Show OneSignal Integration Verification Dialog
  static void _showVerificationDialog() {
    final context = navigatorKey?.currentContext;
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVerificationDialog();
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Your OneSignal SDK integration is complete!'),
        content: const Text(
          'You can now send Push Notifications & In-App Messages through OneSignal. Tap below to enable push notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              requestPermission();
            },
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Show ROUJLI custom notification explanation modal when user logs in
  static Future<void> promptNotificationExplanationIfNeeded() async {
    final hasPermission = OneSignal.Notifications.permission;
    if (hasPermission) return;

    final prefs = await SharedPreferences.getInstance();
    final explanationShown = prefs.getBool(_explanationShownKey) ?? false;
    if (explanationShown) return;

    await prefs.setBool(_explanationShownKey, true);

    final context = navigatorKey?.currentContext;
    if (context == null || !context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        promptNotificationExplanationIfNeeded();
      });
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stay Updated with ROUJLI'),
        content: const Text(
          'Enable notifications to get instant updates on your orders, messages, and business requests.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              requestPermission();
            },
            child: const Text('Enable Notifications'),
          ),
        ],
      ),
    );
  }

  /// Associate ROUJLI user ID as OneSignal External ID
  static Future<void> login(String externalUserId) async {
    await OneSignal.login(externalUserId);
    await promptNotificationExplanationIfNeeded();
  }

  /// Logout current OneSignal session
  static Future<void> logout() async {
    await OneSignal.logout();
  }

  /// Add User Tag
  static Future<void> addTag(String key, String value) async {
    await OneSignal.User.addTags({key: value});
  }

  /// Remove User Tag
  static Future<void> removeTag(String key) async {
    await OneSignal.User.removeTags([key]);
  }

  /// Associate Email
  static Future<void> setEmail(String email) async {
    await OneSignal.User.addEmail(email);
  }

  /// Associate SMS Number
  static Future<void> setSMS(String smsNumber) async {
    await OneSignal.User.addSms(smsNumber);
  }

  /// Request push notification system permission
  static Future<void> requestPermission() async {
    await OneSignal.Notifications.requestPermission(true);
  }
}
