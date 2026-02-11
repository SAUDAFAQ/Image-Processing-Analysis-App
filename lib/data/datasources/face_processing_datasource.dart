import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../core/errors/app_failure.dart';
import '../../core/services/storage_service.dart';

/// Face pipeline: detect → crop each face → grayscale → paste back → save.
/// Heavy decode/encode and pixel work runs in compute isolate.
class FaceProcessingDataSource {
  FaceProcessingDataSource(this._storage);

  final StorageService _storage;

  Future<String> process(String sourceImagePath) async {
    final file = File(sourceImagePath);
    if (!await file.exists()) {
      throw const ImageLoadFailure('Source image not found');
    }
    final bytes = await file.readAsBytes();

    final inputImage = InputImage.fromFilePath(sourceImagePath);
    final detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableLandmarks: false,
        enableContours: false,
        enableClassification: false,
        minFaceSize: 0.15,
      ),
    );
    List<Face> faces;
    try {
      faces = await detector.processImage(inputImage);
      await detector.close();
    } catch (e) {
      await detector.close();
      throw MLFailure('Face detection failed: $e');
    }

    if (faces.isEmpty) {
      throw const MLFailure('No faces found in image');
    }

    // Get dimensions from decoded image; InputImage.metadata can be null/zero on some platforms.
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const ImageLoadFailure('Failed to decode image');
    }
    final width = decoded.width;
    final height = decoded.height;
    if (width <= 0 || height <= 0) {
      throw const ImageLoadFailure('Invalid image dimensions');
    }
    final rects = faces.map((f) {
      final r = f.boundingBox;
      return <double>[
        r.left / width,
        r.top / height,
        r.right / width,
        r.bottom / height,
      ];
    }).toList();

    // Payload as List for isolate-safe transfer.
    final resultBytes = await compute(
      processFaceIsolate,
      <dynamic>[bytes, width, height, rects],
    );
    if (resultBytes == null || resultBytes.isEmpty) {
      throw const MLFailure('Face processing produced empty result');
    }

    final dir = await _storage.getFacesDir();
    final outPath = _storage.uniquePath(dir, prefix: 'face', extension: '.png');
    final outFile = File(outPath);
    await outFile.writeAsBytes(resultBytes);
    return outPath;
  }
}

/// Top-level for compute: [bytes, width, height, rects].
/// Crops each face rect → grayscale → pastes back as bounding rectangle.
List<int>? processFaceIsolate(List<dynamic> args) {
  final bytes = Uint8List.fromList(args[0] as List<int>);
  final rects = args[3] as List<List<double>>;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final w = decoded.width;
  final h = decoded.height;

  for (final r in rects) {
    final x1 = (r[0] * w).round().clamp(0, w - 1);
    final y1 = (r[1] * h).round().clamp(0, h - 1);
    final x2 = (r[2] * w).round().clamp(0, w);
    final y2 = (r[3] * h).round().clamp(0, h);
    final cropW = x2 - x1;
    final cropH = y2 - y1;
    if (cropW <= 0 || cropH <= 0) continue;
    final crop = img.copyCrop(decoded, x: x1, y: y1, width: cropW, height: cropH);
    final gray = img.grayscale(crop);
    img.compositeImage(decoded, gray, dstX: x1, dstY: y1);
  }
  return img.encodePng(decoded);
}
