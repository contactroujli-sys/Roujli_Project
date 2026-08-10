import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_notifier.dart';
import 'home_state.dart';

// Repository Provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl();
});

// State Provider
final homeStateProvider = AutoDisposeNotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
