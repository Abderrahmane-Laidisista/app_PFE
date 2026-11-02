import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/api/api_constants.dart';
import '../../../app/config/theme/app_colores.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/providers/api_provider.dart';

class ForceChangePasswordView extends StatefulWidget {
  const ForceChangePasswordView({super.key});

  @override
  State<ForceChangePasswordView> createState() => _ForceChangePasswordViewState();
}

class _ForceChangePasswordViewState extends State<ForceChangePasswordView> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Update Required'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.security, size: 56, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Security Policy Enforcement',
                textAlign: TextAlign.center,
                style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You must update your temporary initial password before proceeding into the clinical decision support system.',
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current / Temporary Password',
                  prefixIcon: Icon(Icons.key_outlined),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter your temporary password' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Strong Password (min 8 chars)',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) {
                  if (v == null || v.length < 8) return 'Password must be at least 8 characters';
                  if (v == _currentPasswordController.text) return 'New password must differ from temporary password';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_reset),
                ),
                validator: (v) => (v != _newPasswordController.text) ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPasswordChange,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Password & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPasswordChange() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final api = Get.find<ApiProvider>();
      final response = await api.put(
        ApiConstants.changePassword,
        body: {
          'current_password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
        },
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        if (Get.isRegistered<AuthService>()) {
          await Get.find<AuthService>().fetchCurrentProfile();
        }
        Get.offAllNamed(AppRoutes.MAIN_LAYOUT);
        Get.snackbar(
          'Success',
          'Password updated successfully. Welcome!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        String msg = 'Failed to change password';
        try {
          final err = jsonDecode(response.body);
          if (err['detail'] != null) msg = err['detail'].toString();
        } catch (_) {}
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
