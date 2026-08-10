import '../../domain/entities/explore_business.dart';

class ExploreBusinessModel extends ExploreBusiness {
  ExploreBusinessModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.logo,
    super.cover,
    required super.category,
    super.location,
    required super.rating,
    required super.reviews,
    required super.growthScore,
    required super.monthlyGrowth,
    required super.verified,
    required super.followersCount,
    required super.isSaved,
    required super.isFollowed,
  });

  factory ExploreBusinessModel.fromJson(Map<String, dynamic> json) {
    return ExploreBusinessModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      logo: json['logo'],
      cover: json['cover'],
      category: json['category'] ?? 'General',
      location: json['location'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? 0,
      growthScore: json['growthScore'] ?? 0,
      monthlyGrowth: json['monthlyGrowth'] ?? 0,
      verified: json['verified'] ?? false,
      followersCount: json['followersCount'] ?? 0,
      isSaved: json['isSaved'] ?? false,
      isFollowed: json['isFollowed'] ?? false,
    );
  }
}

class BusinessDetailModel extends BusinessDetail {
  BusinessDetailModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.logo,
    super.cover,
    required super.category,
    super.location,
    required super.rating,
    required super.reviews,
    required super.growthScore,
    required super.monthlyGrowth,
    required super.verified,
    required super.followersCount,
    required super.isSaved,
    required super.isFollowed,
    super.phone,
    super.email,
    super.website,
    super.whatsapp,
    super.address,
    required super.productsCount,
    required super.servicesCount,
    required super.offersCount,
    required super.products,
    required super.services,
    required super.offers,
  });

  factory BusinessDetailModel.fromJson(Map<String, dynamic> json) {
    return BusinessDetailModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      logo: json['logo'],
      cover: json['cover'],
      category: json['category'] ?? 'General',
      location: json['location'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? 0,
      growthScore: json['growthScore'] ?? 0,
      monthlyGrowth: json['monthlyGrowth'] ?? 0,
      verified: json['verified'] ?? false,
      followersCount: json['followersCount'] ?? 0,
      isSaved: json['isSaved'] ?? false,
      isFollowed: json['isFollowed'] ?? false,
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      whatsapp: json['whatsapp'],
      address: json['address'],
      productsCount: json['productsCount'] ?? 0,
      servicesCount: json['servicesCount'] ?? 0,
      offersCount: json['offersCount'] ?? 0,
      products: (json['products'] as List<dynamic>?)
              ?.map((p) => ProductItem(
                    id: p['id'] ?? '',
                    name: p['name'] ?? '',
                    description: p['description'],
                    price: (p['price'] ?? 0).toDouble(),
                    image: p['image'],
                  ))
              .toList() ??
          [],
      services: (json['services'] as List<dynamic>?)
              ?.map((s) => ServiceItem(
                    id: s['id'] ?? '',
                    name: s['name'] ?? '',
                    description: s['description'],
                    price: (s['price'] ?? 0).toDouble(),
                    duration: s['duration'],
                    image: s['image'],
                  ))
              .toList() ??
          [],
      offers: (json['offers'] as List<dynamic>?)
              ?.map((o) => OfferItem(
                    id: o['id'] ?? '',
                    title: o['title'] ?? '',
                    description: o['description'],
                    discount: o['discount'] != null ? (o['discount']).toDouble() : null,
                    image: o['image'],
                    expiresAt: o['expiresAt'] != null ? DateTime.tryParse(o['expiresAt']) : null,
                  ))
              .toList() ??
          [],
    );
  }
}
