import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/dio_service.dart';

final unreadNotificationsProvider = NotifierProvider<UnreadNotificationsNotifier, int>(UnreadNotificationsNotifier.new);

class UnreadNotificationsNotifier extends Notifier<int> {
  Timer? _timer;

  @override
  int build() {
    fetchUnreadCount();
    _startPolling();
    ref.onDispose(() {
      _timer?.cancel();
    });
    return 0;
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchUnreadCount();
    });
  }

  Future<void> fetchUnreadCount() async {
    try {
      final dio = DioService.instance;
      final response = await dio.get(ApiConstants.unreadNotificationsCount);
      if (response.statusCode == 200) {
        state = response.data['data']['unreadCount'] ?? 0;
      }
    } catch (_) {
      // Ignore background poll errors
    }
  }

  void clearBadge() {
    state = 0;
  }
}
