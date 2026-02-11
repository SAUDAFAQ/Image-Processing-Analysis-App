/// App-wide constants. Storage paths are relative to getApplicationDocumentsDirectory.
class AppConstants {
  AppConstants._();

  static const String appStorageFolder = 'ImageFlow';
  static const String facesSubfolder = 'faces';
  static const String docsSubfolder = 'docs';
  static const String hiveBoxName = 'imageflow_metadata';

  /// Max longest edge when copying picked images. Reduces OOM/crashes on large camera photos.
  static const int maxImageDimension = 1920;
}
