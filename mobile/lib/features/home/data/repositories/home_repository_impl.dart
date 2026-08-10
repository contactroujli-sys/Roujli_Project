import '../../domain/entities/home_data.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/home_data_model.dart' hide BusinessGrowthScore, Stat, Business, Offer, BusinessInsight, Category;

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _dataSource = HomeRemoteDataSource();

  @override
  Future<HomeData> getHomeData() async {
    final model = await _dataSource.getHomeData();
    return _mapToEntity(model);
  }

  HomeData _mapToEntity(HomeDataModel model) {
    return HomeData(
      growthScore: BusinessGrowthScore(
        score: model.growthScore.score,
        change: model.growthScore.change,
        period: model.growthScore.period, profileCompletion: '', engagementRate: '', responseTime: '', reviewScore: '', topPercentage: '',
      ),
      stats: model.stats.map((stat) => Stat(
        label: stat.label,
        value: stat.value,
        change: stat.change,
        isPositive: stat.isPositive,
      )).toList(),
      trendingBusinesses: model.trendingBusinesses.map((business) => Business(
        id: business.id,
        name: business.name,
        category: business.category,
        imageUrl: business.imageUrl,
        rating: business.rating,
        reviews: business.reviews,
        location: business.location,
        isVerified: business.isVerified,
      )).toList(),
      recommendedBusinesses: model.recommendedBusinesses.map((business) => Business(
        id: business.id,
        name: business.name,
        category: business.category,
        imageUrl: business.imageUrl,
        rating: business.rating,
        reviews: business.reviews,
        location: business.location,
        isVerified: business.isVerified,
      )).toList(),
      trendingOffers: model.trendingOffers.map((offer) => Offer(
        id: offer.id,
        title: offer.title,
        businessName: offer.businessName,
        imageUrl: offer.imageUrl,
        discount: offer.discount,
        description: offer.description,
        expiresAt: offer.expiresAt,
      )).toList(),
      growingBusinesses: model.growingBusinesses.map((business) => Business(
        id: business.id,
        name: business.name,
        category: business.category,
        imageUrl: business.imageUrl,
        rating: business.rating,
        reviews: business.reviews,
        location: business.location,
        isVerified: business.isVerified,
      )).toList(),
      businessInsights: model.businessInsights.map((insight) => BusinessInsight(
        id: insight.id,
        title: insight.title,
        description: insight.description,
        category: insight.category,
        createdAt: insight.createdAt,
      )).toList(),
      categories: model.categories.map((category) => Category(
        id: category.id,
        name: category.name,
        icon: category.icon,
        businessCount: category.businessCount,
      )).toList(),
    );
  }
}
