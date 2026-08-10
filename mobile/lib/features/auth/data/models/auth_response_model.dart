import '../../domain/entities/auth_result.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthResult {
  const AuthResponseModel({
    required super.user,
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Backend shape: { success, message, data: { user, tokens: { accessToken, refreshToken } } }
    final data = json['data'] as Map<String, dynamic>;
    final tokens = data['tokens'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;

    return AuthResponseModel(
      user: UserModel.fromJson(userJson),
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
    );
  }
}
