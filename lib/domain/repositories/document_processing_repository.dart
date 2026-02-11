/// Result of document pipeline: path to saved PDF and extracted OCR text.
class DocumentProcessingResult {
  const DocumentProcessingResult({
    required this.pdfPath,
    this.title,
    this.extractedText = '',
  });
  final String pdfPath;
  final String? title;
  final String extractedText;
}

/// Runs the document pipeline: text rec → boundaries → perspective → crop → enhance → PDF.
/// Heavy work off UI thread.
abstract class DocumentProcessingRepository {
  Future<DocumentProcessingResult> process(String sourceImagePath);
}
