class ProfileData {
  final UserProfile user;
  final List<BusinessCount> businessCounts;
  final Membership membership;

  ProfileData({
    required this.user,
    required this.businessCounts,
    required this.membership,
  });
}

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? avatar;
  final String? bio;
  final String? country;
  final String? city;
  final bool isVerified;
  final int growthScore;
  final BusinessInfo? business;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.avatar,
    this.bio,
    this.country,
    this.city,
    required this.isVerified,
    required this.growthScore,
    this.business,
  });

  String get fullName => '$firstName $lastName';
}

class BusinessInfo {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? logo;
  final String? cover;
  final String? phone;
  final String? email;
  final String? website;
  final String? whatsapp;
  final String? address;
  final bool verified;
  final int growthScore;
  final int monthlyGrowth;

  BusinessInfo({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logo,
    this.cover,
    this.phone,
    this.email,
    this.website,
    this.whatsapp,
    this.address,
    required this.verified,
    required this.growthScore,
    required this.monthlyGrowth,
  });
}

class BusinessCount {
  final String type;
  final int count;

  BusinessCount({
    required this.type,
    required this.count,
  });
}

class Membership {
  final String type;
  final String status;
  final DateTime? expiresAt;

  Membership({
    required this.type,
    required this.status,
    this.expiresAt,
  });
}
