import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String? currentPassword;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    this.currentPassword,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _codeController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _codeController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final code = _codeController.text.trim();
    final currentPassword = _currentPasswordController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (widget.currentPassword != null && widget.currentPassword!.isNotEmpty) {
      if (currentPassword.isEmpty) {
        _showError('Please enter your current password to confirm your identity.');
        return;
      }

      if (currentPassword != widget.currentPassword) {
        _showError('The current password you entered does not match your saved password.');
        return;
      }
    }

    if (code.length < 6) {
      _showError('Please enter the 6-digit code sent to your email.');
      return;
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showError('Please fill in both password fields.');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }

    if (password.length < 8) {
      _showError('Password must be at least 8 characters.');
      return;
    }

    final success = await ref.read(authProvider.notifier).resetPassword(
          email: widget.email,
          code: code,
          newPassword: password,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! Please sign in.'),
          backgroundColor: Color(0xFFE8B923),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
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
              const SizedBox(height: 40),

              // Title
              const Text(
                'Reset Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                widget.currentPassword != null && widget.currentPassword!.isNotEmpty
                    ? 'Confirm your old password, then enter the 6-digit code sent to your email and choose a new password.'
                    : 'Enter the 6-digit code sent to your email along with your new password.',
                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 40),

              if (widget.currentPassword != null && widget.currentPassword!.isNotEmpty) ...[
                const Text(
                  'CURRENT PASSWORD',
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _inputDecoration(hintText: 'Enter your current password'),
                ),
                const SizedBox(height: 24),
              ],

              // Code Label & Field
              const Text(
                'RESET CODE',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 4, fontWeight: FontWeight.bold),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration(hintText: '123456').copyWith(counterText: ''),
              ),
              const SizedBox(height: 24),

              // New Password Label & Field
              const Text(
                'NEW PASSWORD',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
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
              const SizedBox(height: 24),

              // Confirm Password Label & Field
              const Text(
                'CONFIRM PASSWORD',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _inputDecoration(
                  hintText: 'Re-enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF9E9E9E),
                      size: 22,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Reset Password Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _resetPassword,
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
                          'Reset Password',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Back to Login
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  ),
                  child: const Text(
                    'Back to Sign In',
                    style: TextStyle(color: Color(0xFFE8B923), fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 40),
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