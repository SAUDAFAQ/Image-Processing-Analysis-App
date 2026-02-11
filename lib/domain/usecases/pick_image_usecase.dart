import '../repositories/image_source_repository.dart';

/// Picks image from camera or gallery; returns file path.
class PickImageUseCase {
  PickImageUseCase(this._repo);
  final ImageSourceRepository _repo;

  Future<String> call(ImageSourceType source) => _repo.pickImage(source);
}
