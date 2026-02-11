import '../entities/processed_item.dart';
import '../repositories/metadata_repository.dart';

/// Fetches a single item for detail screen.
class GetItemByIdUseCase {
  GetItemByIdUseCase(this._repo);
  final MetadataRepository _repo;

  Future<ProcessedItem?> call(String id) => _repo.getById(id);
}
