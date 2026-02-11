import '../../domain/repositories/extract_document_text_repository.dart';
import '../datasources/ocr_datasource.dart';

/// Delegates to ML Kit via OcrDataSource; never throws to UI.
class ExtractDocumentTextRepositoryImpl implements ExtractDocumentTextRepository {
  ExtractDocumentTextRepositoryImpl(this._dataSource);
  final OcrDataSource _dataSource;

  @override
  Future<String> extractFromPath(String imagePath) =>
      _dataSource.extractFromPath(imagePath);
}
