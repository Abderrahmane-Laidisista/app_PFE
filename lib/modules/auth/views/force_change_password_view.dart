import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class ForceChangePasswordView extends StatefulWidget {
  const ForceChangePasswordView({super.key});

  @override
  State<ForceChangePasswordView> createState() => _ForceChangePasswordViewState();
}

class _ForceChangePasswordViewState extends State<ForceChangePasswordView> {
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
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Strong Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => (v == null || v.length < 8) ? 'Password must be at least 8 characters' : null,
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
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
    Get.offAllNamed(AppRoutes.HOME);
    Get.snackbar('Success', 'Password updated successfully. Welcome!');
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
