import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/dio_service.dart';
import '../profile/presentation/providers/profile_provider.dart';

/// Show Subscription Plans Dialog
Future<void> showSubscriptionDialog(BuildContext context, WidgetRef ref) async {
  showDialog(
    context: context,
    builder: (ctx) => _SubscriptionDialog(ref: ref),
  );
}

class _SubscriptionDialog extends StatefulWidget {
  final WidgetRef ref;
  const _SubscriptionDialog({required this.ref});

  @override
  State<_SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<_SubscriptionDialog> {
  List<dynamic> _plans = [];
  Map<String, dynamic>? _mySubscription;
  bool _isLoading = true;
  String? _error;

  static const Color darkBg = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color gold = Color(0xFFD4AF37);
  static const Color border = Color(0xFF2C2C2C);

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = DioService.instance;
      final plansRes = await dio.get(ApiConstants.subscriptionPlans);

      try {
        final mySubRes = await dio.get(ApiConstants.mySubscription);
        _mySubscription = mySubRes.data['data'];
      } catch (_) {}

      if (mounted) {
        final rawPlans = (plansRes.data['data'] as List?) ?? [];
        setState(() {
          _plans = rawPlans.where((p) {
            final type = p['type'] as String?;
            final name = p['name'] as String?;
            return name != null && name.isNotEmpty && ['START', 'GROW', 'SCALE', 'ENTERPRISE'].contains(type);
          }).toList();
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

  void _onSelectPlan(Map<String, dynamic> plan) {
    final type = plan['type'] ?? 'START';
    final price = (plan['price'] as num?)?.toDouble() ?? 0.0;

    if (type == 'START' || price == 0) {
      _executeSubscription(type);
      return;
    }

    // Open Chargily Checkout Flow
    _showChargilyCheckout(plan);
  }

  Future<void> _executeSubscription(String planType) async {
    try {
      final dio = DioService.instance;
      final response = await dio.post(ApiConstants.subscribe, data: {'planType': planType});

      // Reload profile state so subscription status updates everywhere
      widget.ref.read(profileStateProvider.notifier).loadProfileData();

      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Successfully subscribed to $planType!'),
            backgroundColor: Colors.green,
          ),
        );
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

  void _showChargilyCheckout(Map<String, dynamic> plan) {
    final name = plan['name'] ?? '';
    final type = plan['type'] ?? '';
    final price = (plan['price'] as num?)?.toDouble() ?? 0.0;
    final currency = plan['currency'] ?? 'DZD';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ChargilyCheckoutModal(
        planName: name,
        planType: type,
        price: price,
        currency: currency,
        onPaymentSuccess: () {
          Navigator.pop(ctx); // Close Chargily modal
          _executeSubscription(type); // Execute subscription update
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePlanType = _mySubscription?['plan']?['type'] ?? 'START';

    return Dialog(
      backgroundColor: darkBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 650, maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.workspace_premium, color: gold, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'ROUJLI Plans',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: border),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: gold))
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
                      : ListView.builder(
                          itemCount: _plans.length,
                          itemBuilder: (context, index) {
                            final plan = _plans[index];
                            final type = plan['type'] ?? '';
                            final name = plan['name'] ?? type;
                            final price = (plan['price'] as num?)?.toDouble() ?? 0.0;
                            final currency = plan['currency'] ?? 'DZD';
                            final suitableFor = plan['suitableFor'] ?? '';
                            final features = (plan['features'] as List?)?.cast<String>() ?? [];
                            final isActive = activePlanType == type;
                            final isPopular = type == 'SCALE';

                            String priceDisplay = '0 DZD';
                            if (type == 'ENTERPRISE') {
                              priceDisplay = 'From 15,000 DZD / mo';
                            } else if (price > 0) {
                              priceDisplay = '${price.toStringAsFixed(0)} $currency / mo';
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: darkCard,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isPopular ? gold : (isActive ? Colors.green : border),
                                  width: isPopular ? 2 : 1,
                                ),
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
                                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          if (isPopular) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: gold.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: gold),
                                              ),
                                              child: const Text(
                                                'POPULAR',
                                                style: TextStyle(color: gold, fontSize: 9, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        priceDisplay,
                                        style: const TextStyle(color: gold, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  if (suitableFor.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      suitableFor,
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  ...features.map((feat) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check, color: gold, size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                feat,
                                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: isActive ? null : () => _onSelectPlan(plan),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isActive ? Colors.grey[800] : (isPopular ? gold : const Color(0xFF2E2E2E)),
                                        foregroundColor: isPopular && !isActive ? Colors.black : Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: Text(
                                        isActive ? 'Active Plan' : 'Select $name Plan',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChargilyCheckoutModal extends StatefulWidget {
  final String planName;
  final String planType;
  final double price;
  final String currency;
  final VoidCallback onPaymentSuccess;

  const _ChargilyCheckoutModal({
    required this.planName,
    required this.planType,
    required this.price,
    required this.currency,
    required this.onPaymentSuccess,
  });

  @override
  State<_ChargilyCheckoutModal> createState() => _ChargilyCheckoutModalState();
}

class _ChargilyCheckoutModalState extends State<_ChargilyCheckoutModal> {
  String _selectedMethod = 'EDAHABIA';
  bool _isProcessing = false;

  static const Color chargilyGreen = Color(0xFF00A859);
  static const Color darkCard = Color(0xFF1E1E1E);

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate Chargily gateway processing
    if (mounted) {
      widget.onPaymentSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chargily Header Badge
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: chargilyGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: chargilyGreen),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock, color: chargilyGreen, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Chargily Pay',
                          style: TextStyle(color: chargilyGreen, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.price.toStringAsFixed(0)} ${widget.currency}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Upgrading to ${widget.planName} Plan',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),

          const Text(
            'Select Payment Method',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),

          // Payment Methods
          _buildPaymentMethodTile(
            id: 'EDAHABIA',
            title: 'Edahabia (Algérie Poste)',
            subtitle: 'Pay securely using your Edahabia card',
            icon: Icons.credit_card,
          ),
          const SizedBox(height: 10),
          _buildPaymentMethodTile(
            id: 'CIB',
            title: 'CIB Bank Card',
            subtitle: 'Interbank card payment',
            icon: Icons.account_balance,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: chargilyGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Processing Chargily Pay...'),
                      ],
                    )
                  : Text(
                      'Pay ${widget.price.toStringAsFixed(0)} ${widget.currency} via Chargily',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? chargilyGreen : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? chargilyGreen : Colors.white60, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: chargilyGreen, size: 20),
          ],
        ),
      ),
    );
  }
}
