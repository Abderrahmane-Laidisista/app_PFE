import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../app/routes/app_routes.dart';

class CameraGetxController extends GetxController {
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  
  final isCameraInitialized = false.obs;
  final isCapturing = false.obs;
  final capturedImagePath = Rxn<String>();
  final imageQuality = 0.0.obs; // 0-100
  final brightness = 0.0.obs; // 0-100
  final flashMode = FlashMode.auto.obs; // Observable flash state
  
  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      
      if (status.isGranted) {
        // Get available cameras
        cameras = await availableCameras();
        
        if (cameras != null && cameras!.isNotEmpty) {
          // Use back camera
          cameraController = CameraController(
            cameras![0],
            ResolutionPreset.high,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.jpeg,
          );
          
          await cameraController!.initialize();
          
          // Set flash mode to auto
          await cameraController!.setFlashMode(FlashMode.auto);
          flashMode.value = FlashMode.auto;
          
          isCameraInitialized.value = true;
          
          debugPrint('✅ Camera initialized successfully');
        } else {
          debugPrint('❌ No cameras available');
          _showError('No camera found on device');
        }
      } else {
        debugPrint('❌ Camera permission denied');
        _showError('error_camera_permission'.tr);
      }
    } catch (e) {
      debugPrint('❌ Error initializing camera: $e');
      _showError('Error initializing camera: $e');
    }
  }
  
  Future<void> capturePhoto() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      _showError('Camera not initialized');
      return;
    }
    
    if (isCapturing.value) return;
    
    try {
      isCapturing.value = true;
      
      // Capture image
      final XFile image = await cameraController!.takePicture();
      capturedImagePath.value = image.path;
      
      debugPrint('✅ Photo captured: ${image.path}');
      
      // Analyze image quality (basic check)
      await _analyzeImageQuality(image.path);
      
    } catch (e) {
      debugPrint('❌ Error capturing photo: $e');
      _showError('Error capturing photo: $e');
    } finally {
      isCapturing.value = false;
    }
  }
  
  Future<void> _analyzeImageQuality(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      
      // Simple quality check based on file size
      // A good quality 1024x1024 JPEG should be around 100-500KB
      final sizeKB = bytes.length / 1024;
      
      if (sizeKB < 50) {
        imageQuality.value = 30.0;
      } else if (sizeKB < 100) {
        imageQuality.value = 50.0;
      } else if (sizeKB < 300) {
        imageQuality.value = 75.0;
      } else {
        imageQuality.value = 90.0;
      }
      
      // Brightness estimation (simplified)
      brightness.value = 60.0; // Default to medium brightness
      
      debugPrint('Image quality: ${imageQuality.value}%');
    } catch (e) {
      debugPrint('Error analyzing image: $e');
    }
  }
  
  void retakePhoto() {
    capturedImagePath.value = null;
    imageQuality.value = 0.0;
    brightness.value = 0.0;
  }
  
  void useThisPhoto() {
    if (capturedImagePath.value != null) {
      // Navigate to Clinical Form with image path
      Get.offNamed(
        AppRoutes.CONSENT,
        arguments: {'imagePath': capturedImagePath.value},
      );
    }
  }
  
  Future<void> toggleFlash() async {
    if (cameraController == null) return;
    
    final current = flashMode.value;
    FlashMode next;
    
    if (current == FlashMode.off) {
      next = FlashMode.auto;
    } else if (current == FlashMode.auto) {
      next = FlashMode.always;
    } else {
      next = FlashMode.off;
    }
    
    await cameraController!.setFlashMode(next);
    flashMode.value = next; // Update observable
  }
  
  void _showError(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }
  
  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}