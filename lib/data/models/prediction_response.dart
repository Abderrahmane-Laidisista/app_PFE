import 'package:flutter/material.dart';
import 'package:get/get.dart';
class PredictionResponse {
  final String predictedClass;
  final double confidence;
  final String riskLevel;
  final Map<String, double> allProbabilities;
  final double inferenceTimeMs;
  final String disclaimer;
  final List<String> recommendations;
  
  PredictionResponse({
    required this.predictedClass,
    required this.confidence,
    required this.riskLevel,
    required this.allProbabilities,
    required this.inferenceTimeMs,
    required this.disclaimer,
    required this.recommendations,
  });
  
  // Create from JSON (API response)
  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    // Note: FastAPI returns 'predicted_label' instead of 'predicted_class'
    final predictedClass = json['predicted_label'] as String? ?? 'UNKNOWN';
    final riskLevel = json['risk_level'] as String? ?? 'MODERATE';
    
    // Check if probabilities came as a List of objects (FastAPI format) or a Map
    Map<String, double> parsedProbabilities = {};
    if (json['all_probabilities'] is List) {
      final list = json['all_probabilities'] as List;
      for (var item in list) {
        parsedProbabilities[item['label'].toString()] = (item['probability'] as num).toDouble();
      }
    } else if (json['all_probabilities'] is Map) {
      parsedProbabilities = Map<String, double>.from(
        (json['all_probabilities'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      );
    }
    
    // We get recommendations from FastAPI, or fallback to generating them locally
    List<String> parsedRecommendations = [];
    if (json['recommendations'] is List) {
      parsedRecommendations = List<String>.from(json['recommendations']);
    } else {
      parsedRecommendations = _generateRecommendations(predictedClass, riskLevel);
    }
    
    return PredictionResponse(
      predictedClass: predictedClass,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      riskLevel: riskLevel,
      allProbabilities: parsedProbabilities,
      inferenceTimeMs: (json['inference_time_ms'] as num?)?.toDouble() ?? 0.0,
      disclaimer: json['risk_explanation'] as String? ?? 'disclaimer_text',
      recommendations: parsedRecommendations,
    );
  }
  
  // Convert to JSON (for storage)
  Map<String, dynamic> toJson() {
    return {
      'predicted_class': predictedClass,
      'confidence': confidence,
      'risk_level': riskLevel,
      'all_probabilities': allProbabilities,
      'inference_time_ms': inferenceTimeMs,
      'disclaimer': disclaimer,
      'recommendations': recommendations,
    };
  }
  
  // Generate recommendations based on diagnosis and risk
  static List<String> _generateRecommendations(String diagnosis, String riskLevel) {
    final recommendations = <String>[];
    
    // Based on diagnosis
    switch (diagnosis) {
      case 'MEL': // Melanoma
        recommendations.add('rec_consult_dermatologist');
        recommendations.add('rec_biopsy_needed');
        recommendations.add('rec_avoid_sun');
        break;
      case 'BCC': // Basal Cell Carcinoma
      case 'SCC': // Squamous Cell Carcinoma
        recommendations.add('rec_consult_dermatologist');
        recommendations.add('rec_regular_checkup');
        recommendations.add('rec_avoid_sun');
        break;
      case 'ACK': // Actinic Keratosis
        recommendations.add('rec_consult_dermatologist');
        recommendations.add('rec_monitor_changes');
        recommendations.add('rec_avoid_sun');
        break;
      case 'NEV': // Nevus
      case 'SEK': // Seborrheic Keratosis
        recommendations.add('rec_monitor_changes');
        recommendations.add('rec_follow_up');
        break;
    }
    
    // Based on risk level — handle all V6.0 risk levels
    if (riskLevel == 'CRITICAL' || riskLevel == 'ÉLEVÉ' || riskLevel == 'HIGH') {
      if (!recommendations.contains('rec_consult_dermatologist')) {
        recommendations.insert(0, 'rec_consult_dermatologist');
      }
    }
    
    return recommendations;
  }
  
  // Get risk level color — aligned with backend V6.0 RiskLevel enum
  // Backend returns: LOW | MODERATE | HIGH | CRITICAL
  Color getRiskLevelColor() {
    switch (riskLevel.toUpperCase()) {
      case 'FAIBLE':
      case 'LOW':
        return const Color(0xFF22C55E); // Green  (#22c55e matches backend RISK_COLOR)
      case 'MODÉRÉ':
      case 'MODERATE':
        return const Color(0xFFF59E0B); // Amber  (#f59e0b matches backend RISK_COLOR)
      case 'ÉLEVÉ':
      case 'HIGH':
        return const Color(0xFFEF4444); // Red    (#ef4444 matches backend RISK_COLOR)
      case 'CRITICAL':
        return const Color(0xFF7C3AED); // Purple (#7c3aed matches backend RISK_COLOR)
      default:
        return const Color(0xFF9E9E9E); // Grey — fallback
    }
  }
  
  // Get diagnosis class full name
  String getDiagnosisFullName() {
    return predictedClass; // Translation will be handled by GetX
  }
  
  // Get confidence percentage
  String getConfidencePercentage() {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }
  
  // Get sorted probabilities
  List<MapEntry<String, double>> getSortedProbabilities() {
    final entries = allProbabilities.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }
  
  @override
  String toString() {
    return 'PredictionResponse(predictedClass: $predictedClass, confidence: ${getConfidencePercentage()}, riskLevel: $riskLevel)';
  }
}