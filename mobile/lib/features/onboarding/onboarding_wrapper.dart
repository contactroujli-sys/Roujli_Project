import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/services/storage_service.dart';
import 'onboarding1.dart';
import 'onboarding2.dart';
import 'onboarding3.dart';
import '../auth/presentation/screens/login_screen.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToLogin() async {
    await StorageService.setOnboardingCompleted(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _completeOnboarding() async {
    await StorageService.setOnboardingCompleted(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          OnboardingScreen1(
            onNext: _nextPage,
            onSkip: _skipToLogin,
          ),
          OnboardingScreen2(
            onNext: _nextPage,
            onSkip: _skipToLogin,
          ),
          OnboardingScreen3(
            onGetStarted: _completeOnboarding,
            onSkip: _skipToLogin,
          ),
        ],
      ),
    );
  }
}

// Updated onboarding screen 1 with callbacks
class OnboardingScreen1 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingScreen1({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return DiscoverPremiumBusinessesScreen(
      onNext: onNext,
      onSkip: onSkip,
    );
  }
}

// Updated onboarding screen 2 with callbacks
class OnboardingScreen2 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingScreen2({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return GrowYourBusinessScreen(
      onNext: onNext,
      onSkip: onSkip,
    );
  }
}

// Updated onboarding screen 3 with callbacks
class OnboardingScreen3 extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSkip;

  const OnboardingScreen3({
    super.key,
    required this.onGetStarted,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return ConnectCollaborateScreen(
      onGetStarted: onGetStarted,
      onSkip: onSkip,
    );
  }
}
