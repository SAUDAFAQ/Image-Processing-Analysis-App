/// Result of face pipeline: path to saved composite image.
class FaceProcessingResult {
  const FaceProcessingResult({required this.resultImagePath});
  final String resultImagePath;
}

/// Runs the face pipeline: detect → crop → grayscale → paste → save.
/// Heavy work must be off UI thread (caller uses compute/isolate).
abstract class FaceProcessingRepository {
  Future<FaceProcessingResult> process(String sourceImagePath);
}
