import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../../../data/models/prediction_response.dart';
import '../controllers/result_controller.dart';
import 'widgets/risk_level_badge.dart';

class ResultView extends GetView<ResultController> {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.result == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final result = controller.result!;

    return Scaffold(
      appBar: AppBar(
        title: Text('result_title'.tr),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: controller.startNewDiagnosis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export Medical Report',
            onPressed: controller.exportPdfReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Image / Grad-CAM++ Heatmap Viewer ──────────────────
            _buildImageViewer(result),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDiagnosisCard(result),
                  const SizedBox(height: 16),
                  _buildConfidenceCard(result),
                  const SizedBox(height: 16),
                  _buildRiskLevelCard(result),
                  const SizedBox(height: 16),
                  _buildProbabilitiesCard(result),
                  const SizedBox(height: 16),
                  _buildRecommendationsCard(result),
                  const SizedBox(height: 16),
                  _buildDisclaimerCard(),
                  const SizedBox(height: 24),
                  _buildActionButtons(result, context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Interactive Image Viewer with Grad-CAM Saliency Overlay Toggle
  Widget _buildImageViewer(PredictionResponse result) {
    return Obx(() {
      final isHeatmap = controller.showHeatmap.value;

      Widget imageContent;

      if (isHeatmap && result.gradcamHeatmapBase64 != null) {
        // Base64 heatmap from inference response
        final cleanBase64 = result.gradcamHeatmapBase64!.contains(',')
            ? result.gradcamHeatmapBase64!.split(',').last
            : result.gradcamHeatmapBase64!;
        imageContent = Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 260,
        );
      } else if (isHeatmap && (controller.resolvedGradcamUrl.value ?? result.gradcamUrl) != null && (controller.resolvedGradcamUrl.value ?? result.gradcamUrl)!.isNotEmpty) {
        // Remote Grad-CAM URL
        imageContent = Image.network(
          (controller.resolvedGradcamUrl.value ?? result.gradcamUrl)!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 260,
          errorBuilder: (_, __, ___) => _buildLocalImageFallback(),
        );
      } else {
        // Original dermoscopy photo
        imageContent = _buildLocalImageFallback();
      }

      return Stack(
        children: [
          Container(
            height: 260,
            width: double.infinity,
            color: Colors.black,
            child: imageContent,
          ),
          // Saliency overlay toggle pill
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPillButton(
                    label: 'Original',
                    isSelected: !isHeatmap,
                    onTap: () {
                      if (isHeatmap) controller.toggleHeatmap();
                    },
                  ),
                  _buildPillButton(
                    label: 'Grad-CAM++',
                    isSelected: isHeatmap,
                    onTap: () {
                      if (!isHeatmap) controller.toggleHeatmap();
                    },
                  ),
                ],
              ),
            ),
          ),
          if (isHeatmap)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'AI Attention Map',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildLocalImageFallback() {
    if (controller.imagePath != null && File(controller.imagePath!).existsSync()) {
      return Image.file(
        File(controller.imagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 260,
      );
    }
    if (controller.result?.imageUrl != null) {
      return Image.network(
        controller.result!.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 260,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.grey200,
          child: const Center(child: Icon(Icons.broken_image, size: 48)),
        ),
      );
    }
    return Container(
      color: AppColors.grey200,
      child: const Center(child: Icon(Icons.image, size: 48)),
    );
  }

  Widget _buildPillButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisCard(PredictionResponse result) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medical_information_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'diagnosis'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${result.predictedClass.tr} (${result.predictedClass})',
                          style: Get.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline, color: AppColors.secondary),
                        tooltip: 'What is this?',
                        onPressed: () => _showMedicalDictionary(result.predictedClass),
                      ),
                    ],
                  ),
                  if (result.predictedLabelFull.isNotEmpty)
                    Text(
                      result.predictedLabelFull,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceCard(PredictionResponse result) {
    final confidence = result.confidence;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'confidence'.tr,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  result.getConfidencePercentage(),
                  style: Get.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 12,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getConfidenceColor(confidence),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.timer, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '${'inference_time'.tr}: ${result.inferenceTimeMs.toStringAsFixed(1)} ms',
                  style: Get.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskLevelCard(PredictionResponse result) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'risk_level'.tr,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RiskLevelBadge(
                        riskLevel: result.riskLevel,
                        showExplanation: true,
                        customExplanation: result.riskExplanation,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (result.riskEscalated) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Risk level escalated due to uncertainty or borderline lesion margin.',
                        style: Get.textTheme.bodySmall?.copyWith(color: Colors.brown),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilitiesCard(PredictionResponse result) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'detailed_probabilities'.tr,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Obx(() => Icon(
                        controller.showProbabilities.value
                            ? Icons.expand_less
                            : Icons.expand_more,
                      )),
                  onPressed: controller.toggleProbabilities,
                ),
              ],
            ),
            Obx(() {
              if (!controller.showProbabilities.value) {
                return const SizedBox.shrink();
              }

              final sorted = result.getSortedProbabilities();

              return Column(
                children: [
                  const SizedBox(height: 12),
                  ...sorted.map((entry) {
                    final isTop = entry.key == result.predictedClass;
                    final percentage = (entry.value * 100).toStringAsFixed(1);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${entry.key.tr} (${entry.key})',
                                style: TextStyle(
                                  fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                  color: isTop ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '$percentage%',
                                style: TextStyle(
                                  fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                  color: isTop ? AppColors.primary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: entry.value,
                              minHeight: 6,
                              backgroundColor: AppColors.grey200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isTop ? AppColors.primary : AppColors.grey400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(PredictionResponse result) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'recommendations'.tr,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...result.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          rec.tr,
                          style: Get.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return InkWell(
      onTap: controller.showDisclaimer,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'disclaimer_text'.tr,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(PredictionResponse result, BuildContext context) {
    final showReferralButton = result.suggestReferral ||
        result.riskLevel == 'CRITICAL' ||
        result.riskLevel == 'HIGH' ||
        result.riskLevel == 'INCONCLUSIVE';

    return Column(
      children: [
        // ── Télé-expertise Referral CTA ────────────────────────────
        if (showReferralButton) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.requestSpecialistReferral,
              icon: const Icon(Icons.share_arrival_time_rounded, color: Colors.white),
              label: const Text('Request Specialist Referral (Télé-expertise)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED), // Purple CTA
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Doctor Feedback Concordance Button ──────────────────────
        Obx(() {
          if (controller.feedbackSubmitted.value) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Text('Clinical Feedback Confirmed & Logged', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDoctorFeedbackSheet(context),
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Doctor Confirmation / Feedback'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),

        // ── Save & Export PDF ──────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.saveResult,
                icon: const Icon(Icons.save),
                label: Text('save_result'.tr),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.exportPdfReport,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Export PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: controller.startNewDiagnosis,
            icon: const Icon(Icons.add),
            label: Text('new_diagnosis'.tr),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _showDoctorFeedbackSheet(BuildContext context) {
    bool confirmed = true;
    String selectedClass = controller.result!.predictedClass;
    bool biopsy = false;
    final biopsyTextController = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doctor Concordance Feedback',
                    style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Evaluate model prediction accuracy and provide clinical ground truth.',
                    style: Get.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Text('Do you agree with the AI diagnosis?', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Agree (Confirm)'),
                        selected: confirmed,
                        onSelected: (val) => setState(() => confirmed = true),
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('Disagree (Modify)'),
                        selected: !confirmed,
                        onSelected: (val) => setState(() => confirmed = false),
                      ),
                    ],
                  ),
                  if (!confirmed) ...[
                    const SizedBox(height: 16),
                    const Text('Your Clinical Diagnosis:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedClass,
                      items: ['MEL', 'BCC', 'SCC', 'ACK', 'NEV', 'SEK'].map((c) {
                        return DropdownMenuItem(value: c, child: Text('$c (${c.tr})'));
                      }).toList(),
                      onChanged: (val) => setState(() => selectedClass = val ?? 'MEL'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Biopsy Performed?'),
                    value: biopsy,
                    onChanged: (val) => setState(() => biopsy = val),
                  ),
                  if (biopsy) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: biopsyTextController,
                      decoration: const InputDecoration(
                        labelText: 'Biopsy Result / Histological Note',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.submitConcordanceFeedback(
                          confirmed: confirmed,
                          diagnosis: confirmed ? controller.result!.predictedClass : selectedClass,
                          biopsyPerformed: biopsy,
                          biopsyResult: biopsyTextController.text.isNotEmpty ? biopsyTextController.text : null,
                        );
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Submit Clinical Feedback'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  void _showMedicalDictionary(String diagnosisClass) {
    Map<String, String> titleMap = {
      'MEL': 'Melanoma',
      'BCC': 'Basal Cell Carcinoma',
      'SCC': 'Squamous Cell Carcinoma',
      'ACK': 'Actinic Keratosis',
      'NEV': 'Melanocytic Nevus',
      'SEK': 'Seborrheic Keratosis',
    };

    Map<String, String> descMap = {
      'MEL': 'A serious form of skin cancer that begins in cells known as melanocytes. Highly aggressive, requires immediate clinical excision.',
      'BCC': 'The most common form of skin cancer, arising from the basal cell layer. Slow-growing and rarely metastasizes.',
      'SCC': 'The second most common form of skin cancer. Arises in the squamous cells of the epidermis. High cure rate when detected early.',
      'ACK': 'A rough, scaly patch on the skin caused by years of sun exposure. Pre-malignant lesion that may progress to SCC.',
      'NEV': 'A common pigmented skin lesion (mole), typically benign and composed of melanocytes.',
      'SEK': 'A common, non-cancerous skin growth that often appears as a waxy or wart-like growth in older adults.',
    };

    Get.dialog(
      AlertDialog(
        title: Text(titleMap[diagnosisClass] ?? diagnosisClass),
        content: Text(descMap[diagnosisClass] ?? 'Skin lesion requiring dermatological evaluation.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('done'.tr),
          ),
        ],
      ),
    );
  }
}
