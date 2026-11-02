import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/diagnosis_history.dart';
import '../../result/views/widgets/risk_level_badge.dart';
import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('history_title'.tr),
        centerTitle: true,
        actions: [
          Obx(() => controller.historyItems.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                  tooltip: 'Clear All',
                  onPressed: controller.clearAllHistory,
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // Risk Level Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Obx(() => Row(
                  children: [
                    _buildFilterChip('ALL', 'All Risks'),
                    const SizedBox(width: 8),
                    _buildFilterChip('CRITICAL', 'Critical'),
                    const SizedBox(width: 8),
                    _buildFilterChip('HIGH', 'High'),
                    const SizedBox(width: 8),
                    _buildFilterChip('MODERATE', 'Moderate'),
                    const SizedBox(width: 8),
                    _buildFilterChip('LOW', 'Low / Benign'),
                    const SizedBox(width: 8),
                    _buildFilterChip('INCONCLUSIVE', 'Inconclusive'),
                  ],
                )),
          ),

          // History List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = controller.historyItems;
              if (list.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.loadHistory,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildHistoryCard(item, index);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.offAllNamed(AppRoutes.HOME),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: Text('new_diagnosis'.tr),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = controller.selectedRiskFilter.value == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.filterByRisk(value),
    );
  }

  Widget _buildHistoryCard(DiagnosisHistoryItem item, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: _buildThumbnail(item),
              ),
            ),
            const SizedBox(width: 14),

            // Scan Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.diagnosis.tr} (${item.diagnosis})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.grey500),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => controller.deleteEntry(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Confidence: ${(item.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      RiskLevelBadge(riskLevel: item.riskLevel),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${item.date.day}/${item.date.month}/${item.date.year}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      if (item.patientId != null) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.person_outline, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(item.patientId!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(DiagnosisHistoryItem item) {
    if (item.imagePath != null && File(item.imagePath!).existsSync()) {
      return Image.file(File(item.imagePath!), fit: BoxFit.cover);
    }
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return Image.network(
        item.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.grey200,
          child: const Icon(Icons.broken_image, size: 28),
        ),
      );
    }
    return Container(
      color: AppColors.grey200,
      child: const Icon(Icons.image, size: 28),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 72, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              'No Historical Scans Found',
              style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Diagnoses performed on this device or synchronized from your doctor account will appear here.',
              textAlign: TextAlign.center,
              style: Get.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
