import '../../domain/entities/user.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../core/services/onesignal_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _dataSource = AuthRemoteDataSource();

  // ─── Register ───────────────────────────────────────────────────────────────

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    await _dataSource.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      role: role,
    );
  }

  // ─── Verify Email ────────────────────────────────────────────────────────────

  @override
  Future<AuthResult> verifyEmail({
    required String email,
    required String code,
  }) async {
    final result = await _dataSource.verifyEmail(email: email, code: code);
    await _persistSession(result);
    await StorageService.clearVerificationSkipData();
    return result;
  }

  // ─── Resend Code ─────────────────────────────────────────────────────────────

  @override
  Future<void> resendCode({required String email}) async {
    await _dataSource.resendCode(email: email);
  }

  // ─── Login ───────────────────────────────────────────────────────────────────

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _dataSource.login(email: email, password: password);
    await _persistSession(result);
    return result;
  }

  // ─── Forgot Password ─────────────────────────────────────────────────────────

  @override
  Future<void> forgotPassword({required String email}) async {
    await _dataSource.forgotPassword(email: email);
  }

  // ─── Reset Password ──────────────────────────────────────────────────────────

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _dataSource.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  // ─── Logout ──────────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    final refreshToken = await StorageService.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _dataSource.logout(refreshToken: refreshToken);
      } catch (_) {
        // Ignore server errors on logout — always clear local state
      }
    }
    await StorageService.clearAuth();
    await OneSignalService.logout();
  }

  // ─── Auth Status ─────────────────────────────────────────────────────────────

  @override
  Future<bool> isLoggedIn() async {
    return StorageService.isLoggedIn();
  }

  @override
  Future<User?> getCurrentUser() async {
    final userJson = await StorageService.getUserJson();
    if (userJson == null) return null;
    try {
      return UserModel.fromJsonString(userJson);
    } catch (_) {
      return null;
    }
  }

  // ─── Private ─────────────────────────────────────────────────────────────────

  Future<void> _persistSession(AuthResult result) async {
    await StorageService.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    if (result.user is UserModel) {
      await StorageService.saveUserJson((result.user as UserModel).toJsonString());
    }
    if (result.user.id.isNotEmpty) {
      await OneSignalService.login(result.user.id);
      if (result.user.email.isNotEmpty) {
        await OneSignalService.setEmail(result.user.email);
      }
      if (result.user.role.isNotEmpty) {
        await OneSignalService.addTag('role', result.user.role);
      }
    }
  }
}
