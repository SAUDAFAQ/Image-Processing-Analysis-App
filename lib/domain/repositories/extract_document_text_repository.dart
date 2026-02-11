/// Extracts plain text from an image file using OCR (e.g. ML Kit).
/// Implementations must not throw to UI; return empty string on failure.
abstract class ExtractDocumentTextRepository {
  Future<String> extractFromPath(String imagePath);
}
