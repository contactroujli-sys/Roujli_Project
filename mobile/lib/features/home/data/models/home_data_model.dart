class HomeDataModel {
  final BusinessGrowthScore growthScore;
  final List<Stat> stats;
  final List<Business> trendingBusinesses;
  final List<Business> recommendedBusinesses;
  final List<Offer> trendingOffers;
  final List<Business> growingBusinesses;
  final List<BusinessInsight> businessInsights;
  final List<Category> categories;

  HomeDataModel({
    required this.growthScore,
    required this.stats,
    required this.trendingBusinesses,
    required this.recommendedBusinesses,
    required this.trendingOffers,
    required this.growingBusinesses,
    required this.businessInsights,
    required this.categories,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      growthScore: BusinessGrowthScore.fromJson(json['growthScore'] ?? {}),
      stats: (json['stats'] as List<dynamic>?)
              ?.map((e) => Stat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      trendingBusinesses: (json['trendingBusinesses'] as List<dynamic>?)
              ?.map((e) => Business.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recommendedBusinesses: (json['recommendedBusinesses'] as List<dynamic>?)
              ?.map((e) => Business.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      trendingOffers: (json['trendingOffers'] as List<dynamic>?)
              ?.map((e) => Offer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      growingBusinesses: (json['growingBusinesses'] as List<dynamic>?)
              ?.map((e) => Business.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      businessInsights: (json['businessInsights'] as List<dynamic>?)
              ?.map((e) => BusinessInsight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'growthScore': growthScore.toJson(),
      'stats': stats.map((e) => e.toJson()).toList(),
      'trendingBusinesses': trendingBusinesses.map((e) => e.toJson()).toList(),
      'recommendedBusinesses': recommendedBusinesses.map((e) => e.toJson()).toList(),
      'trendingOffers': trendingOffers.map((e) => e.toJson()).toList(),
      'growingBusinesses': growingBusinesses.map((e) => e.toJson()).toList(),
      'businessInsights': businessInsights.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }
}

class BusinessGrowthScore {
  final int score;
  final int change;
  final String period;
  final String profileCompletion;
  final String engagementRate;
  final String responseTime;
  final String reviewScore;
  final String topPercentage;

  BusinessGrowthScore({
    required this.score,
    required this.change,
    required this.period,
    required this.profileCompletion,
    required this.engagementRate,
    required this.responseTime,
    required this.reviewScore,
    required this.topPercentage,
  });

  factory BusinessGrowthScore.fromJson(Map<String, dynamic> json) {
    return BusinessGrowthScore(
      score: json['score'] as int? ?? 0,
      change: json['change'] as int? ?? 0,
      period: json['period'] as String? ?? 'month',
      profileCompletion: json['profileCompletion'] as String? ?? '0%',
      engagementRate: json['engagementRate'] as String? ?? '0%',
      responseTime: json['responseTime'] as String? ?? '0%',
      reviewScore: json['reviewScore'] as String? ?? '0%',
      topPercentage: json['topPercentage'] as String? ?? '0%',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'change': change,
      'period': period,
      'profileCompletion': profileCompletion,
      'engagementRate': engagementRate,
      'responseTime': responseTime,
      'reviewScore': reviewScore,
      'topPercentage': topPercentage,
    };
  }
}

class Stat {
  final String label;
  final String value;
  final String change;
  final bool isPositive;

  Stat({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
      change: json['change'] as String? ?? '',
      isPositive: json['isPositive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'change': change,
      'isPositive': isPositive,
    };
  }
}

class Business {
  final String id;
  final String name;
  final String category;
  final String? imageUrl;
  final double rating;
  final int reviews;
  final String location;
  final bool isVerified;

  Business({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.isVerified,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] as int? ?? 0,
      location: json['location'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviews': reviews,
      'location': location,
      'isVerified': isVerified,
    };
  }
}

class Offer {
  final String id;
  final String title;
  final String businessName;
  final String? imageUrl;
  final String discount;
  final String description;
  final DateTime expiresAt;

  Offer({
    required this.id,
    required this.title,
    required this.businessName,
    this.imageUrl,
    required this.discount,
    required this.description,
    required this.expiresAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      discount: json['discount'] as String? ?? '',
      description: json['description'] as String? ?? '',
      expiresAt: DateTime.parse(json['expiresAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'businessName': businessName,
      'imageUrl': imageUrl,
      'discount': discount,
      'description': description,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

class BusinessInsight {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;

  BusinessInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
  });

  factory BusinessInsight.fromJson(Map<String, dynamic> json) {
    return BusinessInsight(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Category {
  final String id;
  final String name;
  final String icon;
  final int businessCount;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.businessCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      businessCount: json['businessCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'businessCount': businessCount,
    };
  }
}
