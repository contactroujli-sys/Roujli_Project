import '../../domain/entities/explore_business.dart';

class ExploreState {
  final bool isLoading;
  final List<ExploreBusiness> businesses;
  final List<CategoryItem> categories;
  final String? errorMessage;
  final String searchQuery;
  final String selectedCategory;
  final int totalCount;

  const ExploreState({
    this.isLoading = false,
    this.businesses = const [],
    this.categories = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.totalCount = 0,
  });

  ExploreState copyWith({
    bool? isLoading,
    List<ExploreBusiness>? businesses,
    List<CategoryItem>? categories,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    String? selectedCategory,
    int? totalCount,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      businesses: businesses ?? this.businesses,
      categories: categories ?? this.categories,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class SaveState {
  final bool isLoading;
  final List<ExploreBusiness> savedBusinesses;
  final String? errorMessage;

  const SaveState({
    this.isLoading = false,
    this.savedBusinesses = const [],
    this.errorMessage,
  });

  SaveState copyWith({
    bool? isLoading,
    List<ExploreBusiness>? savedBusinesses,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SaveState(
      isLoading: isLoading ?? this.isLoading,
      savedBusinesses: savedBusinesses ?? this.savedBusinesses,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
