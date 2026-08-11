import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/explore_repository.dart';
import 'explore_state.dart';
import 'explore_provider.dart';

class ExploreNotifier extends Notifier<ExploreState> {
  late final ExploreRepository _repository;

  @override
  ExploreState build() {
    _repository = ref.watch(exploreRepositoryProvider);
    return const ExploreState();
  }

  Future<void> initExplore({String? initialQuery}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      searchQuery: initialQuery ?? state.searchQuery,
    );
    try {
      final categories = await _repository.getCategories();
      state = state.copyWith(categories: categories);
      await loadBusinesses();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _cleanError(e));
    }
  }

  Future<void> loadBusinesses() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.getBusinesses(
        search: state.searchQuery,
        categoryId: state.selectedCategory,
      );
      state = state.copyWith(
        isLoading: false,
        businesses: result['items'],
        totalCount: result['total'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _cleanError(e));
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    loadBusinesses();
  }

  void selectCategory(String categoryName) {
    state = state.copyWith(selectedCategory: categoryName);
    loadBusinesses();
  }

  Future<void> toggleSave(String businessId) async {
    // Optimistic UI update
    final currentList = [...state.businesses];
    final index = currentList.indexWhere((b) => b.id == businessId);
    if (index != -1) {
      final item = currentList[index];
      currentList[index] = item.copyWith(isSaved: !item.isSaved);
      state = state.copyWith(businesses: currentList);
    }

    try {
      final isSaved = await _repository.toggleSave(businessId);
      if (index != -1) {
        currentList[index] = currentList[index].copyWith(isSaved: isSaved);
        state = state.copyWith(businesses: currentList);
      }
      // Refresh save state provider
      ref.read(saveStateProvider.notifier).loadSavedBusinesses();
    } catch (e) {
      // Revert on error
      if (index != -1) {
        final item = currentList[index];
        currentList[index] = item.copyWith(isSaved: !item.isSaved);
        state = state.copyWith(businesses: currentList);
      }
    }
  }

  Future<void> toggleFollow(String businessId) async {
    final currentList = [...state.businesses];
    final index = currentList.indexWhere((b) => b.id == businessId);
    if (index != -1) {
      final item = currentList[index];
      final newFollowed = !item.isFollowed;
      final newCount = newFollowed ? item.followersCount + 1 : (item.followersCount > 0 ? item.followersCount - 1 : 0);
      currentList[index] = item.copyWith(isFollowed: newFollowed, followersCount: newCount);
      state = state.copyWith(businesses: currentList);
    }

    try {
      await _repository.toggleFollow(businessId);
    } catch (e) {
      // Revert on error
      if (index != -1) {
        final item = currentList[index];
        final oldFollowed = !item.isFollowed;
        final oldCount = oldFollowed ? item.followersCount + 1 : (item.followersCount > 0 ? item.followersCount - 1 : 0);
        currentList[index] = item.copyWith(isFollowed: oldFollowed, followersCount: oldCount);
        state = state.copyWith(businesses: currentList);
      }
    }
  }

  String _cleanError(Object e) {
    final message = e.toString();
    if (message.startsWith('Exception: ')) return message.substring(11);
    return message;
  }
}

class SaveNotifier extends Notifier<SaveState> {
  late final ExploreRepository _repository;

  @override
  SaveState build() {
    _repository = ref.watch(exploreRepositoryProvider);
    return const SaveState();
  }

  Future<void> loadSavedBusinesses() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.getSavedBusinesses();
      state = state.copyWith(isLoading: false, savedBusinesses: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _cleanError(e));
    }
  }

  Future<void> unsaveBusiness(String businessId) async {
    state = state.copyWith(
      savedBusinesses: state.savedBusinesses.where((b) => b.id != businessId).toList(),
    );
    try {
      await _repository.toggleSave(businessId);
      // Also update explore state
      ref.read(exploreStateProvider.notifier).loadBusinesses();
    } catch (e) {
      loadSavedBusinesses();
    }
  }

  String _cleanError(Object e) {
    final message = e.toString();
    if (message.startsWith('Exception: ')) return message.substring(11);
    return message;
  }
}
