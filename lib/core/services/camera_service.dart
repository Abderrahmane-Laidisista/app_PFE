import 'package:camera/camera.dart';
import 'package:get/get.dart';

class CameraService extends GetxService {
  List<CameraDescription> cameras = [];

  Future<CameraService> init() async {
    try {
      cameras = await availableCameras();
    } catch (_) {}
    return this;
  }
}
