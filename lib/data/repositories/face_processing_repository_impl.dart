import '../../domain/repositories/face_processing_repository.dart';
import '../datasources/face_processing_datasource.dart';

class FaceProcessingRepositoryImpl implements FaceProcessingRepository {
  FaceProcessingRepositoryImpl(this._dataSource);

  final FaceProcessingDataSource _dataSource;

  @override
  Future<FaceProcessingResult> process(String sourceImagePath) async {
    final path = await _dataSource.process(sourceImagePath);
    return FaceProcessingResult(resultImagePath: path);
  }
}
