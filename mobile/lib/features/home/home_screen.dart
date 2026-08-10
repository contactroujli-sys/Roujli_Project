import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/verification_reminder_service.dart';
import '../auth/presentation/screens/verify_email_screen.dart';
import '../../shared/services/storage_service.dart';
import '../explore/bussiness_details_screen.dart';
import '../notifications/unread_notifications_provider.dart';
import 'domain/entities/home_data.dart';
import 'presentation/providers/home_provider.dart';
import 'presentation/providers/growth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load home & growth data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeStateProvider.notifier).loadHomeData();
      ref.read(growthProvider.notifier).loadGrowthData();
    });
    
    // Start periodic verification reminders
    VerificationReminderService.startPeriodicReminders(context);
    
    // Check immediately on app start
    _checkVerificationReminder();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Stop periodic reminders when leaving home screen
    VerificationReminderService.stopPeriodicReminders();
    super.dispose();
  }

  Future<void> _checkVerificationReminder() async {
    final shouldShow = await VerificationReminderService.shouldShowVerificationReminder();
    if (shouldShow && mounted) {
      VerificationReminderService.showVerificationReminder(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeStateProvider);
    final growthState = ref.watch(growthProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: homeState.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8B923)),
                ),
              )
            : homeState.errorMessage != null
                ? _buildErrorView(homeState.errorMessage!)
                : homeState.homeData == null
                    ? const Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Header
                            _buildHeader(),
                            const SizedBox(height: 20),

                            // Search Bar
                            _buildSearchBar(),
                            const SizedBox(height: 20),

                            // Smart Business Growth Ecosystem (Priority 1-7)
                            _buildSmartGrowthEcosystemSection(growthState, homeState.homeData!.growthScore),
                            const SizedBox(height: 20),

                            // Stats Row
                            _buildStatsRow(homeState.homeData!.stats.cast<Stat>()),
                            const SizedBox(height: 16),

                            // AI Assistant
                            _buildAIAssistantCard(),
                            const SizedBox(height: 24),

                            // Categories
                            _buildCategoriesSection(homeState.homeData!.categories.cast<Category>()),
                            const SizedBox(height: 24),

                            // Trending Businesses
                            _buildTrendingBusinesses(homeState.homeData!.trendingBusinesses.cast<Business>()),
                            const SizedBox(height: 24),

                            // Recommended For You
                            _buildRecommendedSection(homeState.homeData!.recommendedBusinesses.cast<Business>()),
                            const SizedBox(height: 24),

                            // Trending Offers
                            _buildTrendingOffers(homeState.homeData!.trendingOffers.cast<Offer>()),
                            const SizedBox(height: 24),

                            // Growing Now
                            _buildGrowingNowSection(homeState.homeData!.growingBusinesses.cast<Business>()),
                            const SizedBox(height: 24),

                            // Business Insights
                            _buildBusinessInsights(homeState.homeData!.businessInsights.cast<BusinessInsight>()),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(homeStateProvider.notifier).refreshData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8B923),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return FutureBuilder<String?>(
      future: StorageService.getUserJson(),
      builder: (context, snapshot) {
        String name = 'User';
        String userEmail = '';
        bool isVerified = false;
        if (snapshot.hasData && snapshot.data != null) {
          try {
            final data = snapshot.data!;
            if (data.contains('"firstName"')) {
              final match = RegExp(r'"firstName"\s*:\s*"([^"]+)"').firstMatch(data);
              if (match != null && match.group(1) != null) {
                name = match.group(1)!;
              }
            }
            if (data.contains('"email"')) {
              final matchEmail = RegExp(r'"email"\s*:\s*"([^"]+)"').firstMatch(data);
              if (matchEmail != null && matchEmail.group(1) != null) {
                userEmail = matchEmail.group(1)!;
              }
            }
            if (data.contains('"isVerified"')) {
              isVerified = data.contains('"isVerified":true');
            }
          } catch (_) {}
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome,',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: isVerified
                  ? null
                  : () async {
                      final email = userEmail.isNotEmpty
                          ? userEmail
                          : await StorageService.getPendingVerificationEmail();
                      if (email != null && email.isNotEmpty && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerifyEmailScreen(email: email),
                          ),
                        );
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFFE8B923).withValues(alpha: 0.15)
                      : Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isVerified
                        ? const Color(0xFFE8B923).withValues(alpha: 0.4)
                        : Colors.redAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isVerified ? Icons.verified : Icons.error_outline,
                      color: isVerified ? const Color(0xFFE8B923) : Colors.redAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isVerified ? 'Verified' : 'Not Verified',
                      style: TextStyle(
                        color: isVerified ? const Color(0xFFE8B923) : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  context.push('/explore?q=${Uri.encodeComponent(query.trim())}');
                }
              },
              decoration: const InputDecoration(
                hintText: 'Search businesses, services...',
                hintStyle: TextStyle(
                  color: Color(0xFF6B6B6B),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF9E9E9E),
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            final query = _searchController.text.trim();
            context.push('/explore${query.isNotEmpty ? '?q=${Uri.encodeComponent(query)}' : ''}');
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFE8B923),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Search',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== SMART BUSINESS GROWTH ECOSYSTEM ====================
  Widget _buildSmartGrowthEcosystemSection(GrowthState growthState, BusinessGrowthScore fallbackScore) {
    if (growthState.isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8B923).withValues(alpha: 0.2)),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8B923)),
          ),
        ),
      );
    }

    final data = growthState.data;
    if (data == null) {
      return _buildFallbackGrowthScoreCard(fallbackScore);
    }

    final isPositive = data.monthlyGrowth >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Growth Score Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E1F2E), Color(0xFF141524)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE8B923).withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE8B923).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: CircularProgressIndicator(
                            value: data.growthScore / 100,
                            strokeWidth: 7,
                            strokeCap: StrokeCap.round,
                            backgroundColor: const Color(0xFF2A2A38),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE8B923)),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${data.growthScore}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '/ 100',
                              style: TextStyle(color: Color(0xFF8A8E9D), fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Business Growth Score',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isPositive ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isPositive ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPositive ? Icons.trending_up : Icons.trending_down,
                                size: 12,
                                color: isPositive ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${isPositive ? '+' : ''}${data.monthlyGrowth} points this month',
                                style: TextStyle(
                                  color: isPositive ? Colors.green : Colors.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Evaluated in real-time from active offerings, response speed, and trust signals.',
                          style: TextStyle(color: Color(0xFF8A8E9D), fontSize: 10, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Score Breakdown ("Why this score?")
        if (data.pillars.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF14141A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Why this score?',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total: ${data.growthScore}/100',
                      style: const TextStyle(color: Color(0xFFE8B923), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...data.pillars.map((pillar) {
                  final pct = pillar.maxScore > 0 ? (pillar.score / pillar.maxScore) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pillar.name,
                              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '+${pillar.score} / ${pillar.maxScore}',
                              style: const TextStyle(color: Color(0xFFE8B923), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: const Color(0xFF222332),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              pct >= 0.8 ? const Color(0xFF10B981) : pct >= 0.5 ? const Color(0xFFE8B923) : Colors.orangeAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 3. Personalized Growth Recommendations
        if (data.recommendations.isNotEmpty) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFFE8B923), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Personalized Recommendations',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...data.recommendations.map((rec) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14141A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8B923).withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8B923).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.lightbulb_outline, color: Color(0xFFE8B923), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rec.recommendation,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Problem: ${rec.problem}',
                                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(rec.reason, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1F2E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.rocket_launch, color: Color(0xFF10B981), size: 13),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Impact: ${rec.expectedImpact}',
                                style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // 4. Actionable Tasks
        if (data.tasks.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF14141A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Actionable Growth Tasks',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${data.tasks.where((t) => t.completed).length} / ${data.tasks.length}',
                      style: const TextStyle(color: Color(0xFF8A8E9D), fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...data.tasks.map((task) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1F2E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: task.completed ? const Color(0xFF10B981) : const Color(0xFF8A8E9D),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              color: task.completed ? Colors.white54 : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              decoration: task.completed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8B923).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '+${task.points} pts',
                            style: const TextStyle(color: Color(0xFFE8B923), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 5. Matched Opportunities
        if (data.opportunities.isNotEmpty) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.handshake_outlined, color: Color(0xFFE8B923), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Matched Opportunities',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...data.opportunities.map((opp) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14141A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.business_center, color: Color(0xFFE8B923), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(opp.title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(opp.matchReason, style: const TextStyle(color: Color(0xFF8A8E9D), fontSize: 10)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1F2E),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(opp.type, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // 6. Growth History Timeline
        if (data.history.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF14141A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Growth Trajectory', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...data.history.map((pt) {
                  final dateStr = '${pt.recordedAt.day.toString().padLeft(2, '0')}/${pt.recordedAt.month.toString().padLeft(2, '0')}';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateStr, style: const TextStyle(color: Color(0xFF8A8E9D), fontSize: 11)),
                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: pt.score / 100,
                                  backgroundColor: const Color(0xFF222332),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE8B923)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${pt.score} pts', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFallbackGrowthScoreCard(BusinessGrowthScore growthScore) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: growthScore.score / 100,
                    strokeWidth: 5,
                    backgroundColor: const Color(0xFF2A2A2A),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE8B923)),
                  ),
                ),
                Text(
                  '${growthScore.score}',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Business Growth Score',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text('Score: ${growthScore.score}/100', style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STATS ROW ====================
  Widget _buildStatsRow(List<Stat> stats) {
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildStatCard(stat.value, stat.label, stat.change, stat.isPositive),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(
      String value,
      String label,
      String change,
      bool isPositive,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== AI ASSISTANT ====================
  Widget _buildAIAssistantCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Color(0xFFE8B923),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'ROUJLI AI Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8B923).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'COMING SOON',
                        style: TextStyle(
                          color: Color(0xFFE8B923),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Smart recommendations, instant answers, and AI-powered business insights.',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF9E9E9E),
          ),
        ],
      ),
    );
  }

  // ==================== CATEGORIES ====================
  Widget _buildCategoriesSection(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'All',
                style: TextStyle(
                  color: Color(0xFFE8B923),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = cat.name == 'All';
              return Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE8B923).withValues(alpha: 0.15)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFE8B923)
                        : const Color(0xFF2A2A2A),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForCategory(cat.icon),
                      color: isSelected
                          ? const Color(0xFFE8B923)
                          : const Color(0xFF9E9E9E),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFE8B923)
                            : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'all':
        return Icons.apps;
      case 'technology':
        return Icons.memory;
      case 'finance':
        return Icons.account_balance;
      case 'legal':
        return Icons.gavel;
      case 'health':
        return Icons.health_and_safety;
      case 'education':
        return Icons.school;
      case 'retail':
        return Icons.shopping_cart;
      case 'food':
        return Icons.restaurant;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  // ==================== TRENDING BUSINESSES ====================
  Widget _buildTrendingBusinesses(List<Business> businesses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFE8B923),
                  size: 20,
                ),
                SizedBox(width: 6),
                Text(
                  'Trending Businesses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See all',
                style: TextStyle(
                  color: Color(0xFFE8B923),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const Text(
          'Growing fast right now',
          style: TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        businesses.isEmpty
            ? Container(
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Nothing',
                  style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 15),
                ),
              )
            : SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    return _buildBusinessCard(businesses[index]);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildBusinessCard(Business business) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BusinessProfileScreen(businessId: business.id),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Image Placeholder
          Container(
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: business.imageUrl != null && business.imageUrl!.isNotEmpty
                      ? Image.network(business.imageUrl!, fit: BoxFit.cover)
                      : const Icon(
                          Icons.business,
                          color: Color(0xFF6B6B6B),
                          size: 36,
                        ),
                ),
                if (business.isVerified)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8B923),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Color(0xFFE8B923),
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${business.rating}',
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      business.category,
                      style: TextStyle(
                        color: Colors.green.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  // ==================== RECOMMENDED ====================
  Widget _buildRecommendedSection(List<Business> businesses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: Color(0xFFE8B923),
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              'Recommended For You',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Based on your activity',
          style: TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        if (businesses.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Nothing',
              style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 15),
            ),
          )
        else ...
          businesses.map((business) => _buildRecommendedItem(business)),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'View all',
              style: TextStyle(
                color: Color(0xFFE8B923),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedItem(Business business) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BusinessProfileScreen(businessId: business.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                business.name.isNotEmpty ? business.name.substring(0, business.name.length >= 2 ? 2 : 1).toUpperCase() : 'BN',
                style: const TextStyle(
                  color: Color(0xFFE8B923),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        business.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (business.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFFE8B923),
                        size: 14,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${business.category} • ${business.location}',
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '★ ${business.rating}',
                style: TextStyle(
                  color: Colors.green.shade400,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${business.reviews} reviews',
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  // ==================== TRENDING OFFERS ====================
  Widget _buildTrendingOffers(List<Offer> offers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trending Offers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View all',
                style: TextStyle(
                  color: Color(0xFFE8B923),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (offers.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Nothing',
              style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 15),
            ),
          )
        else
          ...offers.map((offer) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildOfferItem(offer),
              )),
      ],
    );
  }

  Widget _buildOfferItem(Offer offer) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Color(0xFFE8B923),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  offer.businessName,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  offer.discount,
                  style: const TextStyle(
                    color: Color(0xFFE8B923),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFFE8B923),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${offer.expiresAt.difference(DateTime.now()).inDays.abs()} days',
                    style: const TextStyle(
                      color: Color(0xFFE8B923),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== GROWING NOW ====================
  Widget _buildGrowingNowSection(List<Business> businesses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              'Growing Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Highest growth this week',
          style: TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        if (businesses.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Nothing',
              style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 15),
            ),
          )
        else
          ...businesses.asMap().entries.map((entry) {
            return _buildGrowingItem(entry.key + 1, entry.value);
          }),
      ],
    );
  }

  Widget _buildGrowingItem(int rank, Business business) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BusinessProfileScreen(businessId: business.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
            '#$rank',
            style: const TextStyle(
              color: Color(0xFFE8B923),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                business.name.isNotEmpty ? business.name.substring(0, business.name.length >= 2 ? 2 : 1).toUpperCase() : 'BN',
                style: const TextStyle(
                  color: Color(0xFFE8B923),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        business.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (business.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFFE8B923),
                        size: 14,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  business.category,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '★ ${business.rating}',
                style: TextStyle(
                  color: Colors.green.shade400,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${business.reviews} reviews',
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  // ==================== BUSINESS INSIGHTS ====================
  Widget _buildBusinessInsights(List<BusinessInsight> insights) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildInsightItem(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BOTTOM NAV ====================
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(
          top: BorderSide(color: Color(0xFF1A1A1A), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Explore icon - navigate to explore screen
            context.push('/explore');
          } else if (index == 2) {
            // Messages icon - navigate to messages screen
            context.push('/messages');
          } else if (index == 3) {
            // Alerts icon - navigate to notifications screen
            context.push('/notifications');
          } else if (index == 4) {
            // Profile icon - navigate to profile screen
            context.push('/profile');
          } else {
            setState(() => _currentIndex = index);
          }
        },
        backgroundColor: const Color(0xFF0A0A0A),
        selectedItemColor: const Color(0xFFE8B923),
        unselectedItemColor: const Color(0xFF6B6B6B),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (ref.watch(unreadNotificationsProvider) > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4AF37),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.notifications),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}