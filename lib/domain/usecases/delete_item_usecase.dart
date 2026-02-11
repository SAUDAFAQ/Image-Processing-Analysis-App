import '../repositories/metadata_repository.dart';

/// Deletes a history item by id (metadata + optional file cleanup in repo impl).
class DeleteItemUseCase {
  DeleteItemUseCase(this._metadataRepo);
  final MetadataRepository _metadataRepo;

  Future<void> call(String id) => _metadataRepo.deleteById(id);
}
