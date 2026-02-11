import '../repositories/face_processing_repository.dart';

/// Runs full face pipeline; returns path to result image.
class ProcessFaceUseCase {
  ProcessFaceUseCase(this._repo);
  final FaceProcessingRepository _repo;

  Future<FaceProcessingResult> call(String sourceImagePath) =>
      _repo.process(sourceImagePath);
}
