import '../repositories/document_processing_repository.dart';

/// Runs full document pipeline; returns path to PDF.
class ProcessDocumentUseCase {
  ProcessDocumentUseCase(this._repo);
  final DocumentProcessingRepository _repo;

  Future<DocumentProcessingResult> call(String sourceImagePath) =>
      _repo.process(sourceImagePath);
}
