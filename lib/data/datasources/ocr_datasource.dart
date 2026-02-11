import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Runs ML Kit text recognition on an image file. Never throws; returns empty string on failure.
/// Recognizer is created and closed per call to avoid keeping heavy resources alive.
class OcrDataSource {
  Future<String> extractFromPath(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) return '';
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(inputImage);
      final text = result.text.trim();
      return text;
    } catch (_) {
      return '';
    } finally {
      recognizer.close();
    }
  }
}
