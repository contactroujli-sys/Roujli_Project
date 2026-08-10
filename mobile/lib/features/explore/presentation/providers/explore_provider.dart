import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/explore_remote_datasource.dart';
import '../../data/repositories/explore_repository_impl.dart';
import '../../domain/repositories/explore_repository.dart';
import 'explore_state.dart';
import 'explore_notifier.dart';

final exploreRemoteDataSourceProvider = Provider<ExploreRemoteDataSource>((ref) {
  return ExploreRemoteDataSource();
});

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  final remoteDataSource = ref.watch(exploreRemoteDataSourceProvider);
  return ExploreRepositoryImpl(remoteDataSource);
});

final exploreStateProvider =
    NotifierProvider<ExploreNotifier, ExploreState>(ExploreNotifier.new);

final saveStateProvider =
    NotifierProvider<SaveNotifier, SaveState>(SaveNotifier.new);
