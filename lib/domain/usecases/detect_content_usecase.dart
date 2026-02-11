import '../../core/utils/content_type.dart';
import '../repositories/content_detection_repository.dart';

/// Determines if image is face or document (routes to correct pipeline).
class DetectContentUseCase {
  DetectContentUseCase(this._repo);
  final ContentDetectionRepository _repo;

  Future<ContentType> call(String imagePath) =>
      _repo.detectFromImagePath(imagePath);
}
