import '../../domain/entities/profile_data.dart';

class ProfileState {
  final bool isLoading;
  final ProfileData? profileData;
  final String? errorMessage;

  const ProfileState({
    this.isLoading = false,
    this.profileData,
    this.errorMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    ProfileData? profileData,
    String? errorMessage,
    bool clearData = false,
    bool clearError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profileData: clearData ? null : profileData ?? this.profileData,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
