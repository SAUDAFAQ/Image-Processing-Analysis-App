import '../../domain/entities/processed_item.dart';

/// Data model for Hive storage. Stored as Map in Hive (no code gen).
class ProcessedItemModel {
  ProcessedItemModel({
    required this.id,
    required this.originalPath,
    required this.resultPath,
    required this.type,
    required this.dateMillis,
    required this.fileSizeBytes,
    this.title,
    this.ocrText,
  });

  final String id;
  final String originalPath;
  final String resultPath;
  final String type;
  final int dateMillis;
  final int fileSizeBytes;
  final String? title;
  final String? ocrText;

  Map<String, dynamic> toMap() => {
        'id': id,
        'originalPath': originalPath,
        'resultPath': resultPath,
        'type': type,
        'dateMillis': dateMillis,
        'fileSizeBytes': fileSizeBytes,
        'title': title,
        'ocrText': ocrText,
      };

  static ProcessedItemModel fromMap(Map<dynamic, dynamic> map) {
    return ProcessedItemModel(
      id: map['id'] as String,
      originalPath: map['originalPath'] as String,
      resultPath: map['resultPath'] as String,
      type: map['type'] as String,
      dateMillis: map['dateMillis'] as int,
      fileSizeBytes: map['fileSizeBytes'] as int,
      title: map['title'] as String?,
      ocrText: map['ocrText'] as String?,
    );
  }

  ProcessedItem toEntity() => ProcessedItem(
        id: id,
        originalPath: originalPath,
        resultPath: resultPath,
        type: type,
        date: DateTime.fromMillisecondsSinceEpoch(dateMillis),
        fileSizeBytes: fileSizeBytes,
        title: title,
        ocrText: ocrText,
      );

  static ProcessedItemModel fromEntity(ProcessedItem e) => ProcessedItemModel(
        id: e.id,
        originalPath: e.originalPath,
        resultPath: e.resultPath,
        type: e.type,
        dateMillis: e.date.millisecondsSinceEpoch,
        fileSizeBytes: e.fileSizeBytes,
        title: e.title,
        ocrText: e.ocrText,
      );
}
