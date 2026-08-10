import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/dio_service.dart';
import '../profile/presentation/providers/profile_provider.dart';

class AddRequestScreen extends ConsumerStatefulWidget {
  final String businessId;
  final String businessName;
  final String requestType; // 'PRODUCT', 'SERVICE', 'OFFER'
  final String itemId;
  final String itemName;
  final double? price;
  final int? duration;
  final double? discount;

  const AddRequestScreen({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.requestType,
    required this.itemId,
    required this.itemName,
    this.price,
    this.duration,
    this.discount,
  });

  @override
  ConsumerState<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends ConsumerState<AddRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _noteController;
  int _quantity = 1;
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;
  bool _isLoading = false;

  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color goldColor = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileStateProvider).profileData?.user;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _phoneController = TextEditingController(text: profile?.phoneNumber ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: goldColor, surface: darkCard),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _preferredTime ?? const TimeOfDay(hour: 10, minute: 0),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: goldColor, surface: darkCard),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _preferredDate = pickedDate;
          _preferredTime = pickedTime;
        });
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dio = DioService.instance;
      DateTime? combinedDateTime;
      if (_preferredDate != null && _preferredTime != null) {
        combinedDateTime = DateTime(
          _preferredDate!.year,
          _preferredDate!.month,
          _preferredDate!.day,
          _preferredTime!.hour,
          _preferredTime!.minute,
        );
      }

      final payload = {
        'businessId': widget.businessId,
        'type': widget.requestType,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'note': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        'quantity': _quantity,
        'preferredDate': combinedDateTime?.toIso8601String(),
      };

      if (widget.requestType == 'PRODUCT') {
        payload['productId'] = widget.itemId;
      } else if (widget.requestType == 'SERVICE') {
        payload['serviceId'] = widget.itemId;
      } else if (widget.requestType == 'OFFER') {
        payload['offerId'] = widget.itemId;
      }

      await dio.post(ApiConstants.requests, data: payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Submit Request',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Header Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: goldColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.requestType == 'PRODUCT'
                              ? Icons.shopping_bag_outlined
                              : widget.requestType == 'SERVICE'
                                  ? Icons.miscellaneous_services_outlined
                                  : Icons.local_offer_outlined,
                          color: goldColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.itemName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.businessName,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (widget.price != null)
                        Text(
                          '\$${widget.price!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: goldColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildFieldLabel('Full Name *'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Your full name',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Phone Number'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _phoneController,
                  hint: '+1 (555) 000-0000',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Email Address'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emailController,
                  hint: 'your.email@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Quantity stepper for PRODUCT requests
                if (widget.requestType == 'PRODUCT') ...[
                  _buildFieldLabel('Quantity'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Units requested', style: TextStyle(color: Colors.white70)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: goldColor),
                              onPressed: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: goldColor),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Date/Time picker for SERVICE requests
                if (widget.requestType == 'SERVICE') ...[
                  _buildFieldLabel('Preferred Date & Time'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDateTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: darkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: goldColor, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            _preferredDate != null && _preferredTime != null
                                ? '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year} at ${_preferredTime!.format(context)}'
                                : 'Select date and time',
                            style: TextStyle(
                              color: _preferredDate != null ? Colors.white : Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                _buildFieldLabel('Additional Notes / Content'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _noteController,
                  hint: 'Specify any custom requirements or preferences...',
                  maxLines: 4,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Submit Request',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldColor),
        ),
      ),
    );
  }
}
