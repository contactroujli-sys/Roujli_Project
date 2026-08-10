import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/auth_providers.dart';
import 'verify_email_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'CUSTOMER';
  bool _agreeToTerms = false;
  bool _obscurePassword = true;

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'Customer',
      'role': 'CUSTOMER',
      'icon': Icons.shopping_cart_outlined,
    },
    {
      'title': 'Business',
      'role': 'BUSINESS',
      'icon': Icons.business_outlined,
    },
    {
      'title': 'Provider',
      'role': 'SERVICE_PROVIDER',
      'icon': Icons.build_outlined,
    },
    {
      'title': 'Creator',
      'role': 'CREATOR',
      'icon': Icons.auto_awesome,
    },
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }

    if (password.length < 8) {
      _showError('Password must be at least 8 characters.');
      return;
    }

    final success = await ref.read(authProvider.notifier).register(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          role: _selectedRole,
        );

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyEmailScreen(email: email),
        ),
      );
    } else {
      final error = ref.read(authProvider).errorMessage;
      if (error != null) _showError(error);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text('Back', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Title
              const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Join thousands of growing businesses',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 15),
              ),
              const SizedBox(height: 32),

              // Role Grid
              const Text(
                'I AM A',
                style: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _roles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.6,
                ),
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  final isSelected = _selectedRole == role['role'];

                  return GestureDetector(
                    onTap: () => setState(() => _selectedRole = role['role']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFE8B923) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            role['icon'],
                            color: isSelected ? const Color(0xFFE8B923) : const Color(0xFFB0B0B0),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            role['title'],
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFE8B923) : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // First Name & Last Name
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FIRST NAME',
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _firstNameController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: _inputDecoration(hintText: 'First name'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LAST NAME',
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _lastNameController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: _inputDecoration(hintText: 'Last name'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Email
              const Text(
                'EMAIL',
                style: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _inputDecoration(hintText: 'Email'),
              ),
              const SizedBox(height: 20),

              // Password
              const Text(
                'PASSWORD',
                style: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _inputDecoration(
                  hintText: '8+ characters',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF9E9E9E),
                      size: 22,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Terms
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
                      activeColor: const Color(0xFFE8B923),
                      checkColor: Colors.black,
                      side: const BorderSide(color: Color(0xFF6B6B6B), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13, height: 1.4),
                        children: [
                          TextSpan(text: 'By continuing you agree to our '),
                          TextSpan(
                            text: 'Terms',
                            style: TextStyle(color: Color(0xFFE8B923), fontWeight: FontWeight.w500),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(color: Color(0xFFE8B923), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_agreeToTerms && !authState.isLoading) ? _createAccount : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8B923),
                    disabledBackgroundColor: const Color(0xFF2A2A2A),
                    foregroundColor: Colors.black,
                    disabledForegroundColor: const Color(0xFF6B6B6B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 28),

              // OR Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade800, thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade800, thickness: 1)),
                ],
              ),
              const SizedBox(height: 28),

              // Social Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const FaIcon(FontAwesomeIcons.google, size: 18, color: Colors.white),
                        label: const Text('Google', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          side: BorderSide(color: Colors.grey.shade800, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const FaIcon(FontAwesomeIcons.apple, size: 20, color: Colors.white),
                        label: const Text('Apple', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          side: BorderSide(color: Colors.grey.shade800, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: Color(0xFFE8B923), fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 16),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8B923), width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
  }
}