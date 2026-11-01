import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../../../data/models/public_doctor.dart';
import '../controllers/doctor_directory_controller.dart';

class DoctorDirectoryView extends GetView<DoctorDirectoryController> {
  const DoctorDirectoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verified Clinician Directory'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String?>(
                        value: controller.selectedType.value,
                        decoration: const InputDecoration(
                          labelText: 'Clinician Specialization',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All Clinicians')),
                          DropdownMenuItem(value: 'specialist_dermatologist', child: Text('Specialist Dermatologists')),
                          DropdownMenuItem(value: 'general_practitioner', child: Text('General Practitioners')),
                        ],
                        onChanged: controller.filterByType,
                      )),
                ),
              ],
            ),
          ),

          // Directory List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = controller.doctors;
              if (list.isEmpty) {
                return const Center(
                  child: Text('No verified clinicians found for the selected filter.'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = list[index];
                  return _buildDoctorCard(doc);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(PublicDoctor doc) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: doc.isSpecialist ? const Color(0xFF7C3AED).withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
              child: Icon(
                doc.isSpecialist ? Icons.verified : Icons.local_hospital,
                color: doc.isSpecialist ? const Color(0xFF7C3AED) : AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doc.specialization,
                    style: TextStyle(
                      color: doc.isSpecialist ? const Color(0xFF7C3AED) : AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${doc.institutionName} ${doc.wilaya != null ? "(Wilaya ${doc.wilaya})" : ""}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
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
}
