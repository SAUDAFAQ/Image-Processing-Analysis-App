import 'package:hive_flutter/hive_flutter.dart';

import '../../core/utils/constants.dart';
import '../models/processed_item_model.dart';

/// Hive-backed local storage for metadata. Uses a single box with list of maps.
abstract class MetadataLocalDataSource {
  Future<List<ProcessedItemModel>> getAll();
  Future<ProcessedItemModel?> getById(String id);
  Future<void> save(ProcessedItemModel item);
  Future<void> deleteById(String id);
}

class MetadataLocalDataSourceImpl implements MetadataLocalDataSource {
  static const _keyList = 'items';

  Box<dynamic>? _box;

  Future<Box<dynamic>> _getBox() async {
    _box ??= await Hive.openBox(AppConstants.hiveBoxName);
    return _box!;
  }

  @override
  Future<List<ProcessedItemModel>> getAll() async {
    final box = await _getBox();
    final list = box.get(_keyList) as List<dynamic>? ?? [];
    return list
        .map((e) => ProcessedItemModel.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<ProcessedItemModel?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(ProcessedItemModel item) async {
    final box = await _getBox();
    final list = await getAll();
    final index = list.indexWhere((e) => e.id == item.id);
    final map = item.toMap();
    if (index >= 0) {
      list[index] = ProcessedItemModel.fromMap(Map<dynamic, dynamic>.from(map));
    } else {
      list.add(ProcessedItemModel.fromMap(Map<dynamic, dynamic>.from(map)));
    }
    await box.put(_keyList, list.map((e) => e.toMap()).toList());
  }

  @override
  Future<void> deleteById(String id) async {
    final box = await _getBox();
    final list = await getAll();
    list.removeWhere((e) => e.id == id);
    await box.put(_keyList, list.map((e) => e.toMap()).toList());
  }
}
