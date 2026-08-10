import '../entities/explore_business.dart';

abstract class ExploreRepository {
  Future<Map<String, dynamic>> getBusinesses({
    String? search,
    String? categoryId,
    String? sort,
    int page = 1,
    int limit = 20,
  });

  Future<BusinessDetail> getBusinessById(String id);
  Future<bool> toggleSave(String businessId);
  Future<bool> toggleFollow(String businessId);
  Future<List<ExploreBusiness>> getSavedBusinesses();
  Future<List<CategoryItem>> getCategories();
}
