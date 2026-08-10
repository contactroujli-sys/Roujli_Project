import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // ─── Keys ──────────────────────────────────────────────────────────────────

  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _skippedVerificationKey = 'skipped_verification';
  static const String _skipTimestampKey = 'skip_timestamp';
  static const String _pendingVerificationEmailKey = 'pending_verification_email';
  static const String _lastReminderShownKey = 'last_reminder_shown';

  // ─── Onboarding ────────────────────────────────────────────────────────────

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  // ─── Auth Status ───────────────────────────────────────────────────────────

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> setLoggedIn(bool loggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, loggedIn);
  }

  // ─── Access Token ──────────────────────────────────────────────────────────

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  // ─── Refresh Token ─────────────────────────────────────────────────────────

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  // ─── Tokens (both at once) ─────────────────────────────────────────────────

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // ─── User Data ─────────────────────────────────────────────────────────────

  static Future<String?> getUserJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  static Future<void> saveUserJson(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userJson);
  }

  // ─── Clear ─────────────────────────────────────────────────────────────────

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ─── Verification Skip ────────────────────────────────────────────────────────

  static Future<bool> hasSkippedVerification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_skippedVerificationKey) ?? false;
  }

  static Future<void> setSkippedVerification(bool skipped) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_skippedVerificationKey, skipped);
  }

  static Future<String?> getSkipTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_skipTimestampKey);
  }

  static Future<void> setSkipTimestamp(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_skipTimestampKey, timestamp);
  }

  static Future<String?> getPendingVerificationEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingVerificationEmailKey);
  }

  static Future<void> setPendingVerificationEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingVerificationEmailKey, email);
  }

  static Future<String?> getLastReminderShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastReminderShownKey);
  }

  static Future<void> setLastReminderShown(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReminderShownKey, timestamp);
  }

  static Future<void> clearVerificationSkipData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_skippedVerificationKey);
    await prefs.remove(_skipTimestampKey);
    await prefs.remove(_pendingVerificationEmailKey);
    await prefs.remove(_lastReminderShownKey);
  }
}
