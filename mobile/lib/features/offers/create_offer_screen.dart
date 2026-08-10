import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/dio_service.dart';
import '../../core/services/image_upload_service.dart';
import '../profile/presentation/providers/profile_provider.dart';

class CreateOfferScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingOffer;

  const CreateOfferScreen({super.key, this.existingOffer});

  @override
  ConsumerState<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends ConsumerState<CreateOfferScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _discountCtrl;
  DateTime? _expiresAt;
  String? _imageUrl;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const Color gold = Color(0xFFD4AF37);
  static const Color dark = Color(0xFF080809);
  static const Color card = Color(0xFF131418);
  static const Color surface = Color(0xFF1E2029);

  bool get _isEdit => widget.existingOffer != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existingOffer?['title'] ?? '');
    _descCtrl = TextEditingController(text: widget.existingOffer?['description'] ?? '');
    _discountCtrl = TextEditingController(
      text: widget.existingOffer?['discount'] != null
          ? widget.existingOffer!['discount'].toString()
          : '',
    );
    _imageUrl = widget.existingOffer?['image'];
    if (widget.existingOffer?['expiresAt'] != null) {
      _expiresAt = DateTime.tryParse(widget.existingOffer!['expiresAt']);
    }

    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _discountCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
      if (url != null && mounted) setState(() => _imageUrl = url);
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: gold,
            onPrimary: Colors.black,
            surface: Color(0xFF1A1A1A),
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF111111)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final dio = DioService.instance;
      final discount = double.tryParse(_discountCtrl.text.trim());
      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'discount': discount,
        'image': _imageUrl,
        'expiresAt': _expiresAt?.toIso8601String(),
      };

      if (_isEdit) {
        await dio.put(ApiConstants.offerById(widget.existingOffer!['id']), data: data);
      } else {
        await dio.post(ApiConstants.offers, data: data);
      }

      ref.read(profileStateProvider.notifier).refreshData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Offer updated!' : 'Offer created!'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] ?? 'An error occurred.';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString()), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final discountValue = double.tryParse(_discountCtrl.text.trim()) ?? 0;
    final daysLeft = _expiresAt?.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: dark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // ── Hero Header ──
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1208), Color(0xFF080809)],
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
                        Text(
                          _isEdit ? 'Edit Offer' : 'New Offer',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        // Discount preview badge
                        if (discountValue > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${discountValue.toStringAsFixed(0)}% OFF',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          )
                        else
                          const SizedBox(width: 36),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _pickImage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 140,
                        height: 100,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _imageUrl != null ? gold : Colors.white.withValues(alpha: 0.1),
                            width: _imageUrl != null ? 2 : 1,
                          ),
                          image: _imageUrl != null
                              ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _isUploadingImage
                            ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: gold))
                            : _imageUrl == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.local_offer_outlined, color: Colors.white.withValues(alpha: 0.4), size: 28),
                                      const SizedBox(height: 6),
                                      Text('Add Banner', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                                    ],
                                  )
                                : Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      margin: const EdgeInsets.all(6),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(7)),
                                      child: const Icon(Icons.edit, color: Colors.black, size: 12),
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _imageUrl != null ? 'Tap to change banner' : 'Tap to upload offer banner',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                    ),
                  ],
                ),
              ),

              // ── Form ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Offer Title'),
                        const SizedBox(height: 8),
                        _field(controller: _titleCtrl, hint: 'e.g. 50% off Summer Sale', icon: Icons.local_offer_outlined,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null),
                        const SizedBox(height: 20),

                        _label('Discount %'),
                        const SizedBox(height: 8),
                        _field(
                          controller: _discountCtrl,
                          hint: '0 - 100',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          icon: Icons.percent_outlined,
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final d = double.tryParse(v);
                              if (d == null || d < 0 || d > 100) return 'Enter a value between 0-100';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Expiry date picker
                        _label('Expiry Date (optional)'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            decoration: BoxDecoration(
                              color: card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF222222)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_outlined, color: Colors.white.withValues(alpha: 0.4), size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  _expiresAt != null
                                      ? DateFormat('MMM d, yyyy').format(_expiresAt!)
                                      : 'Choose expiry date',
                                  style: TextStyle(
                                    color: _expiresAt != null ? Colors.white : Colors.white.withValues(alpha: 0.3),
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                if (_expiresAt != null && daysLeft != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: daysLeft <= 3 ? Colors.redAccent.withValues(alpha: 0.2) : gold.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$daysLeft days',
                                      style: TextStyle(
                                        color: daysLeft <= 3 ? Colors.redAccent : gold,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _label('Description (optional)'),
                        const SizedBox(height: 8),
                        _field(controller: _descCtrl, hint: 'Describe your offer...', maxLines: 4, icon: Icons.description_outlined),

                        const SizedBox(height: 36),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gold,
                              disabledBackgroundColor: gold.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 22, height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                                : Text(
                                    _isEdit ? 'Save Changes' : 'Create Offer',
                                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) =>
    Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? icon,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
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
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    );
  }
}
