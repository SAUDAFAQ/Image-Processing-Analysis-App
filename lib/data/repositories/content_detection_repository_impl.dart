import '../../core/utils/content_type.dart';
import '../../domain/repositories/content_detection_repository.dart';
import '../datasources/content_detection_datasource.dart';

class ContentDetectionRepositoryImpl implements ContentDetectionRepository {
  ContentDetectionRepositoryImpl(this._dataSource);

  final ContentDetectionDataSource _dataSource;

  @override
  Future<ContentType> detectFromImagePath(String imagePath) =>
      _dataSource.detectFromPath(imagePath);
}
