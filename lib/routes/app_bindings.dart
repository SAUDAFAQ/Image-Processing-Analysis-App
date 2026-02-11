import 'package:get/get.dart';

import '../core/services/storage_service.dart';
import '../data/datasources/content_detection_datasource.dart';
import '../data/datasources/document_processing_datasource.dart';
import '../data/datasources/face_processing_datasource.dart';
import '../data/datasources/image_source_datasource.dart';
import '../data/datasources/metadata_local_datasource.dart';
import '../data/datasources/ocr_datasource.dart';
import '../data/repositories/content_detection_repository_impl.dart';
import '../data/repositories/document_processing_repository_impl.dart';
import '../data/repositories/extract_document_text_repository_impl.dart';
import '../data/repositories/face_processing_repository_impl.dart';
import '../data/repositories/metadata_repository_impl.dart';
import '../domain/repositories/content_detection_repository.dart';
import '../domain/repositories/document_processing_repository.dart';
import '../domain/repositories/extract_document_text_repository.dart';
import '../domain/repositories/face_processing_repository.dart';
import '../domain/repositories/image_source_repository.dart';
import '../domain/repositories/metadata_repository.dart';
import '../domain/usecases/delete_item_usecase.dart';
import '../domain/usecases/detect_content_usecase.dart';
import '../domain/usecases/get_history_usecase.dart';
import '../domain/usecases/get_item_by_id_usecase.dart';
import '../domain/usecases/pick_image_usecase.dart';
import '../domain/usecases/process_document_usecase.dart';
import '../domain/usecases/process_face_usecase.dart';
import '../domain/usecases/save_metadata_usecase.dart';
import '../presentation/controllers/detail_controller.dart';
import '../presentation/controllers/home_controller.dart';
import '../presentation/controllers/processing_controller.dart';
import '../presentation/controllers/result_controller.dart';

void _putReposAndUseCases() {
  final storage = StorageServiceImpl();
  Get.put<StorageService>(storage, permanent: true);

  final metadataLocal = MetadataLocalDataSourceImpl();
  Get.put<MetadataLocalDataSource>(metadataLocal, permanent: true);

  final metadataRepo = MetadataRepositoryImpl(metadataLocal, storage);
  Get.put<MetadataRepository>(metadataRepo, permanent: true);

  Get.put<ContentDetectionRepository>(
    ContentDetectionRepositoryImpl(ContentDetectionDataSource()),
    permanent: true,
  );
  Get.put<FaceProcessingRepository>(
    FaceProcessingRepositoryImpl(FaceProcessingDataSource(storage)),
    permanent: true,
  );
  final ocrDataSource = OcrDataSource();
  Get.put<ExtractDocumentTextRepository>(
    ExtractDocumentTextRepositoryImpl(ocrDataSource),
    permanent: true,
  );
  Get.put<DocumentProcessingRepository>(
    DocumentProcessingRepositoryImpl(
      DocumentProcessingDataSource(storage),
      Get.find<ExtractDocumentTextRepository>(),
    ),
    permanent: true,
  );
  Get.put<ImageSourceRepository>(
    ImageSourceDataSource(),
    permanent: true,
  );

  Get.put<GetHistoryUseCase>(GetHistoryUseCase(metadataRepo), permanent: true);
  Get.put<DeleteItemUseCase>(DeleteItemUseCase(metadataRepo), permanent: true);
  Get.put<GetItemByIdUseCase>(GetItemByIdUseCase(metadataRepo), permanent: true);
  Get.put<SaveMetadataUseCase>(SaveMetadataUseCase(metadataRepo), permanent: true);
  Get.put<PickImageUseCase>(
    PickImageUseCase(Get.find<ImageSourceRepository>()),
    permanent: true,
  );
  Get.put<DetectContentUseCase>(
    DetectContentUseCase(Get.find<ContentDetectionRepository>()),
    permanent: true,
  );
  Get.put<ProcessFaceUseCase>(
    ProcessFaceUseCase(Get.find<FaceProcessingRepository>()),
    permanent: true,
  );
  Get.put<ProcessDocumentUseCase>(
    ProcessDocumentUseCase(Get.find<DocumentProcessingRepository>()),
    permanent: true,
  );
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    _putReposAndUseCases();
    Get.lazyPut<HomeController>(() => HomeController(
          Get.find<GetHistoryUseCase>(),
          Get.find<DeleteItemUseCase>(),
        ));
  }
}

class ProcessingBinding extends Bindings {
  @override
  void dependencies() {
    _putReposAndUseCases();
    Get.lazyPut<ProcessingController>(() => ProcessingController(
          Get.find<DetectContentUseCase>(),
          Get.find<ProcessFaceUseCase>(),
          Get.find<ProcessDocumentUseCase>(),
        ));
  }
}

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    _putReposAndUseCases();
    Get.lazyPut<ResultController>(() => ResultController(
          Get.find<SaveMetadataUseCase>(),
          Get.find<StorageService>(),
        ));
  }
}

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    _putReposAndUseCases();
    Get.lazyPut<DetailController>(() => DetailController(
          Get.find<GetItemByIdUseCase>(),
        ));
  }
}
