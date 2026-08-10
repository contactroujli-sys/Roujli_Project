import '../../domain/entities/home_data.dart';

class HomeState {
  final bool isLoading;
  final HomeData? homeData;
  final String? errorMessage;

  const HomeState({
    this.isLoading = false,
    this.homeData,
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    HomeData? homeData,
    String? errorMessage,
    bool clearData = false,
    bool clearError = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      homeData: clearData ? null : homeData ?? this.homeData,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
