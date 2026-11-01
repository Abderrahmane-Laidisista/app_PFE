import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../../../data/models/referral_model.dart';
import '../controllers/referrals_controller.dart';

class ReferralsView extends GetView<ReferralsController> {
  const ReferralsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Telemedicine Referrals (Télé-expertise)'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.send_rounded), text: 'Sent Cases'),
              Tab(icon: Icon(Icons.inbox_rounded), text: 'Incoming (Specialist)'),
              Tab(icon: Icon(Icons.add_circle_outline), text: 'Create Referral'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Tab 1: Sent Referrals List (GP) ─────────────────────
            _buildSentReferralsTab(),

            // ── Tab 2: Received Referrals List (Specialist) ─────────
            _buildReceivedReferralsTab(context),

            // ── Tab 3: Create Referral Form ─────────────────────────
            _buildCreateReferralTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSentReferralsTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final list = controller.sentReferrals;
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: AppColors.grey400),
              const SizedBox(height: 16),
              Text(
                'No telemedicine referrals dispatched yet.',
                style: Get.textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              const Text('Dispatched clinical cases will appear here with specialist responses.'),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadSentReferrals,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ref = list[index];
            return _buildReferralCard(ref);
          },
        ),
      );
    });
  }

  Widget _buildReceivedReferralsTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final list = controller.receivedReferrals;
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.grey400),
              const SizedBox(height: 16),
              Text(
                'No incoming tele-expertise cases.',
                style: Get.textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              const Text('Cases referred to you by general practitioners will appear here.'),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadReceivedReferrals,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ref = list[index];
            return _buildReceivedReferralCard(ref, context);
          },
        ),
      );
    });
  }

  Widget _buildReferralCard(ReferralModel ref) {
    final bool isCompleted = ref.status == 'completed';
    final Color statusColor = isCompleted ? AppColors.success : Colors.amber.shade700;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isCompleted ? Icons.check_circle : Icons.schedule, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        ref.status.toUpperCase(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${ref.createdAt.day}/${ref.createdAt.month}/${ref.createdAt.year}',
                  style: Get.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (ref.analysisPredictedClass != null) ...[
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Suspected: ${ref.analysisPredictedClass} (${((ref.analysisConfidence ?? 0) * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (ref.analysisRiskLevel != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '[${ref.analysisRiskLevel}]',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Referral Note: "${ref.referralNote}"',
              style: Get.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 12),
            if (ref.specialistName != null)
              Row(
                children: [
                  const Icon(Icons.person_pin, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text('Assigned: ${ref.specialistName}', style: Get.textTheme.bodySmall),
                ],
              ),
            if (ref.specialistResponse != null && ref.specialistResponse!.isNotEmpty) ...[
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_user_rounded, color: AppColors.success, size: 18),
                        SizedBox(width: 6),
                        Text('Specialist Dermatologist Opinion:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ref.specialistResponse!,
                      style: Get.textTheme.bodyMedium?.copyWith(height: 1.4, fontWeight: FontWeight.w500),
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

  Widget _buildReceivedReferralCard(ReferralModel ref, BuildContext context) {
    final bool isCompleted = ref.status == 'completed';
    final Color statusColor = isCompleted ? AppColors.success : Colors.purple;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isCompleted ? Icons.check_circle : Icons.pending_actions_rounded, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        isCompleted ? 'ANSWERED' : 'PENDING REVIEW',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${ref.createdAt.day}/${ref.createdAt.month}/${ref.createdAt.year}',
                  style: Get.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (ref.referringDoctorName != null)
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text('From: Dr. ${ref.referringDoctorName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              'GP Clinical Inquiry: "${ref.referralNote}"',
              style: Get.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 14),
            if (isCompleted && ref.specialistResponse != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Your Opinion: ${ref.specialistResponse!}',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showSpecialistResponseSheet(ref, context),
                  icon: const Icon(Icons.rate_review_rounded),
                  label: const Text('Provide Specialist Opinion'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSpecialistResponseSheet(ReferralModel ref, BuildContext context) {
    final responseTextController = TextEditingController();

    Get.bottomSheet(
      Container(
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
                'Specialist Clinical Evaluation',
                style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Provide your formal dermatological second-opinion for the referring GP.',
                style: Get.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: responseTextController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Specialist Assessment & Recommended Plan',
                  hintText: 'Enter clinical diagnosis, biopsy recommendation, excision urgency, or dermoscopy review...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (responseTextController.text.trim().isEmpty) {
                      Get.snackbar('Input Required', 'Please provide clinical recommendations');
                      return;
                    }
                    controller.respondToReferral(
                      referralId: ref.id,
                      responseText: responseTextController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Transmit Formal Response'),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildCreateReferralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Specialist Referral',
            style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Send an urgent case to a registered specialist dermatologist for second-opinion clinical evaluation.',
            style: Get.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Case Summary Card
          Obx(() {
            if (controller.analysisId.value.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('To refer a specific scan, use the "Request Specialist Referral" button directly from the Result screen.'),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected Analysis Case:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Analysis ID: ${controller.analysisId.value}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  if (controller.predictedClass.value.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Predicted Class: ${controller.predictedClass.value} (${(controller.confidence.value * 100).toStringAsFixed(1)}%) | ${controller.riskLevel.value}'),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 20),

          // Specialist Dropdown (from /public/doctors)
          const Text('Designated Specialist Dermatologist (Optional):', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() {
            return DropdownButtonFormField<String>(
              value: controller.selectedSpecialistId.value,
              isExpanded: true,
              decoration: const InputDecoration(
                hintText: 'Regional Dermatologist Pool (Any available)',
                prefixIcon: Icon(Icons.person_search_outlined),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Regional Specialist Pool (Default)'),
                ),
                ...controller.specialists.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc.userId,
                    child: Text('${doc.fullName} (${doc.institutionName})'),
                  );
                }),
              ],
              onChanged: (val) => controller.selectedSpecialistId.value = val,
            );
          }),
          const SizedBox(height: 20),

          // Referral Note Input
          const Text('Clinical Referral Note / Question:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller.referralNoteController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Describe clinical suspicion, asymmetric border, rapid growth, bleeding history, or request surgical excision advice...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isSubmitting.value ? null : controller.submitReferral,
                  icon: const Icon(Icons.send_rounded),
                  label: controller.isSubmitting.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Dispatch Case to Specialist'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
