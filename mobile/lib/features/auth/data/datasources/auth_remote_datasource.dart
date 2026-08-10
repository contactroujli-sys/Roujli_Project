import 'package:dio/dio.dart';
import '../../../../core/services/dio_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDataSource {
  final Dio _dio = DioService.instance;

  // ─── Register ───────────────────────────────────────────────────────────────

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      await _dio.post(
        ApiConstants.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'role': role,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Verify Email ────────────────────────────────────────────────────────────

  Future<AuthResponseModel> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyEmail,
        data: {'email': email, 'code': code},
      );
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Resend Code ─────────────────────────────────────────────────────────────

  Future<void> resendCode({required String email}) async {
    try {
      await _dio.post(ApiConstants.resendCode, data: {'email': email});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Login ───────────────────────────────────────────────────────────────────

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Forgot Password ─────────────────────────────────────────────────────────

  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post(ApiConstants.forgotPassword, data: {'email': email});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Reset Password ──────────────────────────────────────────────────────────

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Logout ──────────────────────────────────────────────────────────────────

  Future<void> logout({required String refreshToken}) async {
    try {
      await _dio.post(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Error Handler ───────────────────────────────────────────────────────────

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) {
        return Exception(data['message'] as String);
      }
      return Exception('Server error (${e.response!.statusCode})');
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timed out. Please check your internet connection.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return Exception('Cannot connect to server. Please check your internet connection.');
    }

    return Exception('An unexpected error occurred. Please try again.');
  }
}
