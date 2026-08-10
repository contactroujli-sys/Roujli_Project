import 'dart:async';
import 'package:dio/dio.dart';
import '../../../../core/services/dio_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/home_data_model.dart';

class HomeRemoteDataSource {
  final Dio _dio = DioService.instance;

  Future<HomeDataModel> getHomeData() async {
    try {
      // Add a short timeout so the UI fails fast when backend is unreachable.
      final response = await _dio.get(ApiConstants.home).timeout(const Duration(seconds: 7));
      
      if (response.statusCode == 200) {
        return HomeDataModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load home data (status: ${response.statusCode})');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timed out while fetching home data');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
