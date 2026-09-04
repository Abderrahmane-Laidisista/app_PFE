import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../data/models/patient_metadata.dart';
import '../../data/models/prediction_response.dart';
import '../../core/services/storage_service.dart';

class ApiService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();

  String get baseUrl => _storageService.apiUrl;

  /// Map Flutter's internal sex representation to the Backend expected ENUM
  String _mapSex(String formSex) {
    if (formSex == 'M') return 'male';
    if (formSex == 'F') return 'female';
    return 'unknown';
  }

  /// Map Flutter's internal locations to the Backend expected BodyRegion ENUM
  String _mapRegion(String formRegion) {
    switch (formRegion) {
      case 'location_head':
        return 'face'; // Can also be 'scalp'
      case 'location_neck':
        return 'neck';
      case 'location_chest':
        return 'chest';
      case 'location_back':
        return 'back';
      case 'location_arm_left':
      case 'location_arm_right':
        return 'upper extremity';
      case 'location_hand_left':
      case 'location_hand_right':
        return 'hand';
      case 'location_abdomen':
        return 'abdomen';
      case 'location_leg_left':
      case 'location_leg_right':
        return 'lower extremity';
      case 'location_foot_left':
      case 'location_foot_right':
        return 'foot';
      default:
        return 'unknown';
    }
  }

  Future<PredictionResponse> predict(String imagePath, PatientMetadata metadata) async {
    try {
      final uri = Uri.parse('$baseUrl/predict');
      final request = http.MultipartRequest('POST', uri);

      // Web-Compatible Image Loading using XFile
      final xFile = XFile(imagePath);
      final bytes = await xFile.readAsBytes();
      
      // Add Image File
      request.files.add(http.MultipartFile.fromBytes(
        'file', 
        bytes, 
        filename: xFile.name.isEmpty ? 'image.jpg' : xFile.name,
      ));

      // Add Form Fields
      request.fields['age'] = metadata.age.toString();
      request.fields['sex'] = _mapSex(metadata.sex);
      request.fields['localization'] = _mapRegion(metadata.region);
      request.fields['grew'] = metadata.grew.toString();
      request.fields['bleed'] = metadata.bleed.toString();
      request.fields['diameter_1'] = metadata.diameter.toString();
      request.fields['skin_cancer_history'] = metadata.skinCancerHistory.toString();
      // Send elevation if provided (new V6.0 field)
      if (metadata.elevation != null) {
        request.fields['elevation'] = metadata.elevation.toString();
      }

      debugPrint('🚀 Sending POST request to: $uri');
      debugPrint('📦 Payload: age=${metadata.age}, sex=${_mapSex(metadata.sex)}, localization=${_mapRegion(metadata.region)}');

      final streamedResponse = await request.send().timeout(const Duration(seconds: 90)); // 90s for CPU inference
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return PredictionResponse.fromJson(responseData);
      } else {
        debugPrint('❌ Error response: ${response.body}');
        throw Exception('Failed to analyze image: [${response.statusCode}] Make sure FastAPI receives the request.');
      }
    } catch (e) {
      debugPrint('❌ API Request Error: $e');
      throw Exception('Network error: Ensure backend is running and IP is correct. Details: $e');
    }
  }
}
