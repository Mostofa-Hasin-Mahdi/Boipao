import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

enum VerificationState { initial, loading, success, error }

class VerificationController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  VerificationState _state = VerificationState.initial;
  VerificationState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Uint8List? _imageBytes;
  Uint8List? get imageBytes => _imageBytes;

  Map<String, dynamic>? _extractedData;
  Map<String, dynamic>? get extractedData => _extractedData;

  void _setState(VerificationState state) {
    _state = state;
    notifyListeners();
  }

  void reset() {
    _state = VerificationState.initial;
    _errorMessage = null;
    _imageBytes = null;
    _extractedData = null;
    notifyListeners();
  }

  Future<void> pickAndProcessImage() async {
    try {
      _setState(VerificationState.loading);
      _errorMessage = null;

      // Pick image with compression
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 1024,
      );

      if (image == null) {
        _setState(VerificationState.initial);
        return;
      }

      // Convert to bytes and base64
      final bytes = await image.readAsBytes();
      _imageBytes = bytes;
      notifyListeners();

      final base64Image = base64Encode(bytes);

      // Call Edge Function
      final response = await _supabase.functions.invoke(
        'mistral-ocr',
        body: {'base64Image': base64Image},
      );

      if (response.status != 200) {
        throw Exception('Failed to process image. Status: ${response.status}');
      }

      final responseData = response.data;
      if (responseData == null || responseData['success'] != true) {
         throw Exception(responseData?['error'] ?? 'Unknown error processing image');
      }

      _extractedData = responseData['data'];
      _setState(VerificationState.success);
      
    } catch (e) {
      _errorMessage = e.toString();
      _setState(VerificationState.error);
    }
  }

  Future<bool> submitVerification() async {
    if (_imageBytes == null || _extractedData == null) return false;

    try {
      _setState(VerificationState.loading);
      
      final userId = _supabase.auth.currentUser!.id;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload to id_cards bucket using uploadBinary for web support
      await _supabase.storage.from('id_cards').uploadBinary(
        fileName,
        _imageBytes!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Save to database
      await _supabase.from('student_verifications').insert({
        'user_id': userId,
        'school_name': _extractedData!['school_name'] ?? 'Unknown',
        'class_level': _extractedData!['class_level'] ?? 'Unknown',
        'roll_number': _extractedData!['roll_number'] ?? '',
        'id_card_image_url': fileName,
        'status': 'pending',
      });

      reset();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(VerificationState.error);
      return false;
    }
  }
}
