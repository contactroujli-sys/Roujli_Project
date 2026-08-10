import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthNotifier extends AutoDisposeNotifier<AuthState> {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    return const AuthState();
  }

  // ─── Check Auth Status ────────────────────────────────────────────────────

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();

      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          clearUser: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        clearUser: true,
        errorMessage: _cleanError(e),
      );
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _cleanError(e));
      return false;
    }
  }

  // ─── Verify Email ─────────────────────────────────────────────────────────

  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authRepository.verifyEmail(email: email, code: code);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _cleanError(e));
      return false;
    }
  }

  // ─── Resend Code ──────────────────────────────────────────────────────────

  Future<void> resendCode({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authRepository.resendCode(email: email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _cleanError(e));
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authRepository.login(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _cleanError(e));
      return false;
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────

  Future<void> forgotPassword({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authRepository.forgotPassword(email: email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _cleanError(e));
    }
  }

  // ─── Reset Password ───────────────────────────────────────────────────────

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authRepository.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _cleanError(e));
      return false;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (_) {
      // Even if server logout fails, clear local state
    } finally {
      state = const AuthState();
    }
  }

  // ─── Utilities ────────────────────────────────────────────────────────────

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _cleanError(Object e) {
    final message = e.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }
    return message;
  }
}
