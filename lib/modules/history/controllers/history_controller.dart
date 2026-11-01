import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/diagnosis_history.dart';
import '../../../data/repositories/history_repository.dart';

class HistoryController extends GetxController {
  final HistoryRepository _repo = Get.find<HistoryRepository>();

  final historyItems = <DiagnosisHistoryItem>[].obs;
  final isLoading = true.obs;
  final selectedRiskFilter = 'ALL'.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      isLoading.value = true;
      final risk = selectedRiskFilter.value == 'ALL' ? null : selectedRiskFilter.value;
      final list = await _repo.getAnalyses(riskLevel: risk);
      historyItems.value = list;
      debugPrint('✅ Loaded ${historyItems.length} history entries (Filter: ${selectedRiskFilter.value})');
    } catch (e) {
      debugPrint('❌ Error loading history: $e');
      Get.snackbar(
        'error'.tr,
        'Failed to load history',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterByRisk(String risk) {
    selectedRiskFilter.value = risk;
    loadHistory();
  }

  Future<void> deleteEntry(int index) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('delete_confirmation'.tr),
          content: const Text('This action will remove the record from history.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                foregroundColor: Get.theme.colorScheme.error,
              ),
              child: Text('delete'.tr),
            ),
          ],
        ),
      );

      if (confirmed == true && index < historyItems.length) {
        final item = historyItems[index];
        await _repo.deleteAnalysis(item.id, index);
        historyItems.removeAt(index);

        Get.snackbar(
          'success'.tr,
          'deleted_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('❌ Error deleting entry: $e');
    }
  }

  Future<void> clearAllHistory() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This will delete all cached diagnosis history. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Get.theme.colorScheme.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repo.clearAll();
      historyItems.clear();
      Get.snackbar('success'.tr, 'History cleared', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
