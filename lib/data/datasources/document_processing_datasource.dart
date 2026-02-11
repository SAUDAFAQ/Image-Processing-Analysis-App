import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/errors/app_failure.dart';
import '../../core/services/storage_service.dart';

/// Document pipeline: text rec → best-effort bounds → crop → enhance contrast → PDF → save.
/// Structure is extension-ready for real CV (e.g. edge detection, perspective).
class DocumentProcessingDataSource {
  DocumentProcessingDataSource(this._storage);

  final StorageService _storage;

  Future<({String pdfPath, String? title})> process(String sourceImagePath) async {
    final file = File(sourceImagePath);
    if (!await file.exists()) {
      throw const ImageLoadFailure('Source image not found');
    }
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const ImageLoadFailure('Failed to decode image');

    // Text recognition for context; document bounds could use block corners in production.
    final inputImage = InputImage.fromFilePath(sourceImagePath);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      await recognizer.processImage(inputImage);
    } catch (_) {}
    recognizer.close();

    // Best-effort: use full image as "document". Replace with real edge/perspective later.
    img.Image processed = decoded;
    processed = _enhanceContrast(processed);
    final pngBytes = img.encodePng(processed);

    final dir = await _storage.getDocsDir();
    final pdfPath = _storage.uniquePath(dir, prefix: 'doc', extension: '.pdf');
    final title = 'Document ${DateTime.now().toIso8601String().split('T').first}';
    await _writePdfFromImage(pdfPath, pngBytes, title);
    return (pdfPath: pdfPath, title: title);
  }

  img.Image _enhanceContrast(img.Image src) {
    return img.adjustColor(src, contrast: 1.2);
  }

  Future<void> _writePdfFromImage(String pdfPath, List<int> imageBytes, String title) async {
    final doc = pw.Document();
    final image = pw.MemoryImage(Uint8List.fromList(imageBytes));
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );
    final file = File(pdfPath);
    await file.writeAsBytes(await doc.save());
  }
}
