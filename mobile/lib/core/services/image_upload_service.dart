import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import '../services/dio_service.dart';

class ImageUploadService {
  static final _picker = ImagePicker();

  /// Pick an image from gallery or camera, then upload to backend.
  /// Returns the uploaded image URL or null if failed/cancelled.
  static Future<String?> pickAndUpload({
    ImageSource source = ImageSource.gallery,
    Function(String)? onError,
  }) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return null;

      final file = File(picked.path);
      final fileName = picked.name;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final dio = DioService.instance;
      final response = await dio.post(
        ApiConstants.upload,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return response.data['data']['url'] as String?;
    } catch (e) {
      onError?.call(e.toString());
      return null;
    }
  }

  /// Show source picker dialog, then upload.
  static Future<String?> showPickerAndUpload(
    BuildContext context, {
    Function(String)? onError,
  }) async {
    ImageSource? source;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Choose Image', style: TextStyle(color: Colors.white)),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _sourceButton(
              ctx,
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              onTap: () {
                source = ImageSource.gallery;
                Navigator.pop(ctx);
              },
            ),
            _sourceButton(
              ctx,
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              onTap: () {
                source = ImageSource.camera;
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;
    return pickAndUpload(source: source!, onError: onError);
  }

  static Widget _sourceButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
