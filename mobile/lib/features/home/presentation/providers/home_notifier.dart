import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';
import 'home_provider.dart';

class HomeNotifier extends AutoDisposeNotifier<HomeState> {
  late final HomeRepository _homeRepository;

  @override
  HomeState build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    return const HomeState();
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final homeData = await _homeRepository.getHomeData();
      state = state.copyWith(
        isLoading: false,
        homeData: homeData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _cleanError(e),
      );
    }
  }

  void refreshData() {
    loadHomeData();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _cleanError(Object e) {
    final message = e.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }
    return message;
  }
}
