import 'dart:convert';
import 'package:flutter/material.dart';
import '../../app/config/api/api_config.dart';

/// Class probability item.
class DiagnosticProbability {
  final String label;
  final String fullName;
  final double probability;

  DiagnosticProbability({
    required this.label,
    required this.fullName,
    required this.probability,
  });

  factory DiagnosticProbability.fromJson(Map<String, dynamic> json) {
    return DiagnosticProbability(
      label: json['label']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['label']?.toString() ?? '',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'full_name': fullName,
      'probability': probability,
    };
  }
}

/// Comprehensive Multimodal Clinical Prediction Response.
class PredictionResponse {
  final String predictedClass;
  final String predictedLabelFull;
  final double confidence;
  final String riskLevel; // LOW, MODERATE, HIGH, CRITICAL, INCONCLUSIVE
  final String? riskColor;
  final String riskExplanation;
  final Map<String, double> allProbabilities;
  final List<DiagnosticProbability> probabilityList;
  final List<String> recommendations;
  final bool suggestReferral;
  final bool riskEscalated;
  final String? analysisId;
  final String? imageUrl;
  final String? gradcamUrl;
  final String? gradcamHeatmapBase64;
  final String? patientId;
  final String? lesionTag;
  final double inferenceTimeMs;
  final DateTime timestamp;

  PredictionResponse({
    required this.predictedClass,
    required this.predictedLabelFull,
    required this.confidence,
    required this.riskLevel,
    this.riskColor,
    required this.riskExplanation,
    required this.allProbabilities,
    required this.probabilityList,
    required this.recommendations,
    this.suggestReferral = false,
    this.riskEscalated = false,
    this.analysisId,
    this.imageUrl,
    this.gradcamUrl,
    this.gradcamHeatmapBase64,
    this.patientId,
    this.lesionTag,
    required this.inferenceTimeMs,
    required this.timestamp,
  });

  // Aliases for compatibility
  String get disclaimer => riskExplanation;

  /// Construct from FastAPI backend JSON response
  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    final rawLabel = (json['predicted_label'] ?? json['predicted_class'] ?? 'UNKNOWN').toString().toUpperCase();
    final rawFullName = json['predicted_label_full'] as String? ?? _defaultFullName(rawLabel);
    final rawConfidence = (json['confidence'] as num?)?.toDouble() ?? 0.0;
    final rawRisk = (json['risk_level'] as String? ?? 'MODERATE').toUpperCase();

    // Parse all_probabilities (handles List of objects or Map)
    final Map<String, double> parsedMap = {};
    final List<DiagnosticProbability> parsedList = [];

    if (json['all_probabilities'] is List) {
      final list = json['all_probabilities'] as List;
      for (var item in list) {
        if (item is Map) {
          final p = DiagnosticProbability.fromJson(Map<String, dynamic>.from(item));
          parsedList.add(p);
          parsedMap[p.label] = p.probability;
        }
      }
    } else if (json['all_probabilities'] is Map) {
      final map = json['all_probabilities'] as Map;
      map.forEach((k, v) {
        final label = k.toString();
        final prob = (v as num).toDouble();
        parsedMap[label] = prob;
        parsedList.add(DiagnosticProbability(
          label: label,
          fullName: _defaultFullName(label),
          probability: prob,
        ));
      });
    }

    // Sort probabilityList descending
    parsedList.sort((a, b) => b.probability.compareTo(a.probability));

    // Recommendations
    List<String> parsedRecs = [];
    if (json['recommendations'] is List) {
      parsedRecs = List<String>.from(json['recommendations'].map((e) => e.toString()));
    }
    if (parsedRecs.isEmpty) {
      parsedRecs = _generateFallbackRecommendations(rawLabel, rawRisk);
    }

