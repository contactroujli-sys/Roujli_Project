import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'domain/entities/explore_business.dart';
import '../requests/add_request_screen.dart';
import '../chat/presentation/providers/chat_provider.dart';
import 'presentation/providers/explore_provider.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  final String businessId;

  const BusinessProfileScreen({
    super.key,
    required this.businessId,
  });

  @override
  ConsumerState<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color goldColor = Color(0xFFD4AF37);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color darkBg = Color(0xFF0D0D0D);

  BusinessDetail? _business;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(exploreRepositoryProvider);
      final details = await repo.getBusinessById(widget.businessId);
      if (mounted) {
        setState(() {
          _business = details;
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

  Future<void> _toggleFollow() async {
    if (_business == null) return;
    final newFollowed = !_business!.isFollowed;
    final newCount = newFollowed
        ? _business!.followersCount + 1
        : (_business!.followersCount > 0 ? _business!.followersCount - 1 : 0);

    setState(() {
      _business = BusinessDetail(
        id: _business!.id,
        name: _business!.name,
        slug: _business!.slug,
        description: _business!.description,
        logo: _business!.logo,
        cover: _business!.cover,
        category: _business!.category,
        location: _business!.location,
        rating: _business!.rating,
        reviews: _business!.reviews,
        growthScore: _business!.growthScore,
        monthlyGrowth: _business!.monthlyGrowth,
        verified: _business!.verified,
        followersCount: newCount,
        isSaved: _business!.isSaved,
        isFollowed: newFollowed,
        phone: _business!.phone,
        email: _business!.email,
        website: _business!.website,
        whatsapp: _business!.whatsapp,
        address: _business!.address,
        productsCount: _business!.productsCount,
        servicesCount: _business!.servicesCount,
        offersCount: _business!.offersCount,
        products: _business!.products,
        services: _business!.services,
        offers: _business!.offers,
      );
    });

    try {
      final repo = ref.read(exploreRepositoryProvider);
      await repo.toggleFollow(widget.businessId);
    } catch (e) {
      _loadDetails(); // revert on failure
    }
  }

  Future<void> _toggleSave() async {
    if (_business == null) return;
    final newSaved = !_business!.isSaved;

    setState(() {
      _business = BusinessDetail(
        id: _business!.id,
        name: _business!.name,
        slug: _business!.slug,
        description: _business!.description,
        logo: _business!.logo,
        cover: _business!.cover,
        category: _business!.category,
        location: _business!.location,
        rating: _business!.rating,
        reviews: _business!.reviews,
        growthScore: _business!.growthScore,
        monthlyGrowth: _business!.monthlyGrowth,
        verified: _business!.verified,
        followersCount: _business!.followersCount,
        isSaved: newSaved,
        isFollowed: _business!.isFollowed,
        phone: _business!.phone,
        email: _business!.email,
        website: _business!.website,
        whatsapp: _business!.whatsapp,
        address: _business!.address,
        productsCount: _business!.productsCount,
        servicesCount: _business!.servicesCount,
        offersCount: _business!.offersCount,
        products: _business!.products,
        services: _business!.services,
        offers: _business!.offers,
      );
    });

    try {
      final repo = ref.read(exploreRepositoryProvider);
      await repo.toggleSave(widget.businessId);
    } catch (e) {
      _loadDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: darkBg,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(goldColor),
          ),
        ),
      );
    }

    if (_error != null || _business == null) {
      return Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(_error ?? 'Business not found', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDetails,
                style: ElevatedButton.styleFrom(backgroundColor: goldColor),
                child: const Text('Retry', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    final b = _business!;

    return Scaffold(
      backgroundColor: darkBg,
      body: CustomScrollView(
        slivers: [
          // Header Cover Image
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: darkBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  b.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: b.isSaved ? goldColor : Colors.white,
                ),
                onPressed: _toggleSave,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  b.cover != null && b.cover!.isNotEmpty
                      ? Image.network(
                          b.cover!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _placeholderCover(),
                        )
                      : _placeholderCover(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          darkBg.withValues(alpha: 0.8),
                          darkBg,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      if (b.monthlyGrowth > 0)
                        _buildBadge(
                          icon: Icons.trending_up,
                          text: '+${b.monthlyGrowth}% Growth',
                          color: Colors.green,
                        ),
                      if (b.monthlyGrowth > 0) const SizedBox(width: 8),
                      _buildBadge(
                        icon: Icons.star,
                        text: 'Score ${b.growthScore}',
                        color: goldColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Logo + Name + Category
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: goldColor,
                          borderRadius: BorderRadius.circular(12),
                          image: b.logo != null && b.logo!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(b.logo!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: b.logo == null || b.logo!.isEmpty
                            ? Center(
                                child: Text(
                                  b.name.isNotEmpty ? b.name[0].toUpperCase() : 'B',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            : null,
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
                                    b.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (b.verified) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified, color: goldColor, size: 18),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: goldColor, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${b.rating} (${b.reviews})',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                if (b.location != null && b.location!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.location_on, color: Colors.white54, size: 14),
                                  Text(
                                    ' ${b.location}',
                                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  if (b.description != null && b.description!.isNotEmpty)
                    Text(
                      b.description!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    children: [
                      _buildStatCard('${b.followersCount}', 'Followers'),
                      const SizedBox(width: 10),
                      _buildStatCard('${b.productsCount}', 'Products'),
                      const SizedBox(width: 10),
                      _buildStatCard('${b.servicesCount}', 'Services'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Follow Button
                  GestureDetector(
                    onTap: _toggleFollow,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: b.isFollowed ? darkCard : goldColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: b.isFollowed ? goldColor : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            b.isFollowed ? Icons.check : Icons.add,
                            color: b.isFollowed ? goldColor : Colors.black,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            b.isFollowed ? 'Following' : 'Follow Business',
                            style: TextStyle(
                              color: b.isFollowed ? goldColor : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${b.followersCount} followers',
                            style: TextStyle(
                              color: b.isFollowed ? Colors.white54 : Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Chat Button
                  GestureDetector(
                    onTap: () async {
                      try {
                        // Show loading indicator dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(goldColor),
                            ),
                          ),
                        );
                        
                        final chatDs = ref.read(chatRemoteDataSourceProvider);
                        final conv = await chatDs.startConversation(b.id);
                        
                        if (context.mounted) {
                          Navigator.pop(context); // Close loading dialog
                          context.push('/chat/${conv.id}', extra: b.name);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context); // Close loading dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to start chat: $e')),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: goldColor,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: goldColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Chat with Business',
                            style: TextStyle(
                              color: goldColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: goldColor,
                    indicatorWeight: 3,
                    labelColor: goldColor,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Products'),
                      Tab(text: 'Services'),
                      Tab(text: 'Offers'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tab Views
                  SizedBox(
                    height: 480,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(b),
                        _buildProductsTab(b.products),
                        _buildServicesTab(b.services),
                        _buildOffersTab(b.offers),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderCover() {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: const Icon(Icons.business, size: 64, color: Colors.white24),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: darkCard,
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
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BusinessDetail b) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (b.location != null && b.location!.isNotEmpty)
            _buildInfoRow(Icons.location_on, 'Location', b.location!),
          if (b.website != null && b.website!.isNotEmpty)
            _buildInfoRow(Icons.language, 'Website', b.website!),
          if (b.phone != null && b.phone!.isNotEmpty)
            _buildInfoRow(Icons.phone, 'Phone', b.phone!),
          if (b.whatsapp != null && b.whatsapp!.isNotEmpty)
            _buildInfoRow(Icons.chat, 'WhatsApp', b.whatsapp!),
          if (b.email != null && b.email!.isNotEmpty)
            _buildInfoRow(Icons.email, 'Email', b.email!),
        ],
      ),
    );
  }

  Widget _buildProductsTab(List<ProductItem> products) {
    if (products.isEmpty) {
      return const Center(
        child: Text('No products available', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return GestureDetector(
          onTap: () => _navigateToRequest('PRODUCT', p.id, p.name, price: p.price),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.image != null && p.image!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      p.image!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            if (p.description != null) ...[
                              const SizedBox(height: 4),
                              Text(p.description!, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                            ],
                            const SizedBox(height: 8),
                            Text('${p.price.toStringAsFixed(0)} DZ', style: const TextStyle(color: goldColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: goldColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Request', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicesTab(List<ServiceItem> services) {
    if (services.isEmpty) {
      return const Center(
        child: Text('No services available', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.builder(
      itemCount: services.length,
      itemBuilder: (context, index) {
        final s = services[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.track_changes, color: Colors.redAccent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      s.duration != null ? '${s.duration! ~/ 60}h session' : 'Custom Session',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${s.price.toStringAsFixed(0)} DZ', style: const TextStyle(color: goldColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _navigateToRequest('SERVICE', s.id, s.name, price: s.price, duration: s.duration),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: goldColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('Request', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOffersTab(List<OfferItem> offers) {
    if (offers.isEmpty) {
      return const Center(
        child: Text('No offers available', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final o = offers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: goldColor.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(o.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              if (o.description != null) ...[
                const SizedBox(height: 4),
                Text(o.description!, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  if (o.discount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: goldColor, width: 0.8),
                      ),
                      child: Text(
                        'SAVE ${o.discount}%',
                        style: const TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _navigateToRequest('OFFER', o.id, o.title, discount: o.discount),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: goldColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Claim', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToRequest(String type, String itemId, String itemName, {double? price, int? duration, double? discount}) {
    if (_business == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddRequestScreen(
          businessId: _business!.id,
          businessName: _business!.name,
          requestType: type,
          itemId: itemId,
          itemName: itemName,
          price: price,
          duration: duration,
          discount: discount,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: goldColor, size: 20),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}