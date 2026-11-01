import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../../../data/models/patient_model.dart';
import '../controllers/patients_controller.dart';
import 'patient_detail_view.dart';

class PatientsView extends GetView<PatientsController> {
  const PatientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Registry (Pseudonymous)'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePatientDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('New Patient'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search patient by code (e.g. DZ-31)...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) => controller.searchQuery.value = val,
            ),
          ),

          // Patients List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = controller.patients;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_shared_outlined, size: 64, color: AppColors.grey400),
                      const SizedBox(height: 16),
                      Text(
                        'No patients registered yet.',
                        style: Get.textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      const Text('Add a pseudonymous patient to track lesion changes over time.'),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadPatients,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = list[index];
                    return _buildPatientTile(p, context);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientTile(PatientModel p, BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            p.patientCode.length >= 2 ? p.patientCode.substring(0, 2) : 'DZ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        title: Text(
          p.patientCode,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Sex: ${p.sex.toUpperCase()} | Born: ${p.birthYear ?? "N/A"} | Scans: ${p.analysesCount}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          await controller.openPatientDetail(p.id);
          final detailed = controller.selectedPatient.value ?? p;
          Get.to(() => PatientDetailView(patient: detailed));
        },
      ),
    );
  }

  void _showCreatePatientDialog(BuildContext context) {
    final codeCtrl = TextEditingController(text: 'DZ-16-P0${100 + controller.patients.length}');
    final birthCtrl = TextEditingController(text: '1980');
    final notesCtrl = TextEditingController();
    String sex = 'male';

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Register New Patient'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Pseudonymous Code (e.g. DZ-31-P0105)',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: birthCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Birth Year',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Sex: '),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Male'),
                        selected: sex == 'male',
                        onSelected: (_) => setState(() => sex = 'male'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Female'),
                        selected: sex == 'female',
                        onSelected: (_) => setState(() => sex = 'female'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Clinical Notes (Optional)',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (codeCtrl.text.trim().isEmpty) return;
                  controller.createPatient(
                    code: codeCtrl.text.trim(),
                    birthYear: int.tryParse(birthCtrl.text),
                    sex: sex,
                    notes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                  );
                },
                child: const Text('Register'),
              ),
            ],
          );
        },
      ),
    );
  }
}