    DateTime parsedDate;
    if (json['timestamp'] != null) {
      parsedDate = DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return PredictionResponse(
      predictedClass: rawLabel,
      predictedLabelFull: rawFullName,
      confidence: rawConfidence,
      riskLevel: rawRisk,
      riskColor: json['risk_color'] as String?,
      riskExplanation: json['risk_explanation'] as String? ?? json['disclaimer'] as String? ?? '',
      allProbabilities: parsedMap,
      probabilityList: parsedList,
      recommendations: parsedRecs,
      suggestReferral: (json['suggest_referral'] ?? json['suggests_referral']) as bool? ?? false,
      riskEscalated: json['risk_escalated'] as bool? ?? false,
      analysisId: json['analysis_id']?.toString(),
      imageUrl: ApiConfig.resolveMediaUrl(json['image_url'] as String?),
      gradcamUrl: ApiConfig.resolveMediaUrl(json['gradcam_url'] as String?),
      gradcamHeatmapBase64: json['gradcam_heatmap_base64'] as String?,
      patientId: json['patient_id']?.toString(),
      lesionTag: json['lesion_tag'] as String?,
      inferenceTimeMs: (json['inference_time_ms'] as num?)?.toDouble() ?? 0.0,
      timestamp: parsedDate,
    );
  }

  /// Serialization for GetStorage local caching
  Map<String, dynamic> toJson() {
    return {
      'predicted_label': predictedClass,
      'predicted_class': predictedClass,
      'predicted_label_full': predictedLabelFull,
      'confidence': confidence,
      'risk_level': riskLevel,
      'risk_color': riskColor,
      'risk_explanation': riskExplanation,
      'all_probabilities': allProbabilities,
      'recommendations': recommendations,
      'suggest_referral': suggestReferral,
      'risk_escalated': riskEscalated,
      'analysis_id': analysisId,
      'image_url': imageUrl,
      'gradcam_url': gradcamUrl,
      'gradcam_heatmap_base64': gradcamHeatmapBase64,
      'patient_id': patientId,
      'lesion_tag': lesionTag,
      'inference_time_ms': inferenceTimeMs,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// 5-tier clinical risk color mapping
  Color getRiskLevelColor() {
    switch (riskLevel.toUpperCase()) {
      case 'BENIGN':
      case 'FAIBLE':
      case 'LOW':
        return const Color(0xFF22C55E); // Green (#22c55e)
      case 'MODÉRÉ':
      case 'MODERATE':
        return const Color(0xFFF59E0B); // Amber (#f59e0b)
      case 'ÉLEVÉ':
      case 'HIGH':
        return const Color(0xFFEF4444); // Red (#ef4444)
      case 'CRITICAL':
        return const Color(0xFF7C3AED); // Deep Purple (#7c3aed)
      case 'INCONCLUSIVE':
      case 'INCONCLUANT':
      default:
        return const Color(0xFF64748B); // Slate Grey (#64748b)
    }
  }

  String getConfidencePercentage() {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  List<MapEntry<String, double>> getSortedProbabilities() {
    final entries = allProbabilities.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  static String _defaultFullName(String code) {
    switch (code.toUpperCase()) {
      case 'MEL':
        return 'Melanoma';
      case 'BCC':
        return 'Basal Cell Carcinoma';
      case 'SCC':
        return 'Squamous Cell Carcinoma';
      case 'ACK':
        return 'Actinic Keratosis';
      case 'NEV':
        return 'Melanocytic Nevus';
      case 'SEK':
        return 'Seborrheic Keratosis';
      default:
        return 'Atypical Lesion';
    }
  }

  static List<String> _generateFallbackRecommendations(String diagnosis, String risk) {
    final list = <String>[];
    switch (diagnosis) {
      case 'MEL':
        list.add('rec_consult_dermatologist');
        list.add('rec_biopsy_needed');
        list.add('rec_avoid_sun');
        break;
      case 'BCC':
      case 'SCC':
        list.add('rec_consult_dermatologist');
        list.add('rec_regular_checkup');
        list.add('rec_avoid_sun');
        break;
      case 'ACK':
        list.add('rec_consult_dermatologist');
        list.add('rec_monitor_changes');
        list.add('rec_avoid_sun');
        break;
      case 'NEV':
      case 'SEK':
      default:
        list.add('rec_monitor_changes');
        list.add('rec_follow_up');
        break;
    }
    if (risk == 'CRITICAL' || risk == 'HIGH' || risk == 'INCONCLUSIVE') {
      if (!list.contains('rec_consult_dermatologist')) {
        list.insert(0, 'rec_consult_dermatologist');
      }
    }
    return list;
  }
}
