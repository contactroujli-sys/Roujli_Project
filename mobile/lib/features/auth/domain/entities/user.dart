class UserProfile {
  final String firstName;
  final String lastName;
  final String? avatar;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    this.avatar,
  });
}

class User {
  final String id;
  final String email;
  final String role;
  final bool isVerified;
  final UserProfile? profile;

  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.isVerified,
    this.profile,
  });

  String get displayName {
    if (profile != null) {
      return '${profile!.firstName} ${profile!.lastName}'.trim();
    }
    return email;
  }
}
