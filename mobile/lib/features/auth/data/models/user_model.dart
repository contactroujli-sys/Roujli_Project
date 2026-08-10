import 'dart:convert';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.isVerified,
    super.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserProfile? profile;
    if (json['profile'] != null) {
      final p = json['profile'] as Map<String, dynamic>;
      profile = UserProfile(
        firstName: p['firstName'] as String? ?? '',
        lastName: p['lastName'] as String? ?? '',
        avatar: p['avatar'] as String?,
      );
    }

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      profile: profile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'isVerified': isVerified,
      'profile': profile != null
          ? {
              'firstName': profile!.firstName,
              'lastName': profile!.lastName,
              'avatar': profile!.avatar,
            }
          : null,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String jsonStr) {
    return UserModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }
}
