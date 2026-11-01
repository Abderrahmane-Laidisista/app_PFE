import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../../result/views/widgets/risk_level_badge.dart';
import '../controllers/qr_followup_controller.dart';

class QRFollowUpView extends GetView<QRFollowUpController> {
  const QRFollowUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patient Medical Follow-Up'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan or Enter Token',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Access verified diagnostic summary and scheduled appointment dates.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Token input card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: controller.tokenController,
                      decoration: InputDecoration(
                        labelText: 'QR Follow-Up Token',
                        hintText: 'Paste JWT or scan QR code...',
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: controller.clear,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.fetchFollowUp,
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Verify & View Follow-Up'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Result or Loading
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.errorMessage.value != null) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value!,
                          style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final item = controller.followUpData.value;
              if (item == null) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Next Appointment Card (if scheduled)
                  if (item.nextFollowupDate != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.4), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: Color(0xFF7C3AED), size: 36),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Next Scheduled Clinical Checkup',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF7C3AED)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.nextFollowupDate!.year}-${item.nextFollowupDate!.month.toString().padLeft(2, '0')}-${item.nextFollowupDate!.day.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Diagnostic Card
                  Card(
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
                                'AI Primary Diagnosis',
                                style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              RiskLevelBadge(riskLevel: item.riskLevel),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${item.predictedClass.tr} (${item.predictedClass})',
                            style: Get.textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confidence: ${(item.confidence * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          if (item.doctorInstitution != null) ...[
                            const Divider(height: 24),
                            Row(
                              children: [
                                const Icon(Icons.local_hospital_outlined, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Treating Institution: ${item.doctorInstitution!}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (item.doctorConfirmed != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  item.doctorConfirmed! ? Icons.verified : Icons.info_outline,
                                  size: 18,
                                  color: item.doctorConfirmed! ? AppColors.success : Colors.amber,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.doctorConfirmed!
                                      ? 'Clinically validated by attending physician'
                                      : 'Clinical opinion: ${item.doctorDiagnosis ?? "Under Review"}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: item.doctorConfirmed! ? AppColors.success : Colors.brown,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recommendations Card
                  if (item.recommendations.isNotEmpty)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.assignment_outlined, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Physician Recommendations',
                                  style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ...item.recommendations.map((rec) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(rec.tr, style: const TextStyle(fontSize: 14)),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
