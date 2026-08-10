import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/dio_service.dart';
import '../../core/services/image_upload_service.dart';
import '../profile/presentation/providers/profile_provider.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingService;

  const CreateServiceScreen({super.key, this.existingService});

  @override
  ConsumerState<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _durationCtrl;
  String _durationUnit = 'hours';
  String? _imageUrl;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const Color gold = Color(0xFFD4AF37);
  static const Color dark = Color(0xFF080809);
  static const Color card = Color(0xFF131418);
  static const Color surface = Color(0xFF1E2029);

  bool get _isEdit => widget.existingService != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingService?['name'] ?? '');
    _descCtrl = TextEditingController(text: widget.existingService?['description'] ?? '');
    _priceCtrl = TextEditingController(
      text: widget.existingService?['price'] != null
          ? widget.existingService!['price'].toString()
          : '',
    );
    final existingDur = widget.existingService?['duration'];
    if (existingDur != null && existingDur is int) {
      if (existingDur >= 1440 && existingDur % 1440 == 0) {
        _durationCtrl = TextEditingController(text: (existingDur ~/ 1440).toString());
        _durationUnit = 'days';
      } else if (existingDur >= 60 && existingDur % 60 == 0) {
        _durationCtrl = TextEditingController(text: (existingDur ~/ 60).toString());
        _durationUnit = 'hours';
      } else {
        _durationCtrl = TextEditingController(text: existingDur.toString());
        _durationUnit = 'mins';
      }
    } else {
      _durationCtrl = TextEditingController();
    }
    _imageUrl = widget.existingService?['image'];

    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  int? _durationInMinutes() {
    final val = int.tryParse(_durationCtrl.text.trim());
    if (val == null) return null;
    switch (_durationUnit) {
      case 'days': return val * 1440;
      case 'hours': return val * 60;
      default: return val;
    }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final dio = DioService.instance;
      final data = {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        'duration': _durationInMinutes(),
        'image': _imageUrl,
      };

      if (_isEdit) {
        await dio.put(ApiConstants.serviceById(widget.existingService!['id']), data: data);
      } else {
        await dio.post(ApiConstants.services, data: data);
      }

      ref.read(profileStateProvider.notifier).refreshData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Service updated!' : 'Service created!'),
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
                    colors: [Color(0xFF0B1520), Color(0xFF080809)],
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
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _isEdit ? 'Edit Service' : 'New Service',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const SizedBox(width: 36),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _pickImage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(20),
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
                                      Icon(Icons.add_photo_alternate_outlined,
                                        color: Colors.white.withValues(alpha: 0.4), size: 32),
                                      const SizedBox(height: 6),
                                      Text('Add Photo',
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                                    ],
                                  )
                                : Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      margin: const EdgeInsets.all(6),
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(8)),
                                      child: const Icon(Icons.edit, color: Colors.black, size: 14),
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _imageUrl != null ? 'Tap to change photo' : 'Tap to upload service photo',
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
                        _label('Service Name'),
                        const SizedBox(height: 8),
                        _field(controller: _nameCtrl, hint: 'e.g. Hair Styling', icon: Icons.spa_outlined,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
                        const SizedBox(height: 20),

                        _label('Price (DZD)'),
                        const SizedBox(height: 8),
                        _field(
                          controller: _priceCtrl,
                          hint: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          icon: Icons.payments_outlined,
                          prefixText: 'DZD  ',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Price is required';
                            if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _label('Duration (optional)'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                controller: _durationCtrl,
                                hint: 'e.g. 2',
                                keyboardType: TextInputType.number,
                                icon: Icons.timer_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: card,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF222222)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _durationUnit,
                                  dropdownColor: card,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  items: ['mins', 'hours', 'days'].map((u) =>
                                    DropdownMenuItem(value: u, child: Text(u))).toList(),
                                  onChanged: (v) => setState(() => _durationUnit = v!),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _label('Description (optional)'),
                        const SizedBox(height: 8),
                        _field(controller: _descCtrl, hint: 'Describe your service...', maxLines: 4,
                          icon: Icons.description_outlined),

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
                                    _isEdit ? 'Save Changes' : 'Create Service',
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
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      cursorColor: gold,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: gold, fontWeight: FontWeight.bold),
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
