import 'dart:io';
import 'package:camera/camera.dart' as cam;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/theme/app_colores.dart';
import '../controllers/camera_controller.dart' as ctrl;

class CameraView extends GetView<ctrl.CameraGetxController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        
        // Show preview or captured image
        return controller.capturedImagePath.value != null
            ? _buildImagePreview()
            : _buildCameraPreview();
      }),
    );
  }
  
  Widget _buildCameraPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        cam.CameraPreview(controller.cameraController!),
        
        // Overlay with guide circle
        _buildCameraOverlay(),
        
        // Top Controls
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: _buildTopControls(),
          ),
        ),
        
        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: _buildBottomControls(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCameraOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Guide Circle
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.cameraGuideBorder,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Guide Text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'camera_guide'.tr,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Get.back(),
          ),
          
          // Flash Button — uses Obx correctly (observable is inside Obx scope)
          Obx(() {
            final mode = controller.flashMode.value;
            IconData icon;
            if (mode == cam.FlashMode.off) {
              icon = Icons.flash_off;
            } else if (mode == cam.FlashMode.auto) {
              icon = Icons.flash_auto;
            } else {
              icon = Icons.flash_on;
            }
            return IconButton(
              icon: Icon(icon, color: Colors.white, size: 28),
              onPressed: controller.toggleFlash,
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'camera_tips_title'.tr,
                  style: Get.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...[
                  'camera_tip_1',
                  'camera_tip_2',
                  'camera_tip_3',
                  'camera_tip_4',
                ].map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    tip.tr,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                )),
              ],
            ),
          ),
          
          // Capture Button
          Obx(() => GestureDetector(
            onTap: controller.isCapturing.value ? null : controller.capturePhoto,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: AppColors.primary,
                  width: 4,
                ),
              ),
              child: controller.isCapturing.value
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      size: 36,
                      color: AppColors.primary,
                    ),
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Captured Image
        Image.file(
          File(controller.capturedImagePath.value!),
          fit: BoxFit.cover,
        ),
        
        // Top Controls
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Get.back(),
                  ),
                  
                  // Quality Indicator
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getQualityColor().withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getQualityIcon(),
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getQualityText(),
                          style: Get.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
        
        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Retake Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.retakePhoto,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        'retake'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Use Photo Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.useThisPhoto,
                      icon: const Icon(Icons.check),
                      label: Text('use_this_photo'.tr),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getQualityColor() {
    final quality = controller.imageQuality.value;
    if (quality >= 70) return AppColors.success;
    if (quality >= 40) return AppColors.warning;
    return AppColors.error;
  }
  
  IconData _getQualityIcon() {
    final quality = controller.imageQuality.value;
    if (quality >= 70) return Icons.check_circle;
    if (quality >= 40) return Icons.warning;
    return Icons.error;
  }
  
  String _getQualityText() {
    final quality = controller.imageQuality.value;
    if (quality >= 70) return 'camera_quality_good'.tr;
    return 'camera_quality_poor'.tr;
  }
}