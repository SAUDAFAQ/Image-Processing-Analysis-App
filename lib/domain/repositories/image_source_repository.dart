/// Source of image: camera or gallery.
enum ImageSourceType { camera, gallery }

/// Returns the file path of the captured/selected image.
/// Handles permissions and picker; implementation uses image_picker.
abstract class ImageSourceRepository {
  /// Returns path to the picked image file, or throws AppFailure.
  Future<String> pickImage(ImageSourceType source);
}
