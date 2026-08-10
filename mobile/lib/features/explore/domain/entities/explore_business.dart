class ExploreBusiness {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? logo;
  final String? cover;
  final String category;
  final String? location;
  final double rating;
  final int reviews;
  final int growthScore;
  final int monthlyGrowth;
  final bool verified;
  final int followersCount;
  final bool isSaved;
  final bool isFollowed;

  ExploreBusiness({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logo,
    this.cover,
    required this.category,
    this.location,
    required this.rating,
    required this.reviews,
    required this.growthScore,
    required this.monthlyGrowth,
    required this.verified,
    required this.followersCount,
    required this.isSaved,
    required this.isFollowed,
  });

  ExploreBusiness copyWith({
    bool? isSaved,
    bool? isFollowed,
    int? followersCount,
  }) {
    return ExploreBusiness(
      id: id,
      name: name,
      slug: slug,
      description: description,
      logo: logo,
      cover: cover,
      category: category,
      location: location,
      rating: rating,
      reviews: reviews,
      growthScore: growthScore,
      monthlyGrowth: monthlyGrowth,
      verified: verified,
      followersCount: followersCount ?? this.followersCount,
      isSaved: isSaved ?? this.isSaved,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}

class ProductItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? image;

  ProductItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
  });
}

class ServiceItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int? duration;
  final String? image;

  ServiceItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.duration,
    this.image,
  });
}

class OfferItem {
  final String id;
  final String title;
  final String? description;
  final double? discount;
  final String? image;
  final DateTime? expiresAt;

  OfferItem({
    required this.id,
    required this.title,
    this.description,
    this.discount,
    this.image,
    this.expiresAt,
  });
}

class BusinessDetail extends ExploreBusiness {
  final String? phone;
  final String? email;
  final String? website;
  final String? whatsapp;
  final String? address;
  final int productsCount;
  final int servicesCount;
  final int offersCount;
  final List<ProductItem> products;
  final List<ServiceItem> services;
  final List<OfferItem> offers;

  BusinessDetail({
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
    this.phone,
    this.email,
    this.website,
    this.whatsapp,
    this.address,
    required this.productsCount,
    required this.servicesCount,
    required this.offersCount,
    required this.products,
    required this.services,
    required this.offers,
  });
}

class CategoryItem {
  final String id;
  final String name;
  final String? icon;

  CategoryItem({required this.id, required this.name, this.icon});
}
