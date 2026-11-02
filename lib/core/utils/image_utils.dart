import 'dart:io';

/// Image helper utilities for dermoscopy and clinical captures.
class ImageUtils {
  ImageUtils._();

  static bool isValidImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') || lower.endsWith('.webp');
  }

  static double getFileSizeInMb(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }
}
