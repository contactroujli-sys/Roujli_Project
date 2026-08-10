import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_service.dart';
import '../models/explore_business_model.dart';
import '../../domain/entities/explore_business.dart';

class ExploreRemoteDataSource {
  final Dio _dio = DioService.instance;

  Future<Map<String, dynamic>> getBusinesses({
    String? search,
    String? categoryId,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (categoryId != null && categoryId.isNotEmpty && categoryId != '0' && categoryId != 'All') {
        queryParams['categoryId'] = categoryId;
      }
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

      final response = await _dio.get(
        ApiConstants.businesses,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List itemsJson = data['items'] ?? [];
        final businesses = itemsJson.map((json) => ExploreBusinessModel.fromJson(json)).toList();
        return {
          'items': businesses,
          'total': data['total'] ?? 0,
          'totalPages': data['totalPages'] ?? 1,
        };
      }
      throw Exception('Failed to fetch businesses');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<BusinessDetailModel> getBusinessById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.businessById(id));
      if (response.statusCode == 200) {
        return BusinessDetailModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to fetch business details');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<bool> toggleSave(String businessId) async {
    try {
      final response = await _dio.post(ApiConstants.saveBusiness(businessId));
      if (response.statusCode == 200) {
        return response.data['data']['isSaved'] ?? false;
      }
      throw Exception('Failed to save business');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<bool> toggleFollow(String businessId) async {
    try {
      final response = await _dio.post(ApiConstants.followBusiness(businessId));
      if (response.statusCode == 200) {
        return response.data['data']['isFollowed'] ?? false;
      }
      throw Exception('Failed to follow business');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<List<ExploreBusinessModel>> getSavedBusinesses() async {
    try {
      final response = await _dio.get(ApiConstants.savedBusinesses);
      if (response.statusCode == 200) {
        final List list = response.data['data'] ?? [];
        return list.map((json) => ExploreBusinessModel.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch saved businesses');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<List<CategoryItem>> getCategories() async {
    try {
      final response = await _dio.get(ApiConstants.categories);
      if (response.statusCode == 200) {
        final List list = response.data['data'] ?? [];
        final cats = list.map((json) => CategoryItem(
          id: json['id'] ?? '',
          name: json['name'] ?? '',
          icon: json['icon'],
        )).toList();
        return [CategoryItem(id: 'All', name: 'All'), ...cats];
      }
      return [CategoryItem(id: 'All', name: 'All')];
    } catch (_) {
      return [CategoryItem(id: 'All', name: 'All')];
    }
  }
}
