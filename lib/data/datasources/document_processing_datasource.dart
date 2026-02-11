import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/errors/app_failure.dart';
import '../../core/services/storage_service.dart';

/// Document pipeline: enhance → write temp image (for OCR) → PDF → save.
/// Structure is extension-ready for real CV (e.g. edge detection, perspective).
class DocumentProcessingDataSource {
  DocumentProcessingDataSource(this._storage);

  final StorageService _storage;

  /// Returns pdfPath, title, and path to enhanced image (for OCR). Caller runs OCR and may delete temp file.
  Future<({String pdfPath, String? title, String enhancedImagePath})> process(String sourceImagePath) async {
    final file = File(sourceImagePath);
    if (!await file.exists()) {
      throw const ImageLoadFailure('Source image not found');
    }
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const ImageLoadFailure('Failed to decode image');

    img.Image processed = decoded;
    processed = _enhanceContrast(processed);
    final pngBytes = img.encodePng(processed);

    final tempDir = await getTemporaryDirectory();
    final enhancedPath = p.join(tempDir.path, 'imageflow_enhanced_${DateTime.now().millisecondsSinceEpoch}.png');
    await File(enhancedPath).writeAsBytes(pngBytes);

    final dir = await _storage.getDocsDir();
    final pdfPath = _storage.uniquePath(dir, prefix: 'doc', extension: '.pdf');
    final title = 'Document ${DateTime.now().toIso8601String().split('T').first}';
    await _writePdfFromImage(pdfPath, pngBytes, title);
    return (pdfPath: pdfPath, title: title, enhancedImagePath: enhancedPath);
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
