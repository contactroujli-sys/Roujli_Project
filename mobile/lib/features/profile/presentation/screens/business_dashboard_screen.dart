import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile_data.dart';
import '../providers/profile_provider.dart';
import 'business_form_screen.dart';
import '../../../products/create_product_screen.dart';
import '../../../services/create_service_screen.dart';
import '../../../offers/create_offer_screen.dart';

class BusinessDashboardScreen extends ConsumerStatefulWidget {
  final BusinessInfo business;
  final String? initialSection;

  const BusinessDashboardScreen({super.key, required this.business, this.initialSection});

  @override
  ConsumerState<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends ConsumerState<BusinessDashboardScreen> {
  late String _selectedSection;

  static const Color backgroundColor = Color(0xFF060607);
  static const Color cardColor = Color(0xFF131418);
  static const Color surfaceColor = Color(0xFF1F222A);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color muteColor = Color(0xFF8A8E9D);

  @override
  void initState() {
    super.initState();
    _selectedSection = widget.initialSection ?? 'Overview';
  }

  BusinessInfo get business => widget.business;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Business Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BusinessFormScreen(existingBusiness: business),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: cardColor,
                    title: const Text('Delete Business', style: TextStyle(color: Colors.white)),
                    content: const Text(
                      'Are you sure you want to delete this business? This action cannot be undone.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                await ref.read(profileStateProvider.notifier).deleteBusiness();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 18),
              _buildPerformanceCard(),
              const SizedBox(height: 18),
              _buildManagementActionsCard(),
              const SizedBox(height: 18),
              _buildContactCard(),
              const SizedBox(height: 18),
              _buildDetailsCard(),
              const SizedBox(height: 18),
              _buildSectionSelector(),
              const SizedBox(height: 18),
              _buildSectionCard('Selected section', _selectedSection),
              const SizedBox(height: 18),
              _buildSectionCard(
                'What’s next',
                'Use the profile menu to add products, services, or exclusive offers for your business.',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 72),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: business.cover != null
                ? Image.network(
                    business.cover!,
                    height: 170,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildCoverPlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 170,
                        color: const Color(0xFF16171D),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: accentColor,
                          ),
                        ),
                      );
                    },
                  )
                : _buildCoverPlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(),
                    const SizedBox(width: 14),
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _buildVerifiedBadge(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            business.slug,
                            style: const TextStyle(
                              color: muteColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  business.description ??
                      'No business description added yet. Update your profile to tell customers more about your brand and services.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _buildStatusChip(business.verified ? 'Verified Business' : 'Pending Verification'),
                    const SizedBox(width: 10),
                    _buildStatusChip('Premium Experience', background: const Color(0xFF26282F)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      height: 170,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF25272F), Color(0xFF14141A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.business_center_outlined,
          size: 48,
          color: Colors.white24,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: business.logo != null
            ? Image.network(
                business.logo!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: accentColor, size: 36),
              )
            : const Icon(Icons.business, color: accentColor, size: 36),
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: business.verified ? accentColor.withValues(alpha: 36) : const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            business.verified ? Icons.verified : Icons.hourglass_bottom,
            color: business.verified ? accentColor : Colors.white70,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            business.verified ? 'Verified' : 'Pending',
            style: TextStyle(
              color: business.verified ? accentColor : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Performance Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricTile(
                title: 'Growth Score',
                value: '${business.growthScore}%',
                icon: Icons.trending_up,
              ),
              const SizedBox(width: 12),
              _buildMetricTile(
                title: 'Monthly Change',
                value: '${business.monthlyGrowth >= 0 ? '+' : ''}${business.monthlyGrowth}%',
                icon: Icons.bar_chart,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  business.verified
                      ? 'Verified businesses earn higher trust and more customer traffic.'
                      : 'Complete verification to increase visibility and build trust with customers.',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor, size: 22),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _buildContactRow(Icons.email_outlined, 'Email', business.email),
          const SizedBox(height: 12),
          _buildContactRow(Icons.phone_outlined, 'Phone', business.phone),
          const SizedBox(height: 12),
          _buildContactRow(Icons.public_outlined, 'Website', business.website),
          const SizedBox(height: 12),
          _buildContactRow(Icons.location_on_outlined, 'Address', business.address),
          if (business.whatsapp != null) ...[
            const SizedBox(height: 12),
            _buildContactRow(Icons.chat_outlined, 'WhatsApp', business.whatsapp),
          ],
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: muteColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value ?? 'Not provided',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Business Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _buildDetailRow('Verification', business.verified ? 'Completed' : 'Pending'),
          const SizedBox(height: 12),
          _buildDetailRow('Growth score', '${business.growthScore}%'),
          const SizedBox(height: 12),
          _buildDetailRow('Monthly change', '${business.monthlyGrowth >= 0 ? '+' : ''}${business.monthlyGrowth}%'),
          const SizedBox(height: 12),
          _buildDetailRow('Business ID', business.id),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: muteColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSelector() {
    final sections = ['Overview', 'Products', 'Services', 'Offers'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: sections.map((section) {
          final isSelected = section == _selectedSection;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSection = section;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? accentColor : Colors.transparent,
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    section,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusChip(String text, {Color background = accentColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 46),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: background,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildManagementActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUICK ACTIONS',
            style: TextStyle(
              color: accentColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.shopping_bag_outlined,
                  label: '+ Product',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateProductScreen())),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_business_outlined,
                  label: '+ Service',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateServiceScreen())),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.local_offer_outlined,
                  label: '+ Offer',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateOfferScreen())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
