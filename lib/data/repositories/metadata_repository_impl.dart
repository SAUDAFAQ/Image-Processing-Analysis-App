import '../../core/services/storage_service.dart';
import '../../domain/entities/processed_item.dart';
import '../../domain/repositories/metadata_repository.dart';
import '../datasources/metadata_local_datasource.dart';
import '../models/processed_item_model.dart';

/// Metadata repository: Hive for list, optional file delete on deleteById.
class MetadataRepositoryImpl implements MetadataRepository {
  MetadataRepositoryImpl(this._local, this._storage);

  final MetadataLocalDataSource _local;
  final StorageService _storage;

  @override
  Future<List<ProcessedItem>> getAll() async {
    final list = await _local.getAll();
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<ProcessedItem?> getById(String id) async {
    final m = await _local.getById(id);
    return m?.toEntity();
  }

  @override
  Future<void> save(ProcessedItem item) async {
    await _local.save(ProcessedItemModel.fromEntity(item));
  }

  @override
  Future<void> deleteById(String id) async {
    final item = await _local.getById(id);
    if (item != null) {
      await _storage.deleteFile(item.resultPath);
    }
    await _local.deleteById(id);
  }
}
