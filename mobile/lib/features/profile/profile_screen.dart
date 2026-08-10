import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/presentation/providers/auth_providers.dart';
import '../auth/presentation/screens/login_screen.dart';
import '../explore/explore_screen.dart';
import '../explore/save_screen.dart';
import '../requests/requests_screen.dart';
import '../notifications/notifications_screen.dart';
import '../home/home_screen.dart';
import 'domain/entities/profile_data.dart';
import 'edit_profile_screen.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/screens/business_dashboard_screen.dart';
import 'presentation/screens/business_form_screen.dart';
import 'settings_screen.dart';
import '../subscriptions/subscription_dialog.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _currentIndex = 4; // Profile is selected

  @override
  void initState() {
    super.initState();
    // Load profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileStateProvider.notifier).loadProfileData();
    });
  }

  // Gold color used for icons & accents
  static const Color gold = Color(0xFFD4AF37);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color sectionTitle = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (profileState.profileData != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  profile: profileState.profileData!.user,
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 22),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                        icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Scrollable content ───────────────────────────
            Expanded(
              child: profileState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                      ),
                    )
                  : profileState.errorMessage != null
                      ? _buildErrorView(profileState.errorMessage!)
                      : profileState.profileData == null
                          ? const Center(
                              child: Text(
                                'No data available',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Profile Header Card ───────────────────
                                  _buildProfileHeader(profileState.profileData!.user),

                                  const SizedBox(height: 16),

                                  // ── Stats Row ─────────────────────────────
                                  _buildStatsRow(profileState.profileData!.user),

                                  const SizedBox(height: 24),

                                  // ── MY BUSINESS Section ───────────────────
                                  _sectionTitle('MY BUSINESS'),
                                  const SizedBox(height: 8),
                                  ..._buildBusinessMenuItems(
                                    profileState.profileData!.businessCounts,
                                    profileState.profileData!.user,
                                  ),

                                  const SizedBox(height: 20),

                                  // ── ACCOUNT Section ───────────────────────
                                  _sectionTitle('ACCOUNT'),
                                  const SizedBox(height: 8),
                                  ..._buildAccountMenuItems(
                                    profileState.profileData!.businessCounts,
                                    profileState.profileData!.user,
                                  ),

                                  const SizedBox(height: 20),

                                  // ── MEMBERSHIP Section ────────────────────
                                  _sectionTitle('MEMBERSHIP'),
                                  const SizedBox(height: 8),
                                  _buildMembershipItem(profileState.profileData!.membership),
                                  _buildMenuItem(
                                    icon: Icons.settings_outlined,
                                    title: 'Settings',
                                    showCount: false,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const SettingsScreen(),
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 28),

                                  // ── Sign Out Button ───────────────────────
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final navigator = Navigator.of(context);
                                        await ref.read(authProvider.notifier).logout();
                                        if (!mounted) return;
                                        navigator.pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                          (_) => false,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2A1A1A),
                                        foregroundColor: Colors.redAccent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: const Text(
                                        'Sign Out',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 100), // space for bottom nav
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),

      // ─── Bottom Navigation Bar ────────────────────────────
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
              ref.read(profileStateProvider.notifier).refreshData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Profile Header (Avatar + Name + Verified + Growth Score)
  // ─────────────────────────────────────────────────────────
  Widget _buildProfileHeader(UserProfile user) {
    final business = user.business;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          // Avatar + Name + Badge
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person,
                  color: gold,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (user.isVerified)
                          const Icon(
                            Icons.verified,
                            color: gold,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: gold.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium, color: gold, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Phone', user.phoneNumber ?? 'Add your phone'),
                const SizedBox(height: 8),
                _buildInfoRow('Bio', user.bio ?? 'Tell us about yourself'),
                const SizedBox(height: 8),
                _buildInfoRow('Country', user.country ?? 'Add your country'),
                const SizedBox(height: 8),
                _buildInfoRow('City', user.city ?? 'Add your city'),
              ],
            ),
          ),

          if (business != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF212121),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business, color: gold, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          business.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: business.verified ? gold.withValues(alpha: 0.18) : Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          business.verified ? 'Business Verified' : 'Pending Verification',
                          style: TextStyle(
                            color: business.verified ? gold : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    business.description ?? 'No business description added yet',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Email', business.email ?? 'Not provided'),
                  const SizedBox(height: 6),
                  _buildInfoRow('Phone', business.phone ?? 'Not provided'),
                  const SizedBox(height: 6),
                  _buildInfoRow('Website', business.website ?? 'Not provided'),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Business Growth Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: ((business?.growthScore ?? user.growthScore) / 100).clamp(0.0, 1.0),
                            strokeWidth: 5,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(gold),
                          ),
                          Text(
                            '${business?.growthScore ?? user.growthScore}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            business != null ? 'Project growth rate' : 'Account growth rate',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            business != null
                                ? 'Display your business s monthly growth rate.'
                                : 'View your profile growth rate in the app.',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (business != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Monthly growth rate',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${business.monthlyGrowth >= 0 ? '+' : ''}${business.monthlyGrowth}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF8A8A8A),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // Stats Row (Businesses / Products / Services)
  // ─────────────────────────────────────────────────────────
  Widget _buildStatsRow(UserProfile user) {
    final business = user.business;
    final growthValue = business?.growthScore ?? user.growthScore;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.business_outlined,
            value: '$growthValue%',
            label: business != null ? 'Business Score' : 'Score',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.trending_up,
            value: business != null ? '+$growthValue%' : '+0%',
            label: business != null ? 'Business Growth' : 'Growth',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.verified,
            value: business != null ? 'Business' : 'Free',
            label: 'Status',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: gold, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Section Title
  // ─────────────────────────────────────────────────────────
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: sectionTitle,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Build Business Menu Items
  // ─────────────────────────────────────────────────────────
  List<Widget> _buildBusinessMenuItems(List<BusinessCount> businessCounts, UserProfile user) {
    final businessItems = ['My Businesses', 'My Products', 'My Services', 'My Offers'];
    return businessItems.map((type) {
      final count = businessCounts.firstWhere(
        (bc) => bc.type == type,
        orElse: () => BusinessCount(type: type, count: 0),
      );
      return _buildMenuItem(
        icon: _getIconForType(type),
        title: type,
        count: count.count,
        onTap: () => _handleBusinessMenuTap(type, user),
      );
    }).toList();
  }

  // ─────────────────────────────────────────────────────────
  // Build Account Menu Items
  // ─────────────────────────────────────────────────────────
  List<Widget> _buildAccountMenuItems(List<BusinessCount> businessCounts, UserProfile user) {
    final accountItems = ['Saved', 'My Requests'];
    return [
      ...accountItems.map((type) {
        final count = businessCounts.firstWhere(
          (bc) => bc.type == type,
          orElse: () => BusinessCount(type: type, count: 0),
        );
        return _buildMenuItem(
          icon: _getIconForType(type),
          title: type,
          count: count.count,
          onTap: () {
            if (type == 'Saved') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SaveScreen()),
              );
            } else if (type == 'My Requests') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RequestsScreen()),
              );
            }
          },
        );
      }),
      _buildMenuItem(
        icon: Icons.person_outline,
        title: 'Edit Profile',
        showCount: false,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(
                profile: user,
              ),
            ),
          );
        },
      ),
    ];
  }

  // ─────────────────────────────────────────────────────────
  // Get Icon for Type
  // ─────────────────────────────────────────────────────────
  IconData _getIconForType(String type) {
    switch (type) {
      case 'My Businesses':
        return Icons.business_outlined;
      case 'My Products':
        return Icons.inventory_2_outlined;
      case 'My Services':
        return Icons.build_outlined;
      case 'My Offers':
        return Icons.local_offer_outlined;
      case 'Saved':
        return Icons.bookmark_outline;
      case 'My Requests':
        return Icons.description_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  void _handleBusinessMenuTap(String title, UserProfile user) {
    final hasBusiness = user.business != null;

    if (title == 'My Businesses') {
      if (hasBusiness) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessDashboardScreen(business: user.business!),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BusinessFormScreen(existingBusiness: null),
          ),
        );
      }
      return;
    }

    if (!hasBusiness) {
      _showNoBusinessDialog();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessDashboardScreen(
          business: user.business!,
          initialSection: title,
        ),
      ),
    );
  }

  void _showNoBusinessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121212),
          title: const Text('Business Required', style: TextStyle(color: Colors.white)),
          content: const Text(
            'You can’t create products, services, or offers without a business. Create a business first.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BusinessFormScreen(existingBusiness: null),
                  ),
                );
              },
              child: const Text('Create Business'),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // Menu Item
  // ─────────────────────────────────────────────────────────
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    int count = 0,
    bool showCount = true,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(icon, color: gold, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCount)
              Text(
                '$count',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
  // ─────────────────────────────────────────────────────────
  // Membership Item (Subscription - Premium)
  // ─────────────────────────────────────────────────────────
  Widget _buildMembershipItem(Membership membership) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: const Icon(Icons.workspace_premium, color: gold, size: 24),
        title: const Text(
          'Subscription',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              membership.type,
              style: const TextStyle(
                color: gold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
        onTap: () {
          showSubscriptionDialog(context, ref);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Bottom Navigation Bar
  // ─────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: gold,
        unselectedItemColor: Colors.white54,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExploreScreen()),
            );
          } else if (index == 2) {
            context.push('/messages');
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}