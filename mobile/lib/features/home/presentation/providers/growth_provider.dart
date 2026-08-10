import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/dio_service.dart';
import '../../../../core/constants/api_constants.dart';

class ScorePillar {
  final String name;
  final String key;
  final int score;
  final int maxScore;
  final List<String> details;

  ScorePillar({
    required this.name,
    required this.key,
    required this.score,
    required this.maxScore,
    required this.details,
  });

  factory ScorePillar.fromJson(Map<String, dynamic> json) {
    return ScorePillar(
      name: json['name'] as String? ?? '',
      key: json['key'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 20,
      details: (json['details'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class GrowthRecommendation {
  final String id;
  final String problem;
  final String reason;
  final String recommendation;
  final String expectedImpact;
  final String relatedMetric;
  final String actionType;

  GrowthRecommendation({
    required this.id,
    required this.problem,
    required this.reason,
    required this.recommendation,
    required this.expectedImpact,
    required this.relatedMetric,
    required this.actionType,
  });

  factory GrowthRecommendation.fromJson(Map<String, dynamic> json) {
    return GrowthRecommendation(
      id: json['id'] as String? ?? '',
      problem: json['problem'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      expectedImpact: json['expectedImpact'] as String? ?? '',
      relatedMetric: json['relatedMetric'] as String? ?? '',
      actionType: json['actionType'] as String? ?? '',
    );
  }
}

class GrowthTask {
  final String id;
  final String title;
  final String description;
  final int points;
  final bool completed;
  final String? actionRoute;

  GrowthTask({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.completed,
    this.actionRoute,
  });

  factory GrowthTask.fromJson(Map<String, dynamic> json) {
    return GrowthTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
      actionRoute: json['actionRoute'] as String?,
    );
  }
}

class OpportunityItem {
  final String id;
  final String title;
  final String type;
  final String? businessId;
  final String? businessName;
  final String? category;
  final String matchReason;

  OpportunityItem({
    required this.id,
    required this.title,
    required this.type,
    this.businessId,
    this.businessName,
    this.category,
    required this.matchReason,
  });

  factory OpportunityItem.fromJson(Map<String, dynamic> json) {
    return OpportunityItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? 'PARTNER',
      businessId: json['businessId'] as String?,
      businessName: json['businessName'] as String?,
      category: json['category'] as String?,
      matchReason: json['matchReason'] as String? ?? '',
    );
  }
}

class GrowthMetrics {
  final int profileViews;
  final int productViews;
  final int serviceViews;
  final int interactions;
  final String conversionRate;
  final double responseTimeMins;
  final double responseRate;
  final int leads;
  final int reviewsCount;
  final double rating;

  GrowthMetrics({
    required this.profileViews,
    required this.productViews,
    required this.serviceViews,
    required this.interactions,
    required this.conversionRate,
    required this.responseTimeMins,
    required this.responseRate,
    required this.leads,
    required this.reviewsCount,
    required this.rating,
  });

  factory GrowthMetrics.fromJson(Map<String, dynamic> json) {
    return GrowthMetrics(
      profileViews: (json['profileViews'] as num?)?.toInt() ?? 0,
      productViews: (json['productViews'] as num?)?.toInt() ?? 0,
      serviceViews: (json['serviceViews'] as num?)?.toInt() ?? 0,
      interactions: (json['interactions'] as num?)?.toInt() ?? 0,
      conversionRate: json['conversionRate'] as String? ?? '0.0%',
      responseTimeMins: (json['responseTimeMins'] as num?)?.toDouble() ?? 0.0,
      responseRate: (json['responseRate'] as num?)?.toDouble() ?? 0.0,
      leads: (json['leads'] as num?)?.toInt() ?? 0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class GrowthHistoryPoint {
  final String id;
  final int score;
  final DateTime recordedAt;

  GrowthHistoryPoint({
    required this.id,
    required this.score,
    required this.recordedAt,
  });

  factory GrowthHistoryPoint.fromJson(Map<String, dynamic> json) {
    return GrowthHistoryPoint(
      id: json['id'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      recordedAt: DateTime.tryParse(json['recordedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class GrowthData {
  final String businessId;
  final String businessName;
  final int growthScore;
  final int monthlyGrowth;
  final List<ScorePillar> pillars;
  final List<GrowthRecommendation> recommendations;
  final List<GrowthTask> tasks;
  final List<OpportunityItem> opportunities;
  final GrowthMetrics? metrics;
  final List<GrowthHistoryPoint> history;

  GrowthData({
    required this.businessId,
    required this.businessName,
    required this.growthScore,
    required this.monthlyGrowth,
    required this.pillars,
    required this.recommendations,
    required this.tasks,
    required this.opportunities,
    this.metrics,
    this.history = const [],
  });

  factory GrowthData.fromJson(Map<String, dynamic> json, {List<GrowthHistoryPoint> history = const []}) {
    return GrowthData(
      businessId: json['businessId'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      growthScore: (json['growthScore'] as num?)?.toInt() ?? 0,
      monthlyGrowth: (json['monthlyGrowth'] as num?)?.toInt() ?? 0,
      pillars: (json['pillars'] as List?)
              ?.map((p) => ScorePillar.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      recommendations: (json['recommendations'] as List?)
              ?.map((r) => GrowthRecommendation.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      tasks: (json['tasks'] as List?)
              ?.map((t) => GrowthTask.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      opportunities: (json['opportunities'] as List?)
              ?.map((o) => OpportunityItem.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      metrics: json['metrics'] != null ? GrowthMetrics.fromJson(json['metrics'] as Map<String, dynamic>) : null,
      history: history,
    );
  }
}

class GrowthState {
  final bool isLoading;
  final GrowthData? data;
  final String? errorMessage;

  GrowthState({
    required this.isLoading,
    this.data,
    this.errorMessage,
  });

  GrowthState copyWith({
    bool? isLoading,
    GrowthData? data,
    String? errorMessage,
  }) {
    return GrowthState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class GrowthNotifier extends StateNotifier<GrowthState> {
  GrowthNotifier() : super(GrowthState(isLoading: false));

  final Dio _dio = DioService.instance;

  Future<void> loadGrowthData() async {
    state = GrowthState(isLoading: true);
    try {
      final response = await _dio.get(ApiConstants.businessGrowth);
      
      List<GrowthHistoryPoint> historyPoints = [];
      try {
        final historyRes = await _dio.get('${ApiConstants.businessGrowth}/history');
        if (historyRes.statusCode == 200 && historyRes.data['success'] == true) {
          historyPoints = (historyRes.data['data'] as List)
              .map((h) => GrowthHistoryPoint.fromJson(h as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}

      if (response.statusCode == 200 && response.data['success'] == true) {
        final growthData = GrowthData.fromJson(
          response.data['data'] as Map<String, dynamic>,
          history: historyPoints,
        );
        state = GrowthState(isLoading: false, data: growthData);
      } else {
        state = GrowthState(
          isLoading: false,
          errorMessage: 'Failed to load growth metrics',
        );
      }
    } catch (e) {
      state = GrowthState(
        isLoading: false,
        errorMessage:
            'Create a business profile first to view growth analytics.',
      );
    }
  }
}

final growthProvider =
    StateNotifierProvider<GrowthNotifier, GrowthState>((ref) {
  return GrowthNotifier();
});
