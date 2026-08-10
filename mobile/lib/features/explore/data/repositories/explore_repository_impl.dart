import '../../domain/entities/explore_business.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_remote_datasource.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource _remoteDataSource;

  ExploreRepositoryImpl(this._remoteDataSource);

  @override
  Future<Map<String, dynamic>> getBusinesses({
    String? search,
    String? categoryId,
    String? sort,
    int page = 1,
    int limit = 20,
  }) {
    return _remoteDataSource.getBusinesses(
      search: search,
      categoryId: categoryId,
      sort: sort,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<BusinessDetail> getBusinessById(String id) {
    return _remoteDataSource.getBusinessById(id);
  }

  @override
  Future<bool> toggleSave(String businessId) {
    return _remoteDataSource.toggleSave(businessId);
  }

  @override
  Future<bool> toggleFollow(String businessId) {
    return _remoteDataSource.toggleFollow(businessId);
  }

  @override
  Future<List<ExploreBusiness>> getSavedBusinesses() {
    return _remoteDataSource.getSavedBusinesses();
  }

  @override
  Future<List<CategoryItem>> getCategories() {
    return _remoteDataSource.getCategories();
  }
}
