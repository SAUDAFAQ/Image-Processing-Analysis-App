import '../../domain/repositories/document_processing_repository.dart';
import '../datasources/document_processing_datasource.dart';

class DocumentProcessingRepositoryImpl implements DocumentProcessingRepository {
  DocumentProcessingRepositoryImpl(this._dataSource);

  final DocumentProcessingDataSource _dataSource;

  @override
  Future<DocumentProcessingResult> process(String sourceImagePath) async {
    final result = await _dataSource.process(sourceImagePath);
    return DocumentProcessingResult(
      pdfPath: result.pdfPath,
      title: result.title,
    );
  }
}
