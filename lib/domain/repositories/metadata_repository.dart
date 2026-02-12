import '../entities/processed_item.dart';

/// Repository for history metadata. Implemented by data layer with Hive.
abstract class MetadataRepository {
  Future<List<ProcessedItem>> getAll();
  Future<ProcessedItem?> getById(String id);
  Future<void> save(ProcessedItem item);
  Future<void> deleteById(String id);
}
