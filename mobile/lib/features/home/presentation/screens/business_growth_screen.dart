import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../subscriptions/subscription_dialog.dart';
import '../providers/growth_provider.dart';

class BusinessGrowthScreen extends ConsumerStatefulWidget {
  const BusinessGrowthScreen({super.key});

  @override
  ConsumerState<BusinessGrowthScreen> createState() =>
      _BusinessGrowthScreenState();
}

class _BusinessGrowthScreenState extends ConsumerState<BusinessGrowthScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimController;
  late Animation<double> _scoreAnim;

  static const Color _bg = Color(0xFF080810);
  static const Color _card = Color(0xFF13141F);
  static const Color _gold = Color(0xFFE8B923);
  static const Color _surface = Color(0xFF1E1F2E);
  static const Color _muted = Color(0xFF8A8E9D);
  static const Color _success = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _scoreAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scoreAnim = CurvedAnimation(parent: _scoreAnimController, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(growthProvider.notifier).loadGrowthData();
    });
  }

  @override
  void dispose() {
    _scoreAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(growthProvider);

    if (state.data != null &&
        _scoreAnimController.status == AnimationStatus.dismissed) {
      _scoreAnimController.forward();
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(state),
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_gold),
                  ),
                ),
              )
            else if (state.errorMessage != null)
              SliverFillRemaining(child: _buildError(state.errorMessage!))
            else if (state.data == null)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No growth data available',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Growth Score Card
                    _buildScoreCard(state.data!),
                    const SizedBox(height: 24),

                    // 2. Score Breakdown ("WHY?")
                    _buildScoreBreakdown(state.data!),
                    const SizedBox(height: 24),

                    // 3. Personalized Growth Recommendations
                    if (state.data!.recommendations.isNotEmpty) ...[
                      _buildRecommendationsSection(state.data!),
                      const SizedBox(height: 24),
                    ],

                    // 4. Actionable Tasks
                    _buildTasksSection(state.data!),
                    const SizedBox(height: 24),

                    // 5. Relevant Opportunities
                    if (state.data!.opportunities.isNotEmpty) ...[
                      _buildOpportunitiesSection(state.data!),
                      const SizedBox(height: 24),
                    ],

                    // 6. Growth Insights & Metrics
                    if (state.data!.metrics != null) ...[
                      _buildMetricsSection(state.data!.metrics!),
                      const SizedBox(height: 24),
                    ],

                    // 7. Growth History
                    if (state.data!.history.isNotEmpty) ...[
                      _buildHistorySection(state.data!.history),
                      const SizedBox(height: 32),
                    ],
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── AppBar ─────────────────────────────
  Widget _buildAppBar(GrowthState state) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: _bg,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          tooltip: 'Subscription Plans',
          icon: const Icon(Icons.workspace_premium, color: _gold),
          onPressed: () => showSubscriptionDialog(context, ref),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Growth Assistant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (state.data != null)
              Text(
                state.data!.businessName,
                style: const TextStyle(
                  color: _gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF080810)],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── 1. Score Card ─────────────────────────
  Widget _buildScoreCard(GrowthData data) {
    final isPositive = data.monthlyGrowth >= 0;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1F2E), Color(0xFF16172A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _scoreAnim,
                builder: (context, _) {
                  final progress = (data.growthScore / 100) * _scoreAnim.value;
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: 1,
                            strokeWidth: 8,
                            backgroundColor: _surface,
                            valueColor: const AlwaysStoppedAnimation<Color>(_surface),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(data.growthScore * _scoreAnim.value).round()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '/ 100',
                              style: TextStyle(color: _muted, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Growth Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPositive ? _success.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isPositive ? _success.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            size: 14,
                            color: isPositive ? _success : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositive ? '+' : ''}${data.monthlyGrowth} points this month',
                            style: TextStyle(
                              color: isPositive ? _success : Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Evaluated in real-time from active catalog items, response performance, and customer trust signals.',
                      style: TextStyle(color: _muted, fontSize: 11, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────── 2. Score Breakdown ("WHY?") ─────────────────────────
  Widget _buildScoreBreakdown(GrowthData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total: ${data.growthScore}/100',
                style: const TextStyle(color: _gold, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Itemized evaluation across 6 operational business pillars',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
          const SizedBox(height: 16),
          ...data.pillars.map((pillar) {
            final pct = pillar.maxScore > 0 ? (pillar.score / pillar.maxScore) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pillar.name,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '+${pillar.score} / ${pillar.maxScore}',
                        style: const TextStyle(color: _gold, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: _surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pct >= 0.8 ? _success : pct >= 0.5 ? _gold : Colors.orangeAccent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ───────────────────────── 3. Personalized Recommendations ─────────────────────────
  Widget _buildRecommendationsSection(GrowthData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: _gold, size: 20),
            SizedBox(width: 8),
            Text(
              'Personalized Recommendations',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...data.recommendations.map((rec) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.lightbulb_outline, color: _gold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.recommendation,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Problem: ${rec.problem}',
                            style: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  rec.reason,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.rocket_launch, color: _success, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Expected Impact: ${rec.expectedImpact}',
                          style: const TextStyle(color: _success, fontSize: 11, fontWeight: FontWeight.w500),
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
    );
  }

  // ───────────────────────── 4. Actionable Tasks ─────────────────────────
  Widget _buildTasksSection(GrowthData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Actionable Tasks',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${data.tasks.where((t) => t.completed).length} / ${data.tasks.length} Completed',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Complete these tasks to directly improve measurable indicators and score',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
          const SizedBox(height: 16),
          ...data.tasks.map((task) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: task.completed ? _surface.withValues(alpha: 0.5) : _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: task.completed ? _success.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: task.completed ? _success : _muted,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            color: task.completed ? Colors.white70 : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.description,
                          style: const TextStyle(color: _muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+${task.points} pts',
                      style: const TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ───────────────────────── 5. Opportunities ─────────────────────────
  Widget _buildOpportunitiesSection(GrowthData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.handshake_outlined, color: _gold, size: 20),
            SizedBox(width: 8),
            Text(
              'Matched Business Opportunities',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...data.opportunities.map((opp) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.business_center, color: _gold, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opp.title,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        opp.matchReason,
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    opp.type,
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ───────────────────────── 6. Growth Insights & Metrics ─────────────────────────
  Widget _buildMetricsSection(GrowthMetrics m) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operational Indicators',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildMetricTile('Profile Views', '${m.profileViews}', Icons.visibility),
              _buildMetricTile('Leads Handled', '${m.leads}', Icons.inbox),
              _buildMetricTile('Conversion Rate', m.conversionRate, Icons.pie_chart),
              _buildMetricTile('Avg Response', m.responseTimeMins > 0 ? '${m.responseTimeMins.round()} min' : 'Insufficient data', Icons.timer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: _gold, size: 20),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: _muted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────── 7. Growth History ─────────────────────────
  Widget _buildHistorySection(List<GrowthHistoryPoint> history) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Growth Trajectory',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Historical Growth Score record',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
          const SizedBox(height: 14),
          ...history.map((pt) {
            final dateStr = '${pt.recordedAt.day.toString().padLeft(2, '0')}/${pt.recordedAt.month.toString().padLeft(2, '0')}';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateStr, style: const TextStyle(color: _muted, fontSize: 12)),
                  Row(
                    children: [
                      Container(
                        width: 120,
                        height: 6,
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: pt.score / 100,
                            backgroundColor: _surface,
                            valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                          ),
                        ),
                      ),
                      Text('${pt.score} pts', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.orangeAccent, size: 48),
            const SizedBox(height: 12),
            Text(msg, style: const TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(growthProvider.notifier).loadGrowthData(),
              style: ElevatedButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.black),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
