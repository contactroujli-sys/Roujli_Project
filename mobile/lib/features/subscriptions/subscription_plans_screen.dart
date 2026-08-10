import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/dio_service.dart';

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends ConsumerState<SubscriptionPlansScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _plans = [];
  List<dynamic> _addOns = [];
  Map<String, dynamic>? _mySubscription;
  bool _isLoading = true;
  String? _error;

  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color darkCard = Color(0xFF161616);
  static const Color gold = Color(0xFFD4AF37);
  static const Color border = Color(0xFF262626);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = DioService.instance;
      final plansRes = await dio.get(ApiConstants.subscriptionPlans);
      final addOnsRes = await dio.get(ApiConstants.subscriptionAddOns);

      try {
        final mySubRes = await dio.get(ApiConstants.mySubscription);
        _mySubscription = mySubRes.data['data'];
      } catch (_) {
        // Guest user or unauthenticated
      }

      if (mounted) {
        setState(() {
          _plans = plansRes.data['data'] ?? [];
          _addOns = addOnsRes.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _subscribeToPlan(String planType) async {
    try {
      final dio = DioService.instance;
      final response = await dio.post(ApiConstants.subscribe, data: {'planType': planType});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Successfully subscribed to $planType plan!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSubscriptionData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscription failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Subscription Plans', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: gold,
          labelColor: gold,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'SaaS Plans'),
            Tab(text: 'Add-on Services'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : _error != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPlansTab(),
                    _buildAddOnsTab(),
                  ],
                ),
    );
  }

  Widget _buildPlansTab() {
    final activePlanType = _mySubscription?['plan']?['type'] ?? 'START';

    return RefreshIndicator(
      onRefresh: _loadSubscriptionData,
      color: gold,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _plans.length,
        itemBuilder: (context, index) {
          final plan = _plans[index];
          final type = plan['type'] ?? '';
          final name = plan['name'] ?? type;
          final price = (plan['price'] as num?)?.toDouble() ?? 0.0;
          final currency = plan['currency'] ?? 'DZ';
          final suitableFor = plan['suitableFor'] ?? '';
          final isCustomPrice = plan['isCustomPrice'] ?? false;
          final features = (plan['features'] as List?)?.cast<String>() ?? [];
          final isActive = activePlanType == type;
          final isPopular = type == 'SCALE';

          String priceDisplay = 'Free';
          if (isCustomPrice) {
            priceDisplay = 'Custom Pricing';
          } else if (price > 0) {
            priceDisplay = '${price.toStringAsFixed(0)} $currency / mo';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: darkCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPopular ? gold : (isActive ? Colors.green : border),
                width: isPopular ? 2 : 1,
              ),
              boxShadow: isPopular
                  ? [
                      BoxShadow(
                        color: gold.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        if (isPopular) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: gold),
                            ),
                            child: const Text(
                              'MOST POPULAR',
                              style: TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Text(
                          'CURRENT PLAN',
                          style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  priceDisplay,
                  style: const TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (suitableFor.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Suitable for: $suitableFor',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(color: border),
                const SizedBox(height: 12),
                ...features.map((feat) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: gold, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feat,
                              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isActive
                        ? null
                        : () {
                            if (isCustomPrice) {
                              _showContactSalesDialog();
                            } else {
                              _subscribeToPlan(type);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? Colors.grey[800] : (isPopular ? gold : const Color(0xFF262626)),
                      foregroundColor: isPopular && !isActive ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      isActive ? 'Active Plan' : (isCustomPrice ? 'Contact Sales' : 'Subscribe to $name'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddOnsTab() {
    return RefreshIndicator(
      onRefresh: _loadSubscriptionData,
      color: gold,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _addOns.length,
        itemBuilder: (context, index) {
          final addon = _addOns[index];
          final name = addon['name'] ?? '';
          final desc = addon['description'] ?? '';
          final price = (addon['price'] as num?)?.toDouble();
          final currency = addon['currency'] ?? 'DZ';
          final category = addon['category'] ?? 'ADD_ON';

          String priceDisplay = 'On Demand';
          if (price != null && price > 0) {
            priceDisplay = '${price.toStringAsFixed(0)} $currency';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star_outline, color: gold, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  category,
                                  style: TextStyle(color: gold.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              priceDisplay,
                              style: const TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Inquiry sent for $name. Our team will contact you.'),
                              backgroundColor: gold,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: gold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Add to Subscription', style: TextStyle(color: gold, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showContactSalesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkCard,
        title: const Text('Enterprise Solutions', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Our Enterprise plan provides dedicated infrastructure, API integrations, and custom dashboard solutions for large corporations.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enterprise inquiry submitted. Dedicated account manager will reach out.'),
                  backgroundColor: gold,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: gold),
            child: const Text('Contact Sales Team', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSubscriptionData,
            style: ElevatedButton.styleFrom(backgroundColor: gold),
            child: const Text('Retry', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
