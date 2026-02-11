import 'dart:io';

import '../../domain/repositories/document_processing_repository.dart';
import '../../domain/repositories/extract_document_text_repository.dart';
import '../datasources/document_processing_datasource.dart';

class DocumentProcessingRepositoryImpl implements DocumentProcessingRepository {
  DocumentProcessingRepositoryImpl(this._dataSource, this._extractTextRepo);

  final DocumentProcessingDataSource _dataSource;
  final ExtractDocumentTextRepository _extractTextRepo;

  @override
  Future<DocumentProcessingResult> process(String sourceImagePath) async {
    final result = await _dataSource.process(sourceImagePath);
    String extractedText = '';
    try {
      extractedText = await _extractTextRepo.extractFromPath(result.enhancedImagePath);
    } catch (_) {
      extractedText = '';
    }
    try {
      await File(result.enhancedImagePath).delete();
    } catch (_) {}
    return DocumentProcessingResult(
      pdfPath: result.pdfPath,
      title: result.title,
      extractedText: extractedText,
    );
  }
}
