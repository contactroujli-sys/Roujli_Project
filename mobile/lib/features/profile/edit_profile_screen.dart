import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/entities/profile_data.dart';
import 'presentation/providers/profile_provider.dart';
import '../../core/services/image_upload_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _cityCtrl;

  String? _avatarUrl;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const Color gold = Color(0xFFD4AF37);
  static const Color dark = Color(0xFF080809);
  static const Color card = Color(0xFF131418);
  static const Color surface = Color(0xFF1E2029);

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.profile.firstName);
    _lastNameCtrl = TextEditingController(text: widget.profile.lastName);
    _phoneCtrl = TextEditingController(text: widget.profile.phoneNumber ?? '');
    _bioCtrl = TextEditingController(text: widget.profile.bio ?? '');
    _countryCtrl = TextEditingController(text: widget.profile.country ?? '');
    _cityCtrl = TextEditingController(text: widget.profile.city ?? '');
    _avatarUrl = widget.profile.avatar;

    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    setState(() => _isUploadingImage = true);
    try {
      final url = await ImageUploadService.showPickerAndUpload(
        context,
        onError: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.redAccent),
          );
        },
      );
      if (url != null && mounted) setState(() => _avatarUrl = url);
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(profileStateProvider.notifier).updateProfileData({
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'avatar': _avatarUrl,
        'bio': _bioCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // ── Hero Header ──
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF131A22), Color(0xFF080809)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                          ),
                        ),
                        const Spacer(),
                        const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        const SizedBox(width: 36),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: _avatarUrl != null ? gold : Colors.white.withValues(alpha: 0.1), width: 2),
                              image: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(_avatarUrl!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: _isUploadingImage
                                ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: gold))
                                : _avatarUrl == null || _avatarUrl!.isEmpty
                                    ? Icon(Icons.person_outline, color: Colors.white.withValues(alpha: 0.4), size: 40)
                                    : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: gold,
                                shape: BoxShape.circle,
                                border: Border.all(color: dark, width: 3),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.black, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Tap to change profile picture', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
                  ],
                ),
              ),

              // ── Form ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('First Name'),
                                const SizedBox(height: 8),
                                _field(controller: _firstNameCtrl, hint: 'First Name', icon: Icons.person_outline),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Last Name'),
                                const SizedBox(height: 8),
                                _field(controller: _lastNameCtrl, hint: 'Last Name'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _label('Phone Number'),
                      const SizedBox(height: 8),
                      _field(controller: _phoneCtrl, hint: 'Enter your phone number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('City'),
                                const SizedBox(height: 8),
                                _field(controller: _cityCtrl, hint: 'City', icon: Icons.location_city_outlined),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Country'),
                                const SizedBox(height: 8),
                                _field(controller: _countryCtrl, hint: 'Country', icon: Icons.public_outlined),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _label('Bio'),
                      const SizedBox(height: 8),
                      _field(controller: _bioCtrl, hint: 'Tell us a bit about yourself...', icon: Icons.edit_note_outlined, maxLines: 4),

                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            disabledBackgroundColor: gold.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                              : const Text('Save Profile', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      cursorColor: gold,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 20) : null,
        filled: true, fillColor: card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF222222))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF222222))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: gold, width: 1.5)),
      ),
    );
  }
}
