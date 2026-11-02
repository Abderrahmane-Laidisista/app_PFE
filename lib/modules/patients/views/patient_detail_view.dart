import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../../../data/models/patient_model.dart';
import '../../result/views/widgets/risk_level_badge.dart';

class PatientDetailView extends StatelessWidget {
  final PatientModel patient;

  const PatientDetailView({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient ${patient.patientCode}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Header Card
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
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, color: AppColors.primary, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.patientCode,
                                style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sex: ${patient.sex.toUpperCase()} | Born: ${patient.birthYear ?? "N/A"}',
                                style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (patient.notes != null && patient.notes!.isNotEmpty) ...[
                      const Divider(height: 24),
                      Text('Clinical Record Notes:', style: Get.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(patient.notes!, style: Get.textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Timeline Header
            Row(
              children: [
                const Icon(Icons.timeline_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Lesion Evolution Timeline (${patient.timeline.length} scans)',
                  style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (patient.timeline.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('No scans linked to this patient yet. Link a scan from the clinical form.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: patient.timeline.length,
                itemBuilder: (context, index) {
                  final item = patient.timeline[index];
                  return _buildTimelineTile(item, index == patient.timeline.length - 1);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile(PatientTimelineItem item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chronological Indicator Line
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 110,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Timeline Scan Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        RiskLevelBadge(riskLevel: item.riskLevel),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Diagnosis: ${item.predictedClass} (${(item.confidence * 100).toStringAsFixed(1)}%)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (item.lesionTag != null) ...[
                      const SizedBox(height: 4),
                      Text('Tag: ${item.lesionTag}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                    if (item.diameter1 != null) ...[
                      const SizedBox(height: 4),
                      Text('Diameter: ${item.diameter1!.toStringAsFixed(1)} mm', style: const TextStyle(fontSize: 12)),
                    ],
                    if (item.doctorConfirmed != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.doctorConfirmed == true ? '✓ Doctor Confirmed' : '⚠ Doctor Modified: ${item.doctorDiagnosis}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.doctorConfirmed == true ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
