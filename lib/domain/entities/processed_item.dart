/// Domain entity for a single history item (face or document result).
/// No Hive or file-path details here; pure domain.
class ProcessedItem {
  const ProcessedItem({
    required this.id,
    required this.originalPath,
    required this.resultPath,
    required this.type,
    required this.date,
    required this.fileSizeBytes,
    this.title,
  });

  final String id;
  final String originalPath;
  final String resultPath;
  final String type; // 'face' | 'document'
  final DateTime date;
  final int fileSizeBytes;
  final String? title;

  bool get isFace => type == 'face';
  bool get isDocument => type == 'document';
}
