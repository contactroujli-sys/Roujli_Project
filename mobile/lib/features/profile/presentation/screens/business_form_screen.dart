import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile_data.dart';
import '../providers/profile_provider.dart';
import '../../../../core/services/image_upload_service.dart';

class BusinessFormScreen extends ConsumerStatefulWidget {
  final BusinessInfo? existingBusiness;

  const BusinessFormScreen({super.key, this.existingBusiness});

  @override
  ConsumerState<BusinessFormScreen> createState() => _BusinessFormScreenState();
}

class _BusinessFormScreenState extends ConsumerState<BusinessFormScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _addressCtrl;

  String? _logoUrl;
  String? _coverUrl;

  bool _isSubmitting = false;
  bool _isUploadingLogo = false;
  bool _isUploadingCover = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const Color gold = Color(0xFFD4AF37);
  static const Color dark = Color(0xFF080809);
  static const Color card = Color(0xFF131418);
  static const Color surface = Color(0xFF1E2029);

  bool get _isEdit => widget.existingBusiness != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingBusiness?.name ?? '');
    _descCtrl = TextEditingController(text: widget.existingBusiness?.description ?? '');
    _phoneCtrl = TextEditingController(text: widget.existingBusiness?.phone ?? '');
    _emailCtrl = TextEditingController(text: widget.existingBusiness?.email ?? '');
    _websiteCtrl = TextEditingController(text: widget.existingBusiness?.website ?? '');
    _whatsappCtrl = TextEditingController(text: widget.existingBusiness?.whatsapp ?? '');
    _addressCtrl = TextEditingController(text: widget.existingBusiness?.address ?? '');
    _logoUrl = widget.existingBusiness?.logo;
    _coverUrl = widget.existingBusiness?.cover;

    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _whatsappCtrl.dispose();
    _addressCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    setState(() => _isUploadingLogo = true);
    try {
      final url = await ImageUploadService.showPickerAndUpload(context);
      if (url != null && mounted) setState(() => _logoUrl = url);
    } finally {
      if (mounted) setState(() => _isUploadingLogo = false);
    }
  }

  Future<void> _pickCover() async {
    setState(() => _isUploadingCover = true);
    try {
      final url = await ImageUploadService.showPickerAndUpload(context);
      if (url != null && mounted) setState(() => _coverUrl = url);
    } finally {
      if (mounted) setState(() => _isUploadingCover = false);
    }
  }

  Future<void> _submitForm() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Business name is required.')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final data = {
        if (_isEdit) 'id': widget.existingBusiness!.id,
        'name': name,
        'description': _descCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'website': _websiteCtrl.text.trim(),
        'whatsapp': _whatsappCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'logo': _logoUrl,
        'cover': _coverUrl,
      };

      await ref.read(profileStateProvider.notifier).updateBusinessData(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Business updated!' : 'Business created!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                        Text(_isEdit ? 'Edit Business' : 'Create Business', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        const SizedBox(width: 36),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Cover and Logo Stack
                    SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Cover Image
                          GestureDetector(
                            onTap: _pickCover,
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(16),
                                image: _coverUrl != null && _coverUrl!.isNotEmpty
                                    ? DecorationImage(image: NetworkImage(_coverUrl!), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: _isUploadingCover
                                  ? const Center(child: CircularProgressIndicator(color: gold))
                                  : _coverUrl == null || _coverUrl!.isEmpty
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.panorama_outlined, color: Colors.white.withValues(alpha: 0.4), size: 32),
                                            const SizedBox(height: 4),
                                            Text('Add Cover', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                                          ],
                                        )
                                      : Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            margin: const EdgeInsets.all(8),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                                            child: const Icon(Icons.edit, color: Colors.white, size: 14),
                                          ),
                                        ),
                            ),
                          ),
                          
                          // Logo
                          Positioned(
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _pickLogo,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: card,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: dark, width: 4),
                                      image: _logoUrl != null && _logoUrl!.isNotEmpty
                                          ? DecorationImage(image: NetworkImage(_logoUrl!), fit: BoxFit.cover)
                                          : null,
                                    ),
                                    child: _isUploadingLogo
                                        ? const Center(child: CircularProgressIndicator(color: gold, strokeWidth: 2))
                                        : _logoUrl == null || _logoUrl!.isEmpty
                                            ? Icon(Icons.store_outlined, color: Colors.white.withValues(alpha: 0.4), size: 30)
                                            : null,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: gold,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: dark, width: 2),
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      _label('Business Name'),
                      const SizedBox(height: 8),
                      _field(controller: _nameCtrl, hint: 'e.g. Acme Corp', icon: Icons.storefront_outlined),
                      const SizedBox(height: 20),

                      _label('Description'),
                      const SizedBox(height: 8),
                      _field(controller: _descCtrl, hint: 'What does your business do?', icon: Icons.description_outlined, maxLines: 4),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Phone'),
                                const SizedBox(height: 8),
                                _field(controller: _phoneCtrl, hint: 'Phone', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('WhatsApp'),
                                const SizedBox(height: 8),
                                _field(controller: _whatsappCtrl, hint: 'WhatsApp', icon: Icons.chat_bubble_outline, keyboardType: TextInputType.phone),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _label('Email'),
                      const SizedBox(height: 8),
                      _field(controller: _emailCtrl, hint: 'contact@business.com', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 20),

                      _label('Website'),
                      const SizedBox(height: 8),
                      _field(controller: _websiteCtrl, hint: 'https://...', icon: Icons.language_outlined, keyboardType: TextInputType.url),
                      const SizedBox(height: 20),

                      _label('Address'),
                      const SizedBox(height: 8),
                      _field(controller: _addressCtrl, hint: 'Business address', icon: Icons.location_on_outlined, maxLines: 2),

                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            disabledBackgroundColor: gold.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                              : Text(_isEdit ? 'Save Business' : 'Create Business', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
