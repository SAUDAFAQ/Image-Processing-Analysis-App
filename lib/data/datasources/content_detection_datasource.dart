import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../core/errors/app_failure.dart';
import '../../core/utils/content_type.dart';

/// Uses ML Kit face detection. If any face found → face, else → document.
/// Runs on main isolate (ML Kit uses platform channels); call from async to avoid blocking UI.
class ContentDetectionDataSource {
  Future<ContentType> detectFromPath(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw const ImageLoadFailure('Image file not found');
    }
    final inputImage = InputImage.fromFilePath(imagePath);
    final detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableLandmarks: false,
        enableContours: false,
        enableClassification: false,
        minFaceSize: 0.15,
      ),
    );
    try {
      final faces = await detector.processImage(inputImage);
      await detector.close();
      if (faces.isNotEmpty) {
        return ContentType.face;
      }
      return ContentType.document;
    } catch (e) {
      await detector.close();
      throw MLFailure('Face detection failed: $e');
    }
  }
}
