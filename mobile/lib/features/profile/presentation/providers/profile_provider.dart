import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_notifier.dart';
import 'profile_state.dart';

// Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

// State Provider
final profileStateProvider = AutoDisposeNotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
