/// Result of document pipeline: path to saved PDF.
class DocumentProcessingResult {
  const DocumentProcessingResult({
    required this.pdfPath,
    this.title,
  });
  final String pdfPath;
  final String? title;
}

/// Runs the document pipeline: text rec → boundaries → perspective → crop → enhance → PDF.
/// Heavy work off UI thread.
abstract class DocumentProcessingRepository {
  Future<DocumentProcessingResult> process(String sourceImagePath);
}
