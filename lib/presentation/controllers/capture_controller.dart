import 'package:get/get.dart';

import '../../core/errors/app_failure.dart';
import '../../domain/repositories/image_source_repository.dart';
import '../../domain/usecases/pick_image_usecase.dart';
import '../../routes/app_pages.dart';

/// Capture: pick camera or gallery; on success navigate to processing with path.
class CaptureController extends GetxController {
  CaptureController(this._pickImage);

  final PickImageUseCase _pickImage;

  final RxBool loading = false.obs;

  Future<void> pickCamera() async {
    await _pickSource(ImageSourceType.camera);
  }

  Future<void> pickGallery() async {
    await _pickSource(ImageSourceType.gallery);
  }

  Future<void> _pickSource(ImageSourceType source) async {
    loading.value = true;
    try {
      final path = await _pickImage(source);
      loading.value = false;
      Get.back();
      Get.toNamed(AppRoutes.processing, arguments: path);
    } on PermissionFailure catch (e) {
      loading.value = false;
      Get.snackbar('Permission', e.message);
    } on ImageLoadFailure catch (e) {
      loading.value = false;
      Get.snackbar('Error', e.message);
    } catch (e) {
      loading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }
}
