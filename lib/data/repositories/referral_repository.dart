import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../app/config/api/api_constants.dart';
import '../models/public_doctor.dart';
import '../models/referral_model.dart';
import '../providers/api_provider.dart';

/// Repository for Telemedicine referrals (GP -> Specialist) and Public Doctor directory.
class ReferralRepository extends GetxService {
  final ApiProvider _api = Get.find<ApiProvider>();

  /// Create a telemedicine referral for a suspicious analysis
  Future<ReferralModel> createReferral(ReferralCreateRequest request) async {
    final response = await _api.post(
      ApiConstants.referrals,
      body: request.toJson(),
      requiresAuth: true,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ReferralModel.fromJson(Map<String, dynamic>.from(data));
    } else {
      String msg = 'Failed to create referral: [${response.statusCode}]';
      try {
        final err = jsonDecode(response.body);
        if (err['detail'] != null) msg = err['detail'].toString();
      } catch (_) {}
      throw Exception(msg);
    }
  }

  /// List referrals sent by current doctor
  Future<List<ReferralModel>> getSentReferrals({String? status}) async {
    try {
      final query = <String, dynamic>{
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response = await _api.get(
        ApiConstants.sentReferrals,
        queryParameters: query,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final list = data['items'] as List? ?? [];
        return list
            .map((e) => ReferralModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error loading sent referrals: $e');
      return [];
    }
  }

  /// List incoming referrals received by current specialist
  Future<List<ReferralModel>> getReceivedReferrals({String? status}) async {
    try {
      final query = <String, dynamic>{
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response = await _api.get(
        ApiConstants.receivedReferrals,
        queryParameters: query,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final list = data['items'] as List? ?? [];
        return list
            .map((e) => ReferralModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error loading received referrals: $e');
      return [];
    }
  }

  /// Specialist responds to referral
  Future<ReferralModel> respondReferral(String referralId, ReferralRespondRequest request) async {
    final response = await _api.put(
      ApiConstants.referralRespond(referralId),
      body: request.toJson(),
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ReferralModel.fromJson(Map<String, dynamic>.from(data));
    } else {
      String msg = 'Failed to respond to referral: [${response.statusCode}]';
      try {
        final err = jsonDecode(response.body);
        if (err['detail'] != null) msg = err['detail'].toString();
      } catch (_) {}
      throw Exception(msg);
    }
  }

  /// Public directory of verified active doctors (unauthenticated)
  Future<List<PublicDoctor>> getPublicDoctors({
    String? wilaya,
    String? doctorType,
  }) async {
    try {
      final query = <String, dynamic>{
        if (wilaya != null && wilaya.isNotEmpty) 'wilaya': wilaya,
        if (doctorType != null && doctorType.isNotEmpty) 'doctor_type': doctorType,
      };

      final response = await _api.get(
        ApiConstants.publicDoctors,
        queryParameters: query,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List? ?? [];
        return list
            .map((e) => PublicDoctor.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error loading public doctors: $e');
      return [];
    }
  }
}
