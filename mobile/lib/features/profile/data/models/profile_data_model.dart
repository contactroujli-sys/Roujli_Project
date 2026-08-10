class ProfileDataModel {
  final UserProfileModel user;
  final List<BusinessCountModel> businessCounts;
  final MembershipModel membership;

  ProfileDataModel({
    required this.user,
    required this.businessCounts,
    required this.membership,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataModel(
      user: UserProfileModel.fromJson(json['user'] ?? {}),
      businessCounts: (json['businessCounts'] as List<dynamic>?)
              ?.map((e) => BusinessCountModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      membership: MembershipModel.fromJson(json['membership'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'businessCounts': businessCounts.map((e) => e.toJson()).toList(),
      'membership': membership.toJson(),
    };
  }
}

class UserProfileModel {
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
  final BusinessModel? business;

  UserProfileModel({
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final business = json['business'] as Map<String, dynamic>?;

    return UserProfileModel(
      firstName: profile['firstName'] as String? ?? '',
      lastName: profile['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: profile['phone'] as String? ?? profile['phoneNumber'] as String?,
      avatar: profile['avatar'] as String?,
      bio: profile['bio'] as String?,
      country: profile['country'] as String?,
      city: profile['city'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      growthScore: business?['growthScore'] as int? ?? 0,
      business: business != null ? BusinessModel.fromJson(business) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phoneNumber,
      'avatar': avatar,
      'bio': bio,
      'country': country,
      'city': city,
      'isVerified': isVerified,
      'growthScore': growthScore,
      'business': business?.toJson(),
    };
  }
}

class BusinessModel {
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

  BusinessModel({
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

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      cover: json['cover'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      whatsapp: json['whatsapp'] as String?,
      address: json['address'] as String?,
      verified: json['verified'] as bool? ?? false,
      growthScore: json['growthScore'] as int? ?? 0,
      monthlyGrowth: json['monthlyGrowth'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'logo': logo,
      'cover': cover,
      'phone': phone,
      'email': email,
      'website': website,
      'whatsapp': whatsapp,
      'address': address,
      'verified': verified,
      'growthScore': growthScore,
      'monthlyGrowth': monthlyGrowth,
    };
  }
}

class BusinessCountModel {
  final String type;
  final int count;

  BusinessCountModel({
    required this.type,
    required this.count,
  });

  factory BusinessCountModel.fromJson(Map<String, dynamic> json) {
    return BusinessCountModel(
      type: json['type'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'count': count,
    };
  }
}

class MembershipModel {
  final String type;
  final String status;
  final String? expiresAt;

  MembershipModel({
    required this.type,
    required this.status,
    this.expiresAt,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      expiresAt: json['expiresAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'status': status,
      'expiresAt': expiresAt,
    };
  }
}
