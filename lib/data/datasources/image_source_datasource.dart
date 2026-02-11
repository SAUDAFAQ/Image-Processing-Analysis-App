import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

import '../../core/errors/app_failure.dart';
import '../../core/utils/constants.dart';
import '../../domain/repositories/image_source_repository.dart';

/// Picks image from camera or gallery; copies (and resizes) to app temp dir and returns path.
/// Resizing avoids OOM/crashes on large camera photos. Copy ensures path stays valid (iOS temp reclaim).
class ImageSourceDataSource implements ImageSourceRepository {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String> pickImage(ImageSourceType source) async {
    if (source == ImageSourceType.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        throw const PermissionFailure('Camera permission denied');
      }
    } else {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        throw const PermissionFailure('Photo library permission denied');
      }
    }

    // Request smaller size from picker to reduce memory; some devices still return large files.
    const maxDim = AppConstants.maxImageDimension;
    final XFile? file = source == ImageSourceType.camera
        ? await _picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
            maxWidth: maxDim.toDouble(),
            maxHeight: maxDim.toDouble(),
          )
        : await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
            maxWidth: maxDim.toDouble(),
            maxHeight: maxDim.toDouble(),
          );

    if (file == null) {
      throw const ImageLoadFailure('No image selected');
    }

    final path = file.path;
    if (path.isEmpty) throw const ImageLoadFailure('Invalid image path');
    final sourceFile = File(path);
    if (!await sourceFile.exists()) throw const ImageLoadFailure('Image file not found');

    final bytes = await sourceFile.readAsBytes();
    // Resize in isolate to avoid OOM on main isolate with large camera images.
    final resizedBytes = await compute(_resizeImageIfNeeded, bytes);
    final tempDir = await getTemporaryDirectory();
    final destPath = p.join(tempDir.path, 'imageflow_pick_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await File(destPath).writeAsBytes(resizedBytes);
    return destPath;
  }
}

/// Top-level for compute: decode, resize so longest edge <= maxImageDimension, encode as jpg.
List<int> _resizeImageIfNeeded(List<int> bytes) {
  final decoded = img.decodeImage(Uint8List.fromList(bytes));
  if (decoded == null) return bytes;
  const maxDim = AppConstants.maxImageDimension;
  final w = decoded.width;
  final h = decoded.height;
  if (w <= maxDim && h <= maxDim) {
    return img.encodeJpg(decoded, quality: 85);
  }
  img.Image resized;
  if (w >= h) {
    resized = img.copyResize(decoded, width: maxDim);
  } else {
    resized = img.copyResize(decoded, height: maxDim);
  }
  return img.encodeJpg(resized, quality: 85);
}
