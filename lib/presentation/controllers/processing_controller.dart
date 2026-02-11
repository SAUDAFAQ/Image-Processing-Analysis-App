import 'package:get/get.dart';

import '../../core/errors/app_failure.dart';
import '../../core/utils/content_type.dart';
import '../../domain/usecases/detect_content_usecase.dart';
import '../../domain/usecases/process_document_usecase.dart';
import '../../domain/usecases/process_face_usecase.dart';
import '../../routes/app_pages.dart';

/// Processing: detect content → run face or document pipeline → navigate to result.
/// Progress message is updated for UI (Detecting faces..., Cropping..., etc.).
class ProcessingController extends GetxController {
  ProcessingController(
    this._detectContent,
    this._processFace,
    this._processDocument,
  );

  final DetectContentUseCase _detectContent;
  final ProcessFaceUseCase _processFace;
  final ProcessDocumentUseCase _processDocument;

  final RxString progressMessage = 'Starting...'.obs;
  final RxDouble progress = 0.0.obs;
  final RxString imagePath = ''.obs;
  final RxBool isProcessing = false.obs;
  final RxString error = ''.obs;

  static const String _detectingFaces = 'Detecting faces...';
  static const String _cropping = 'Cropping...';
  static const String _enhancing = 'Enhancing...';
  static const String _buildingPdf = 'Building PDF...';

  Future<void> start(String sourceImagePath) async {
    if (sourceImagePath.isEmpty) return;
    imagePath.value = sourceImagePath;
    isProcessing.value = true;
    error.value = '';

    try {
      progressMessage.value = _detectingFaces;
      progress.value = 0.2;
      final contentType = await _detectContent(sourceImagePath);

      if (contentType == ContentType.face) {
        progressMessage.value = _cropping;
        progress.value = 0.5;
        final result = await _processFace(sourceImagePath);
        progress.value = 1.0;
        Get.offNamed(
          AppRoutes.result,
          arguments: ResultArgs(
            type: 'face',
            originalPath: sourceImagePath,
            resultPath: result.resultImagePath,
          ),
        );
      } else {
        progressMessage.value = _enhancing;
        progress.value = 0.5;
        progressMessage.value = _buildingPdf;
        progress.value = 0.8;
        final result = await _processDocument(sourceImagePath);
        progress.value = 1.0;
        Get.offNamed(
          AppRoutes.result,
          arguments: ResultArgs(
            type: 'document',
            originalPath: sourceImagePath,
            resultPath: result.pdfPath,
            title: result.title,
          ),
        );
      }
    } on ImageLoadFailure catch (e) {
      error.value = e.message;
      Get.snackbar('Image error', e.message);
    } on MLFailure catch (e) {
      error.value = e.message;
      Get.snackbar('Processing failed', e.message);
    } on StorageFailure catch (e) {
      error.value = e.message;
      Get.snackbar('Storage error', e.message);
    } catch (e) {
      final msg = e is AppFailure ? e.message : e.toString();
      error.value = msg;
      Get.snackbar('Error', msg);
    } finally {
      isProcessing.value = false;
    }
  }
}

class ResultArgs {
  ResultArgs({
    required this.type,
    required this.originalPath,
    required this.resultPath,
    this.title,
  });
  final String type;
  final String originalPath;
  final String resultPath;
  final String? title;
}
