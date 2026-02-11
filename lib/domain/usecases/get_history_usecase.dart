import '../entities/processed_item.dart';
import '../repositories/metadata_repository.dart';

/// Fetches all history items for the home list.
class GetHistoryUseCase {
  GetHistoryUseCase(this._repo);
  final MetadataRepository _repo;

  Future<List<ProcessedItem>> call() => _repo.getAll();
}
