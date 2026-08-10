import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';
import 'profile_provider.dart';

class ProfileNotifier extends AutoDisposeNotifier<ProfileState> {
  late final ProfileRepository _profileRepository;

  @override
  ProfileState build() {
    _profileRepository = ref.watch(profileRepositoryProvider);
    return const ProfileState();
  }

  Future<void> loadProfileData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final profileData = await _profileRepository.getProfileData();
      state = state.copyWith(
        isLoading: false,
        profileData: profileData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _cleanError(e),
      );
    }
  }

  Future<void> updateProfileData(Map<String, dynamic> data) async {
    try {
      await _profileRepository.updateProfileData(data);
      await loadProfileData();
    } catch (e) {
      state = state.copyWith(errorMessage: _cleanError(e));
      rethrow;
    }
  }

  Future<void> updateBusinessData(Map<String, dynamic> data) async {
    try {
      await _profileRepository.updateBusinessData(data);
      await loadProfileData();
    } catch (e) {
      state = state.copyWith(errorMessage: _cleanError(e));
      rethrow;
    }
  }

  Future<void> deleteBusiness() async {
    try {
      await _profileRepository.deleteBusiness();
      await loadProfileData();
    } catch (e) {
      state = state.copyWith(errorMessage: _cleanError(e));
      rethrow;
    }
  }

  void refreshData() {
    loadProfileData();
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
