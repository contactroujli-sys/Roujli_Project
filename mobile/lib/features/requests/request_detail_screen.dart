import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/dio_service.dart';

class RequestDetailScreen extends ConsumerStatefulWidget {
  final String requestId;
  final bool isOwnerView;

  const RequestDetailScreen({
    super.key,
    required this.requestId,
    required this.isOwnerView,
  });

  @override
  ConsumerState<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  Map<String, dynamic>? _request;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  final TextEditingController _ownerNoteController = TextEditingController();

  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color goldColor = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _loadRequestDetail();
  }

  @override
  void dispose() {
    _ownerNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadRequestDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = DioService.instance;
      final response = await dio.get(ApiConstants.requestById(widget.requestId));
      if (mounted) {
        setState(() {
          _request = response.data['data'];
          _ownerNoteController.text = _request?['ownerNote'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isSubmitting = true);
    try {
      final dio = DioService.instance;
      await dio.patch(
        ApiConstants.updateRequestStatus(widget.requestId),
        data: {
          'status': status,
          'ownerNote': _ownerNoteController.text.trim().isEmpty ? null : _ownerNoteController.text.trim(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request $status successfully'),
            backgroundColor: status == 'ACCEPTED' ? Colors.green : Colors.redAccent,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: darkBg,
        body: const Center(child: CircularProgressIndicator(color: goldColor)),
      );
    }

    if (_error != null || _request == null) {
      return Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(_error ?? 'Request not found', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRequestDetail,
                style: ElevatedButton.styleFrom(backgroundColor: goldColor),
                child: const Text('Retry', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    final req = _request!;
    final status = req['status'] ?? 'PENDING';
    final itemName = req['product']?['name'] ?? req['service']?['name'] ?? req['offer']?['title'] ?? 'Requested Item';
    final businessName = req['business']?['name'] ?? 'Business';

    Color statusColor = goldColor;
    if (status == 'ACCEPTED') statusColor = Colors.green;
    if (status == 'REJECTED') statusColor = Colors.redAccent;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Request Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(itemName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Business: $businessName', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildDetailSection('CUSTOMER INFORMATION', [
                _buildInfoRow('Name', req['name'] ?? 'N/A'),
                if (req['phone'] != null) _buildInfoRow('Phone', req['phone']),
                if (req['email'] != null) _buildInfoRow('Email', req['email']),
              ]),
              const SizedBox(height: 16),

              _buildDetailSection('REQUEST DETAILS', [
                _buildInfoRow('Type', req['type'] ?? 'N/A'),
                if (req['quantity'] != null) _buildInfoRow('Quantity', '${req['quantity']}'),
                if (req['preferredDate'] != null)
                  _buildInfoRow(
                    'Preferred Date',
                    DateTime.tryParse(req['preferredDate'])?.toLocal().toString().substring(0, 16) ?? req['preferredDate'],
                  ),
                if (req['note'] != null && req['note'].toString().isNotEmpty)
                  _buildInfoRow('Note', req['note']),
              ]),
              const SizedBox(height: 16),

              if (req['ownerNote'] != null && req['ownerNote'].toString().isNotEmpty) ...[
                _buildDetailSection('BUSINESS RESPONSE NOTE', [
                  _buildInfoRow('Response', req['ownerNote']),
                ]),
                const SizedBox(height: 20),
              ],

              // Owner Action Controls
              if (widget.isOwnerView && status == 'PENDING') ...[
                const Text(
                  'Owner Response Note (Optional)',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ownerNoteController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a response note for the customer...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: darkCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : () => _updateStatus('REJECTED'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                            foregroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Reject Request', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : () => _updateStatus('ACCEPTED'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goldColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Accept Request', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: goldColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
