import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {

  final Connectivity _connectivity = Connectivity();

  final isOnline = false.obs;
  final connectionType = Rx<ConnectivityResult>(ConnectivityResult.none);

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {

    final result = await _connectivity.checkConnectivity();

    await _updateStatus(result);

    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  Future<void> _updateStatus(List<ConnectivityResult> results) async {

    final result = results.first;

    connectionType.value = result;

    if (result == ConnectivityResult.none) {
      isOnline.value = false;
      return;
    }

    isOnline.value = await _hasInternetAccess();
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkInternet() async {

    final result = await _connectivity.checkConnectivity();

    if (result.first == ConnectivityResult.none) {
      return false;
    }

    return await _hasInternetAccess();
  }

  @override
  void onClose() {

    _subscription?.cancel();

    super.onClose();

  }
}