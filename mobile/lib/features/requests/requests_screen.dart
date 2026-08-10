import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/dio_service.dart';
import '../profile/presentation/providers/profile_provider.dart';
import 'request_detail_screen.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _myRequests = [];
  List<dynamic> _incomingRequests = [];
  bool _isLoadingMy = true;
  bool _isLoadingIncoming = true;
  String? _myError;
  String? _incomingError;

  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color goldColor = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllRequests() async {
    _loadMyRequests();
    _loadIncomingRequests();
  }

  Future<void> _loadMyRequests() async {
    setState(() {
      _isLoadingMy = true;
      _myError = null;
    });
    try {
      final dio = DioService.instance;
      final response = await dio.get(ApiConstants.myRequests);
      if (mounted) {
        setState(() {
          _myRequests = response.data['data'] ?? [];
          _isLoadingMy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _myError = e.toString().replaceAll('Exception: ', '');
          _isLoadingMy = false;
        });
      }
    }
  }

  Future<void> _loadIncomingRequests() async {
    setState(() {
      _isLoadingIncoming = true;
      _incomingError = null;
    });
    try {
      final dio = DioService.instance;
      final response = await dio.get(ApiConstants.incomingRequests);
      if (mounted) {
        setState(() {
          _incomingRequests = response.data['data'] ?? [];
          _isLoadingIncoming = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _incomingError = e.toString().replaceAll('Exception: ', '');
          _isLoadingIncoming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasBusiness = ref.watch(profileStateProvider).profileData?.user.business != null;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Requests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: goldColor,
          labelColor: goldColor,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: [
            const Tab(text: 'My Requests'),
            Tab(text: hasBusiness ? 'Business Orders' : 'Incoming'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyRequestsTab(),
          _buildIncomingRequestsTab(hasBusiness),
        ],
      ),
    );
  }

  Widget _buildMyRequestsTab() {
    if (_isLoadingMy) {
      return const Center(child: CircularProgressIndicator(color: goldColor));
    }
    if (_myError != null) {
      return _buildErrorView(_myError!, _loadMyRequests);
    }
    if (_myRequests.isEmpty) {
      return _buildEmptyView('No outgoing requests', 'When you request products or services from businesses, they will appear here.');
    }
    return RefreshIndicator(
      onRefresh: _loadMyRequests,
      color: goldColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myRequests.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(_myRequests[index], isIncoming: false);
        },
      ),
    );
  }

  Widget _buildIncomingRequestsTab(bool hasBusiness) {
    if (!hasBusiness) {
      return _buildEmptyView(
        'No Business Profile',
        'Create a business profile to start receiving product and service requests from customers.',
      );
    }
    if (_isLoadingIncoming) {
      return const Center(child: CircularProgressIndicator(color: goldColor));
    }
    if (_incomingError != null) {
      return _buildErrorView(_incomingError!, _loadIncomingRequests);
    }
    if (_incomingRequests.isEmpty) {
      return _buildEmptyView(
        'No incoming requests',
        'Customer orders and service requests for your business will appear here.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadIncomingRequests,
      color: goldColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _incomingRequests.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(_incomingRequests[index], isIncoming: true);
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req, {required bool isIncoming}) {
    final status = req['status'] ?? 'PENDING';
    final type = req['type'] ?? 'PRODUCT';
    final businessName = req['business']?['name'] ?? 'Business';
    final itemName = req['product']?['name'] ?? req['service']?['name'] ?? req['offer']?['title'] ?? 'Item';

    Color statusColor = goldColor;
    if (status == 'ACCEPTED') statusColor = Colors.green;
    if (status == 'REJECTED') statusColor = Colors.redAccent;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RequestDetailScreen(
              requestId: req['id'],
              isOwnerView: isIncoming,
            ),
          ),
        );
        if (result == true) {
          _loadAllRequests();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 0.8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Text(
                  type,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              itemName,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isIncoming ? 'From: ${req['name'] ?? 'Customer'}' : 'To: $businessName',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
            if (req['note'] != null && req['note'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Note: ${req['note']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: goldColor),
            child: const Text('Retry', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
