import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Configurable IP address for physical devices testing on local Wi-Fi.
  // Replace this IP with your machine's LAN IP if testing on a real phone.

  // Set this to your Render service URL after deploying (e.g. 'https://roujli-backend.onrender.com/api')
  static String get baseUrl {
    return 'https://roujli-project-eta.vercel.app/api';
  }

  static String get socketUrl {
    return baseUrl.replaceAll('/api', '');
  }

  // Auth endpoints
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendCode = '/auth/resend-code';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';

  // Upload endpoint
  static const String upload = '/upload';

  // Home endpoints
  static const String home = '/home';

  // Profile endpoints
  static const String profile = '/profile';
  static const String profileBusiness = '/profile/business';
  static const String profilePrivacy = '/profile/privacy';

  // Business endpoints
  static const String businesses = '/businesses';
  static const String searchSuggestions = '/businesses/suggestions';
  static const String businessGrowth = '/businesses/growth';
  static const String categories = '/categories';
  static const String savedBusinesses = '/businesses/saved';
  static String businessById(String id) => '/businesses/$id';
  static String saveBusiness(String id) => '/businesses/$id/save';
  static String followBusiness(String id) => '/businesses/$id/follow';

  // Products, Services, Offers endpoints
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static const String services = '/services';
  static String serviceById(String id) => '/services/$id';
  static const String offers = '/offers';
  static String offerById(String id) => '/offers/$id';

  // Requests endpoints
  static const String requests = '/requests';
  static const String myRequests = '/requests/my';
  static const String incomingRequests = '/requests/incoming';
  static String requestById(String id) => '/requests/$id';
  static String updateRequestStatus(String id) => '/requests/$id/status';

  // Notifications endpoints
  static const String notifications = '/notifications';
  static const String unreadNotificationsCount = '/notifications/unread-count';
  static const String readAllNotifications = '/notifications/read-all';
  static String readNotification(String id) => '/notifications/$id/read';

  // Subscriptions endpoints
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String subscriptionAddOns = '/subscriptions/add-ons';
  static const String mySubscription = '/subscriptions/my';
  static const String subscribe = '/subscriptions/subscribe';
}
