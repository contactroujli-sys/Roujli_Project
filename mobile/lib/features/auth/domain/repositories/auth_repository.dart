import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/user.dart';
import '../entities/auth_result.dart';
import '../../data/repositories/auth_repository_impl.dart';

abstract class AuthRepository {
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  });

  Future<AuthResult> verifyEmail({
    required String email,
    required String code,
  });

  Future<void> resendCode({required String email});

  Future<AuthResult> login({
    required String email,
    required String password,
  });

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> logout();

  Future<bool> isLoggedIn();

  Future<User?> getCurrentUser();
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});
