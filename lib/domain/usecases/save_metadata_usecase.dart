import '../entities/processed_item.dart';
import '../repositories/metadata_repository.dart';

/// Persists a processed item to history (Hive).
class SaveMetadataUseCase {
  SaveMetadataUseCase(this._repo);
  final MetadataRepository _repo;

  Future<void> call(ProcessedItem item) => _repo.save(item);
}
