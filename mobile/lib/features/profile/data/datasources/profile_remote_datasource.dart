import 'package:dio/dio.dart';
import '../../../../core/services/dio_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/profile_data_model.dart';

class ProfileRemoteDataSource {
  final Dio _dio = DioService.instance;

  Future<ProfileDataModel> getProfileData() async {
    try {
      final response = await _dio.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        return ProfileDataModel.fromJson(response.data['data']);
      }

      throw Exception('Failed to load profile data');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> updateProfileData(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiConstants.profile, data: data);
      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> updateBusinessData(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiConstants.profileBusiness, data: data);
      if (response.statusCode != 200) {
        throw Exception('Failed to save business');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> deleteBusiness() async {
    try {
      final response = await _dio.delete(ApiConstants.profileBusiness);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete business');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

}
