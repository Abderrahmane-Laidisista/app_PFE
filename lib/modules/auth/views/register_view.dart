import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinician Self-Registration'),
        elevation: 0,
      ),
      body: Obx(() {
        return Stepper(
          currentStep: controller.currentStep.value,
          onStepContinue: () {
            if (controller.currentStep.value == 0) {
              controller.nextStep();
            } else {
              controller.submitRegistration();
            }
          },
          onStepCancel: () {
            if (controller.currentStep.value > 0) {
              controller.previousStep();
            } else {
              Get.back();
            }
          },
          controlsBuilder: (context, details) {
            final isLast = controller.currentStep.value == 1;
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              isLast ? 'Complete Registration' : 'Next Step',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
                    child: Text(controller.currentStep.value == 0 ? 'Cancel' : 'Back'),
                  ),
                ],
              ),
            );
          },
          steps: [
            // ── Step 1: Personal & Account ─────────────────────────────
            Step(
              title: const Text('Account Identity'),
              isActive: controller.currentStep.value >= 0,
              state: controller.currentStep.value > 0 ? StepState.complete : StepState.indexed,
              content: Form(
                key: controller.step1Key,
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name with Title (e.g. Dr. Amine Taleb)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter full name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Institutional Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter email';
                        if (!v.contains('@')) return 'Enter valid institutional email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        helperText: 'Minimum 8 characters with letters and numbers',
                      ),
                      validator: (v) => (v == null || v.length < 8) ? 'Password must be at least 8 characters' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock_reset),
                      ),
                      validator: (v) {
                        if (v != controller.passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Step 2: Medical Licensing & Institution ────────────────
            Step(
              title: const Text('Medical Credentials'),
              isActive: controller.currentStep.value >= 1,
              state: controller.currentStep.value >= 1 ? StepState.indexed : StepState.disabled,
              content: Form(
                key: controller.step2Key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Clinician Role / Practice Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Frontline GP'),
                            selected: controller.doctorType.value == 'general_practitioner',
                            onSelected: (_) => controller.setDoctorType('general_practitioner'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Dermatologist'),
                            selected: controller.doctorType.value == 'specialist_dermatologist',
                            onSelected: (_) => controller.setDoctorType('specialist_dermatologist'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.specializationController,
                      decoration: const InputDecoration(
                        labelText: 'Specialization',
                        prefixIcon: Icon(Icons.medical_services_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter specialization' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.licenseNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Order of Physicians License # (ORD-XX)',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter license number' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.institutionNameController,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Health Structure / Hospital / Clinic',
                        prefixIcon: Icon(Icons.local_hospital_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter healthcare institution' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: controller.wilaya.value,
                      decoration: const InputDecoration(
                        labelText: 'Wilaya (Province)',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                      items: controller.wilayas.map((w) {
                        return DropdownMenuItem(value: w['code'], child: Text(w['name']!));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.wilaya.value = val;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Professional Contact Phone',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter contact phone' : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
