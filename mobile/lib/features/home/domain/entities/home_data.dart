class HomeData {
  final BusinessGrowthScore growthScore;
  final List<Stat> stats;
  final List<Business> trendingBusinesses;
  final List<Business> recommendedBusinesses;
  final List<Offer> trendingOffers;
  final List<Business> growingBusinesses;
  final List<BusinessInsight> businessInsights;
  final List<Category> categories;

  HomeData({
    required this.growthScore,
    required this.stats,
    required this.trendingBusinesses,
    required this.recommendedBusinesses,
    required this.trendingOffers,
    required this.growingBusinesses,
    required this.businessInsights,
    required this.categories,
  });
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
}
