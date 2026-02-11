import '../../core/utils/content_type.dart';

/// Detects whether image content is face or document.
/// Uses ML Kit face detection first; if no faces, treats as document.
abstract class ContentDetectionRepository {
  Future<ContentType> detectFromImagePath(String imagePath);
}
